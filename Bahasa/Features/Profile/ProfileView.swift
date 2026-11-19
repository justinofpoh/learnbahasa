import AuthenticationServices
import SwiftUI

/// The learner's face in the top-right corner of every tab. Opens Profile.
struct ProfileButton: View {
    @EnvironmentObject private var progress: ProgressStore
    @EnvironmentObject private var purchases: PurchaseManager
    @EnvironmentObject private var account: AccountManager
    @State private var open = false

    var body: some View {
        Button {
            Haptics.select()
            open = true
        } label: {
            let id = progress.profile.avatar.isEmpty ? Cast.defaultAvatar : progress.profile.avatar
            CharacterPortrait(characterID: id, tint: Cast.avatarTint(id), size: 46, animated: false)
                .overlay(alignment: .bottomTrailing) {
                    if purchases.isPlus {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(width: 18, height: 18)
                            .background(Circle().fill(Theme.sambal))
                            .overlay(Circle().stroke(.white, lineWidth: 1.5))
                            .offset(x: 3, y: 3)
                    }
                }
        }
        .buttonStyle(.squish)
        .accessibilityLabel("Profile")
        .sheet(isPresented: $open) {
            ProfileSheet()
                .environmentObject(progress)
                .environmentObject(purchases)
                .environmentObject(account)
                .presentationDragIndicator(.visible)
        }
    }
}

/// Everything about you in one sheet: your look, details, level, chat speed, Plus and help.
struct ProfileSheet: View {
    @EnvironmentObject private var progress: ProgressStore
    @EnvironmentObject private var purchases: PurchaseManager
    @EnvironmentObject private var account: AccountManager
    @State private var confirmDelete = false
    @Environment(\.dismiss) private var dismiss
    @AppStorage("bahasa.onboarded") private var onboarded = true
    @AppStorage(ChatPace.storageKey) private var pace: ChatPace = .normal
    @AppStorage(ChatPace.waitKey) private var waitForMe = false
    @State private var draft = LearnerProfile()
    @State private var paywall: PaywallContext?
    @State private var restoring = false
    @State private var restoreNote: String?

