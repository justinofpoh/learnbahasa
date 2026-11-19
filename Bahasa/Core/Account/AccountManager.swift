import AuthenticationServices
import Combine
import CryptoKit
import Foundation
import RevenueCat
import Supabase

/// Optional sign-in (Apple or Google) through Supabase, so progress follows the learner to
/// learnbahasa.app and to a new phone. Without sign-in the app works exactly as before.
///
/// Config: `SupabaseHost` (e.g. `abcd.supabase.co`) and `SupabaseAnonKey` in Info.plist, from the
/// `SUPABASE_HOST` / `SUPABASE_ANON_KEY` build settings. Empty = accounts are hidden.
@MainActor
final class AccountManager: ObservableObject {
    enum SyncState: Equatable {
        case idle, syncing
        case synced(Date)
        case failed(String)
    }

    struct Account: Equatable {
        let id: UUID
        let email: String?
        let provider: String
    }

    @Published private(set) var account: Account?
    @Published private(set) var syncState: SyncState = .idle
    @Published private(set) var busy = false
    @Published var error: String?

    let client: SupabaseClient?
    private weak var progress: ProgressStore?
    private var changes: AnyCancellable?
    private var applyingRemote = false
    private var appleNonce: String?

    static let callback = URL(string: "bahasa://auth-callback")!

    var isAvailable: Bool { client != nil }

    init() {
        let host = (Bundle.main.object(forInfoDictionaryKey: "SupabaseHost") as? String ?? "").trimmingCharacters(in: .whitespaces)
        let key = (Bundle.main.object(forInfoDictionaryKey: "SupabaseAnonKey") as? String ?? "").trimmingCharacters(in: .whitespaces)
        if !host.isEmpty, !key.isEmpty, !host.hasPrefix("$("), let url = URL(string: "https://" + host) {
            client = SupabaseClient(supabaseURL: url, supabaseKey: key)
        } else {
            client = nil
        }
    }

    /// Call once at launch with the app's progress store.
    func start(progress: ProgressStore) {
        guard let client, self.progress == nil else { return }
        self.progress = progress
        if let user = client.auth.currentUser { signedIn(user) }
        // Push local changes a few seconds after they settle.
        changes = progress.objectWillChange
            .debounce(for: .seconds(4), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self, !self.applyingRemote, self.account != nil else { return }
                Task { await self.sync() }
            }
        Task {
            for await (event, session) in client.auth.authStateChanges {
                switch event {
                case .signedIn, .initialSession, .tokenRefreshed, .userUpdated:
                    if let user = session?.user { signedIn(user) }
                case .signedOut, .userDeleted:
                    account = nil
                    syncState = .idle
                default:
                    break
                }
            }
        }
        if account != nil { Task { await sync() } }
    }

    private func signedIn(_ user: User) {
        let provider = (user.appMetadata["provider"]?.stringValue) ?? "email"
        let new = Account(id: user.id, email: user.email, provider: provider)
        guard account != new else { return }
        account = new
        // Plus follows the account: RevenueCat links purchases to this user ID.
        if Purchases.isConfigured {
            Task { _ = try? await Purchases.shared.logIn(user.id.uuidString.lowercased()) }
        }
    }

    // MARK: Sign in with Apple (native sheet)

    /// Fills the Apple request with scopes and a hashed nonce.
    func prepare(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = Self.randomNonce()
        appleNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)
    }

    func finishApple(_ result: Result<ASAuthorization, Error>) async {
        guard let client else { return }
        switch result {
        case .failure(let e):
            if (e as? ASAuthorizationError)?.code != .canceled { error = e.localizedDescription }
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken, let token = String(data: tokenData, encoding: .utf8) else {
                error = "Apple didn't return a sign-in token. Please try again."
                return
            }
            busy = true
            defer { busy = false }
            do {
                let session = try await client.auth.signInWithIdToken(
                    credentials: .init(provider: .apple, idToken: token, nonce: appleNonce))
                signedIn(session.user)
                if let given = credential.fullName?.givenName, let progress, progress.profile.name.isEmpty {
                    progress.mutateRehearsal { $0.profile.name = given }
                }
                await sync()
            } catch {
                self.error = "Couldn't sign in with Apple: \(error.localizedDescription)"
            }
        }
    }

    // MARK: Google (web sign-in sheet)

    func signInWithGoogle() async {
        guard let client else { return }
        busy = true
        defer { busy = false }
        do {
            let session = try await client.auth.signInWithOAuth(provider: .google, redirectTo: Self.callback)
            signedIn(session.user)
            await sync()
        } catch {
            if (error as? ASWebAuthenticationSessionError)?.code == .canceledLogin { return }
            self.error = "Couldn't sign in with Google: \(error.localizedDescription)"
        }
    }

    // MARK: Sync

    private struct Row: Codable {
        let user_id: UUID
        let data: SyncDocument
    }

    /// Pulls the account's progress, merges it into this phone, and pushes the merged result back.
    func sync() async {
        guard let client, let progress, let account, syncState != .syncing else { return }
        syncState = .syncing
        do {
            let rows: [Row] = try await client.from("progress").select().eq("user_id", value: account.id).execute().value
            if let remote = rows.first?.data {
                let merged = SyncMerge.merge(local: (progress.state, progress.rehearsal), remote: remote)
                applyingRemote = true
                progress.adopt(merged)
                applyingRemote = false
            }
            let doc = SyncMerge.document(progress: progress.state, rehearsal: progress.rehearsal)
            try await client.from("progress").upsert(Row(user_id: account.id, data: doc)).execute()
            syncState = .synced(Date())
        } catch {
            applyingRemote = false
            syncState = .failed(error.localizedDescription)
        }
    }

    // MARK: Sign out and delete

    func signOut() async {
        guard let client else { return }
        try? await client.auth.signOut()
        account = nil
        syncState = .idle
        if Purchases.isConfigured, !(Purchases.shared.isAnonymous) { _ = try? await Purchases.shared.logOut() }
    }

    /// Deletes the account and its saved progress (this phone keeps its own copy).
    func deleteAccount() async -> Bool {
        guard let client, account != nil else { return false }
        busy = true
        defer { busy = false }
        do {
            try await client.rpc("delete_my_account").execute()
            await signOut()
            return true
        } catch {
            self.error = "Couldn't delete the account: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: Nonce helpers

    private static func randomNonce(length: Int = 32) -> String {
        let chars = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var out = ""
        var generator = SystemRandomNumberGenerator()
        for _ in 0..<length { out.append(chars[Int(generator.next() % UInt64(chars.count))]) }
        return out
    }

    private static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}
