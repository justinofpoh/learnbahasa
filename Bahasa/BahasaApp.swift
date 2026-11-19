import SwiftUI
import UIKit

@main
struct BahasaApp: App {
    @StateObject private var progress = ProgressStore()
    @StateObject private var purchases = PurchaseManager()
    @StateObject private var account = AccountManager()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        Appearance.apply()
        #if DEBUG
        let lessonProblems = LessonValidator.validateAll()
        if !lessonProblems.isEmpty {
            print("LESSON PROBLEMS:\n" + lessonProblems.joined(separator: "\n"))
            assertionFailure("Lesson content problems:\n" + lessonProblems.joined(separator: "\n"))
        }
        let problems = SceneValidator.validateAll()
        if !problems.isEmpty {
            assertionFailure("Scene content problems:\n" + problems.joined(separator: "\n"))
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(progress)
                .environmentObject(purchases)
                .environmentObject(account)
                .tint(Theme.sambal)
                .task {
                    purchases.start()
                    account.start(progress: progress)
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { Task { await account.sync() } }
                }
        }
    }
}

/// Serif navigation titles and a paper-coloured chrome.
enum Appearance {
    static func apply() {
        let ink = UIColor(Theme.ink)
        let paper = UIColor(Theme.paper)

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = paper
        nav.shadowColor = .clear
        nav.largeTitleTextAttributes = [
            .font: roundedFont(size: 34, weight: .bold),
            .foregroundColor: ink
        ]
        nav.titleTextAttributes = [
            .font: roundedFont(size: 17, weight: .semibold),
            .foregroundColor: ink
        ]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav

        let tabBar = UITabBarAppearance()
        tabBar.configureWithOpaqueBackground()
        tabBar.backgroundColor = UIColor(Theme.card)
        tabBar.shadowColor = UIColor(Theme.line)
        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar
    }

    private static func roundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
        return UIFont(descriptor: descriptor, size: size)
    }
}
