import SwiftUI
import WidgetKit

/// Hands the home-screen widgets what they show: streak, today's goal, the next lesson and the
/// neighbour who is waiting (with a pre-drawn portrait, since the widget can't run the drawing code).
/// Written to the shared app group; the widget extension (BahasaWidgets/) reads the same JSON.
enum WidgetBridge {
    static let appGroup = "group.com.justinpoh.bahasa"
    static let snapshotKey = "bahasa.widget.snapshot"

    /// Keep in step with `Snapshot` in BahasaWidgets/BahasaWidgets.swift.
    struct Snapshot: Codable {
        var streak: Int
        var todayXP: Int
        var goal: Int
        var lastActiveDay: String
        var lessonTitle: String?
        var lessonUnit: String?
        var neighbourName: String
        var neighbourPlace: String
        var neighbourLine: String
        var sceneID: String
        var tintHex: String
        var portraitFile: String?
        var updated: Date
    }

    @MainActor
    static func update(progress: ProgressStore, plan: Plan) {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }
        let scene = waitingScene(progress: progress, plan: plan)
        let portrait = scene.flatMap { renderPortrait($0) }
        let snapshot = Snapshot(
            streak: progress.streak,
            todayXP: progress.todayXP,
            goal: ProgressStore.dailyGoal,
            lastActiveDay: progress.state.lastActiveDay,
            lessonTitle: progress.nextLesson?.lesson.title,
            lessonUnit: progress.nextLesson.map { "Unit \($0.unit.number) · \($0.unit.title)" },
            neighbourName: scene?.character.name ?? "Ibu Wayan",
            neighbourPlace: scene?.place ?? "Warung",
            neighbourLine: scene.map { progress.filler.fill($0.node($0.entry)?.them.text ?? "Halo!") } ?? "Mau makan apa?",
            sceneID: scene?.id ?? "id.warung.lunch",
            tintHex: scene?.color.hexString ?? "#D4512A",
            portraitFile: portrait,
            updated: Date())
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Someone they haven't met yet, else whoever has practice due, else the warung.
    private static func waitingScene(progress: ProgressStore, plan: Plan) -> RehearsalScene? {
        let open = SceneLibrary.scenes.filter { Access.scene($0.id, plan: plan) }
        if let fresh = open.first(where: { progress.rehearsal.record($0.id).stars == 0 }) { return fresh }
        if let due = progress.rehearsal.due().first?.sceneID, let scene = SceneLibrary.scene(due) { return scene }
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        return open.isEmpty ? SceneLibrary.scenes.first : open[day % open.count]
    }

    @MainActor
    private static func renderPortrait(_ scene: RehearsalScene) -> String? {
        guard let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else { return nil }
        let name = "portrait-\(scene.character.id).png"
        let url = dir.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: url.path) { return name }
        let renderer = ImageRenderer(content:
            CharacterPortrait(characterID: scene.character.id, tint: scene.color, size: 120,
                              expression: .happy, animated: false)
                .frame(width: 120, height: 120))
        renderer.scale = 3
        guard let png = renderer.uiImage?.pngData() else { return nil }
        try? png.write(to: url, options: .atomic)
        return name
    }
}

private extension Color {
    var hexString: String {
        let c = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        c.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
