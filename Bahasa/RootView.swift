import SwiftUI

enum AppTab: String, CaseIterable {
    case learn, talk, patterns, phrases

    var title: String {
        switch self {
        case .learn: return "Learn"
        case .talk: return "Talk"
        case .patterns: return "Patterns"
        case .phrases: return "Phrases"
        }
    }

    var symbol: String {
        switch self {
        case .learn: return "book.closed.fill"
        case .talk: return "bubble.left.and.bubble.right.fill"
        case .patterns: return "square.grid.3x2.fill"
        case .phrases: return "text.book.closed.fill"
        }
    }
}

/// `bahasa://talk/<scene id>` or `https://learnbahasa.app/talk/<scene id>` opens that Scene. Old ids (`s1`…`s5`, used by the App Store event) still work.
final class EventRouter: ObservableObject {
    @Published var scenarioID: String?

    /// Accepts `bahasa://talk/<id>` and the universal link `https://learnbahasa.app/talk/<id>`.
    func open(_ url: URL) {
        let id: String
        if url.scheme == "bahasa", url.host == "talk" {
            id = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        } else if url.scheme == "https", url.host == "learnbahasa.app" || url.host == "www.learnbahasa.app",
                  url.pathComponents.count >= 3, url.pathComponents[1] == "talk" {
            id = url.pathComponents[2]
        } else {
            return
        }
        guard SceneLibrary.resolve(id) != nil else { return }
        scenarioID = id
    }
}

struct RootView: View {
    @StateObject private var events = EventRouter()
    @State private var tab: AppTab = LaunchArgs.tab ?? .learn
    @AppStorage("bahasa.onboarded") private var onboarded = false
    @State private var showSplash = !LaunchArgs.skipIntro
    @State private var paywall: PaywallContext? = LaunchArgs.paywall ? .general : nil

    /// Screenshot runs (any -tab/-scene/-lesson launch arg) skip the intro unless -onboarding is set.
    private var needsOnboarding: Bool {
        LaunchArgs.forceOnboarding || (!onboarded && !LaunchArgs.skipIntro)
    }

    var body: some View {
        ZStack {
            if needsOnboarding {
                OnboardingView { startChat in
                    withAnimation(.easeInOut(duration: 0.45)) {
                        onboarded = true
                        LaunchArgs.forceOnboarding = false
                    }
                    if startChat {
                        tab = .talk
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            events.scenarioID = SceneLibrary.scenes.first?.id
                        }
                    }
                }
                .transition(.opacity)
            } else {
                tabs
                    .transition(.opacity)
            }

            if showSplash {
                SplashView {
                    withAnimation(.easeOut(duration: 0.45)) { showSplash = false }
                }
                .transition(.opacity.combined(with: .scale(scale: 1.04)))
                .zIndex(10)
            }
        }
        .environmentObject(events)
        .paywall($paywall)
    }

    private var tabs: some View {
        TabView(selection: $tab) {
            LearnView()
                .tabItem { Label(AppTab.learn.title, systemImage: AppTab.learn.symbol) }
                .tag(AppTab.learn)
            TalkView()
                .tabItem { Label(AppTab.talk.title, systemImage: AppTab.talk.symbol) }
                .tag(AppTab.talk)
            PatternsView()
                .tabItem { Label(AppTab.patterns.title, systemImage: AppTab.patterns.symbol) }
                .tag(AppTab.patterns)
            PhrasesView()
                .tabItem { Label(AppTab.phrases.title, systemImage: AppTab.phrases.symbol) }
                .tag(AppTab.phrases)
        }
        .tint(Theme.sambal)
        .onOpenURL { url in
            events.open(url)
            if events.scenarioID != nil { tab = .talk }
        }
        .onChange(of: events.scenarioID) { _, id in
            if id != nil { tab = .talk }
        }
    }
}