    private var avatarID: String { draft.avatar.isEmpty ? Cast.defaultAvatar : draft.avatar }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 14) {
                        CharacterPortrait(characterID: avatarID, tint: Cast.avatarTint(avatarID), size: 92, expression: .happy)
                            .id(avatarID)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                        Text(draft.name.isEmpty ? "Your profile" : draft.name)
                            .font(.rounded(22, .heavy))
                            .foregroundStyle(Theme.ink)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                            ForEach(Cast.avatars, id: \.id) { a in
                                Button {
                                    Haptics.select()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { draft.avatar = a.id }
                                } label: {
                                    CharacterPortrait(characterID: a.id, tint: a.tint, size: 58, animated: false)
                                        .overlay(Circle().stroke(a.id == avatarID ? Theme.sambal : .clear, lineWidth: 3).padding(-4))
                                }
                                .buttonStyle(.squish)
                                .accessibilityLabel("Look \(a.id.replacingOccurrences(of: "you-", with: ""))")
                                .accessibilityAddTraits(a.id == avatarID ? .isSelected : [])
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .listRowBackground(Color.clear)
                }

                if account.isAvailable { accountSection }

                Section {
                    plusRow
                    if purchases.isPlus {
                        Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                            Label("Manage subscription", systemImage: "creditcard")
                        }
                        .foregroundStyle(Theme.ink)
                    }
                    Button {
                        Task { await restore() }
                    } label: {
                        HStack {
                            Label("Restore purchases", systemImage: "arrow.clockwise")
                            Spacer()
                            if restoring { ProgressView() }
                        }
                    }
                    .foregroundStyle(Theme.ink)
                    .disabled(restoring)
                } header: {
                    Text("Bahasa Plus")
                } footer: {
                    if let restoreNote { Text(restoreNote) }
                }

                Section {
                    TextField("Your name", text: $draft.name)
                        .textInputAutocapitalization(.words)
                    Picker("From", selection: $draft.country) {
                        Text("Not set").tag("")
                        ForEach(SceneLibrary.pack.countries, id: \.local) { c in
                            Text(c.local == c.en ? c.en : "\(c.en) · \(c.local)").tag(c.local)
                        }
                    }
                    TextField("Where you live (e.g. Canggu)", text: $draft.city)
                } header: {
                    Text("About you")
                } footer: {
                    Text("Your details fill the lines you say: \"Saya dari \(draft.country.isEmpty ? "…" : draft.country)\".")
                }

                Section {
                    Picker("Level", selection: $draft.level) {
                        if draft.level < 0 { Text("Not set").tag(-1) }
                        ForEach(LearnerLevel.allCases) { l in
                            Text(l.title).tag(l.rawValue)
                        }
                    }
                    Picker("Chat speed", selection: $pace) {
                        ForEach(ChatPace.allCases) { p in
                            Label(p.title, systemImage: p.symbol).tag(p)
                        }
                    }
                    Toggle("Wait for me", isOn: $waitForMe)
                        .tint(Theme.sambal)
                } header: {
                    Text("Learning")
                } footer: {
                    Text("\(pace.note). With \"Wait for me\", listening chats stop after each line until you tap Next.")
                }

                Section {
                    Link(destination: URL(string: "mailto:\(LegalLinks.email)")!) {
                        Label("Email us", systemImage: "envelope")
                    }
                    Link(destination: LegalLinks.support) {
                        Label("Help", systemImage: "questionmark.circle")
                    }
                    Link(destination: LegalLinks.privacy) {
                        Label("Privacy", systemImage: "hand.raised")
                    }
                    Button {
                        save()
                        onboarded = false
                        dismiss()
                    } label: {
                        Label("Show the welcome again", systemImage: "sparkles")
                    }
                }
                .foregroundStyle(Theme.ink)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .tint(Theme.sambal)
        .onAppear { draft = progress.profile }
        .paywall($paywall)
    }

    @ViewBuilder
    private var accountSection: some View {
        Section {
            if let user = account.account {
                HStack(spacing: 12) {
                    Image(systemName: user.provider == "apple" ? "apple.logo" : "person.crop.circle.badge.checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Signed in with \(user.provider == "google" ? "Google" : user.provider == "apple" ? "Apple" : "email")")
                            .font(.rounded(16, .bold))
                            .foregroundStyle(Theme.ink)
                        Text(syncNote)
                            .font(.ui(13))
                            .foregroundStyle(Theme.inkSoft)
                    }
                }
                Button {
                    Task { await account.sync() }
                } label: {
                    Label("Sync now", systemImage: "arrow.triangle.2.circlepath")
                }
                .foregroundStyle(Theme.ink)
                .disabled(account.syncState == .syncing)
                Button("Sign out") { Task { await account.signOut() } }
                    .foregroundStyle(Theme.ink)
                Button("Delete account", role: .destructive) { confirmDelete = true }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    SignInWithAppleButton(.signIn) { request in
                        account.prepare(request)
                    } onCompletion: { result in
                        Task { await account.finishApple(result) }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 46)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Button {
                        Task { await account.signInWithGoogle() }
                    } label: {
                        HStack(spacing: 8) {
                            Text("G").font(.system(size: 18, weight: .heavy)).foregroundStyle(Color(hex: 0x4285F4))
                            Text("Continue with Google").font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.white))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Theme.line, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
                .disabled(account.busy)
            }
        } header: {
            Text("Account")
        } footer: {
            Text(account.account == nil
                 ? "Optional. Save your progress and pick it up on learnbahasa.app or a new phone."
                 : "Your lessons, chats and saved lines are backed up to your account.")
        }
        .alert("Delete your account?", isPresented: $confirmDelete) {
            Button("Delete", role: .destructive) { Task { _ = await account.deleteAccount() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your saved progress online is deleted for good. This phone keeps its own copy. Bahasa Plus isn't cancelled; manage it in your Apple subscriptions.")
        }
        .alert("Account", isPresented: Binding(get: { account.error != nil }, set: { if !$0 { account.error = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(account.error ?? "")
        }
    }

    private var syncNote: String {
        switch account.syncState {
        case .idle: return "Progress syncs automatically"
        case .syncing: return "Syncing…"
        case .synced(let date): return "Synced \(date.formatted(date: .omitted, time: .shortened))"
        case .failed: return "Couldn't sync. Check your connection."
        }
    }

    @ViewBuilder
    private var plusRow: some View {
        if purchases.isPlus {
            HStack(spacing: 12) {
                PlusBadge(size: 30)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Plus is on")
                        .font(.rounded(16, .bold))
                        .foregroundStyle(Theme.ink)
                    Text(plusNote)
                        .font(.ui(13))
                        .foregroundStyle(Theme.inkSoft)
                }
            }
            .padding(.vertical, 2)
        } else {
            Button {
                Haptics.select()
                paywall = .general
            } label: {
                HStack(spacing: 12) {
                    PlusBadge(size: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Get Bahasa Plus")
                            .font(.rounded(16, .bold))
                            .foregroundStyle(Theme.sambal)
                        Text("You're on Free · \(freeSceneCount) of \(SceneLibrary.scenes.count) chats open")
                            .font(.ui(13))
                            .foregroundStyle(Theme.inkSoft)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.inkSoft)
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var freeSceneCount: Int {
        SceneLibrary.scenes.filter { Access.scene($0.id, plan: .free) }.count
    }

    private var plusNote: String {
        guard let status = purchases.subscription else { return "Every neighbour, every lesson." }
        let kind = status.productID == ProductIDs.annual ? "Yearly" : "Monthly"
        guard let date = status.expirationDate else { return kind }
        let when = date.formatted(date: .abbreviated, time: .omitted)
        return status.isInTrial ? "\(kind) · free trial until \(when)" : "\(kind) · renews \(when)"
    }

    private func save() {
        let profile = draft
        progress.mutateRehearsal { $0.profile = profile }
    }

    private func restore() async {
        restoring = true
        restoreNote = nil
        let result = await purchases.restore()
        restoring = false
        switch result {
        case .success(let plan):
            restoreNote = plan == .plus ? "Plus is back on." : "No subscription found for this Apple ID."
            if plan == .plus { Haptics.correct() }
        case .failure:
            restoreNote = "Couldn't reach the App Store. Check your connection and try again."
        }
    }
}

/// The four starting levels picked in onboarding.
enum LearnerLevel: Int, CaseIterable, Identifiable {
    case new = 0, fewWords, getBy, chat

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .new: return "Brand new"
        case .fewWords: return "A few words"
        case .getBy: return "I can get by"
        case .chat: return "I can chat"
        }
    }

    var note: String {
        switch self {
        case .new: return "Halo is all I've got"
        case .fewWords: return "Terima kasih, satu, dua…"
        case .getBy: return "I can order food and ask prices"
        case .chat: return "Small talk, past and future"
        }
    }

    var color: Color {
        switch self {
        case .new: return Theme.sawah
        case .fewWords: return Theme.kunyit
        case .getBy: return Theme.laut
        case .chat: return Theme.indigo
        }
    }

    /// The first Learn unit that's still worth doing at this level.
    var startUnit: Int {
        switch self {
        case .new, .fewWords: return 1
        case .getBy: return 3
        case .chat: return 5
        }
    }

    /// A sensible chat speed to start with.
    var pace: ChatPace {
        switch self {
        case .new, .fewWords: return .relaxed
        case .getBy: return .normal
        case .chat: return .local
        }
    }
}
