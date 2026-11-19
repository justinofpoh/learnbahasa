import SwiftUI
import UIKit
import WidgetKit

// Home-screen and Lock Screen widgets for Learn Bahasa: the streak, today's goal, and the neighbour
// who is waiting for a chat. The app writes a snapshot to the shared app group (Core/WidgetBridge.swift).

private let appGroup = "group.com.justinpoh.bahasa"
private let snapshotKey = "bahasa.widget.snapshot"

/// Keep in step with `WidgetBridge.Snapshot` in the app.
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

    static let sample = Snapshot(streak: 4, todayXP: 20, goal: 30, lastActiveDay: "", lessonTitle: "Ordering food",
                                 lessonUnit: "Unit 8 · Makan", neighbourName: "Ibu Wayan", neighbourPlace: "Warung",
                                 neighbourLine: "Mau makan apa?", sceneID: "id.warung.lunch", tintHex: "#D4512A",
                                 portraitFile: nil, updated: Date())

    static func load() -> Snapshot? {
        guard let data = UserDefaults(suiteName: appGroup)?.data(forKey: snapshotKey) else { return nil }
        return try? JSONDecoder().decode(Snapshot.self, from: data)
    }
}

// MARK: - Palette (same as the app's Theme)

private enum Ink {
    static let paper = Color(hex: "#F6F1E8")
    static let card = Color(hex: "#FFFCF6")
    static let ink = Color(hex: "#1D1A16")
    static let soft = Color(hex: "#6B645A")
    static let line = Color(hex: "#E6DDCD")
    static let sambal = Color(hex: "#D4512A")
    static let kunyit = Color(hex: "#E3A126")
    static let sawah = Color(hex: "#2E7D5B")
}

extension Color {
    init(hex: String) {
        let v = UInt64(hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")), radix: 16) ?? 0
        self.init(red: Double((v >> 16) & 0xFF) / 255, green: Double((v >> 8) & 0xFF) / 255, blue: Double(v & 0xFF) / 255)
    }
}

private extension Font {
    static func r(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Timeline

struct Entry: TimelineEntry {
    let date: Date
    let snap: Snapshot

    private static let day: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// Practised today?
    var doneToday: Bool { snap.lastActiveDay == Self.day.string(from: date) }
    /// The streak still counts if they practised today or yesterday.
    var streak: Int {
        if doneToday { return snap.streak }
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        return snap.lastActiveDay == Self.day.string(from: yesterday) ? snap.streak : 0
    }
    var todayXP: Int { doneToday ? snap.todayXP : 0 }
    var goalFraction: Double { min(1, Double(todayXP) / Double(max(1, snap.goal))) }
    var goalMet: Bool { todayXP >= snap.goal }
    var evening: Bool { Calendar.current.component(.hour, from: date) >= 17 }

    var headline: String {
        if goalMet { return "Selesai! Sampai besok." }
        if streak > 0 && !doneToday { return evening ? "Keep your streak tonight" : "Your streak is waiting" }
        return "\(snap.neighbourName) is waiting"
    }

    var link: URL { URL(string: "bahasa://talk/\(snap.sceneID)")! }

    var portrait: UIImage? {
        guard let name = snap.portraitFile,
              let dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else { return nil }
        return UIImage(contentsOfFile: dir.appendingPathComponent(name).path)
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry { Entry(date: Date(), snap: .sample) }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        completion(Entry(date: Date(), snap: Snapshot.load() ?? .sample))
    }

    /// Now, early evening (the nudge gets warmer) and midnight (the day resets).
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let snap = Snapshot.load() ?? .sample
        let cal = Calendar.current
        let now = Date()
        var dates = [now]
        if let evening = cal.date(bySettingHour: 17, minute: 0, second: 0, of: now), evening > now { dates.append(evening) }
        let midnight = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: now) ?? now)
        dates.append(midnight)
        if let nextEvening = cal.date(bySettingHour: 17, minute: 0, second: 0, of: midnight) { dates.append(nextEvening) }
        completion(Timeline(entries: dates.map { Entry(date: $0, snap: snap) }, policy: .after(midnight)))
    }
}

// MARK: - Pieces

private struct Portrait: View {
    let entry: Entry
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle().fill(Color(hex: entry.snap.tintHex).opacity(0.16))
            if let image = entry.portrait {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                Text(String(entry.snap.neighbourName.split(separator: " ").last?.prefix(1) ?? "B"))
                    .font(.r(size * 0.4, .heavy))
                    .foregroundStyle(Color(hex: entry.snap.tintHex))
            }
        }
        .frame(width: size, height: size)
    }
}

private struct StreakFlame: View {
    let entry: Entry
    var big = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.system(size: big ? 20 : 13, weight: .bold))
                .foregroundStyle(entry.streak > 0 ? Ink.sambal : Ink.soft.opacity(0.5))
            Text("\(entry.streak)")
                .font(.r(big ? 30 : 15, .heavy))
                .foregroundStyle(Ink.ink)
                .contentTransition(.numericText())
        }
    }
}

private struct GoalBar: View {
    let entry: Entry

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Ink.line)
                Capsule().fill(entry.goalMet ? Ink.sawah : Ink.kunyit)
                    .frame(width: max(8, geo.size.width * entry.goalFraction))
            }
        }
        .frame(height: 8)
    }
}

/// A faint kawung field, like the app's hero cards.
private struct Kawung: View {
    var body: some View {
        Canvas { ctx, size in
            let step: CGFloat = 22
            var y: CGFloat = 0
            while y < size.height + step {
                var x: CGFloat = 0
                while x < size.width + step {
                    for angle in stride(from: 0.0, to: 360.0, by: 90.0) {
                        let r = angle * .pi / 180
                        let cx = x + cos(r) * 5.5, cy = y + sin(r) * 5.5
                        var petal = Path(ellipseIn: CGRect(x: -5.5, y: -3, width: 11, height: 6))
                        petal = petal.applying(CGAffineTransform(rotationAngle: r)).applying(CGAffineTransform(translationX: cx, y: cy))
                        ctx.stroke(petal, with: .color(.white.opacity(0.18)), lineWidth: 1)
                    }
                    x += step
                }
                y += step
            }
        }
    }
}

// MARK: - Views

struct SmallView: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Portrait(entry: entry, size: 50)
                Spacer()
                StreakFlame(entry: entry)
            }
            Spacer(minLength: 6)
            Text(entry.goalMet ? "Done today" : entry.snap.neighbourName)
                .font(.r(15, .heavy))
                .foregroundStyle(Ink.ink)
                .lineLimit(1)
            Text(entry.goalMet ? "Sampai besok!" : "“\(entry.snap.neighbourLine)”")
                .font(.r(12, .medium))
                .foregroundStyle(Ink.soft)
                .lineLimit(2)
            Spacer(minLength: 8)
            GoalBar(entry: entry)
        }
        .widgetURL(entry.link)
    }
}

struct MediumView: View {
    let entry: Entry

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(hex: entry.snap.tintHex))
                Kawung().clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                VStack(spacing: 4) {
                    Portrait(entry: entry, size: 70)
                        .background(Circle().fill(Ink.card))
                    Text(entry.snap.neighbourPlace)
                        .font(.r(12, .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
            }
            .frame(width: 112)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.headline)
                        .font(.r(15, .heavy))
                        .foregroundStyle(Ink.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    Spacer(minLength: 4)
                    StreakFlame(entry: entry)
                }
                Text("“\(entry.snap.neighbourLine)”")
                    .font(.r(13, .semibold))
                    .foregroundStyle(Color(hex: entry.snap.tintHex))
                    .lineLimit(1)
                if let lesson = entry.snap.lessonTitle {
                    Text("Next: \(lesson)")
                        .font(.r(12, .medium))
                        .foregroundStyle(Ink.soft)
                        .lineLimit(1)
                }
                Spacer(minLength: 4)
                HStack(spacing: 8) {
                    GoalBar(entry: entry)
                    Text(entry.goalMet ? "Goal met" : "\(entry.todayXP)/\(entry.snap.goal) XP")
                        .font(.r(11, .bold))
                        .foregroundStyle(entry.goalMet ? Ink.sawah : Ink.soft)
                        .fixedSize()
                }
                Text(entry.goalMet ? "Bagus! See you tomorrow." : "5 minutes keeps it warm")
                    .font(.r(11, .medium))
                    .foregroundStyle(Ink.soft)
            }
        }
        .widgetURL(entry.link)
    }
}

struct CircularView: View {
    let entry: Entry

    var body: some View {
        Gauge(value: entry.goalFraction) {
            Image(systemName: "flame.fill")
        } currentValueLabel: {
            Text("\(entry.streak)").font(.r(16, .heavy))
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .widgetURL(entry.link)
    }
}

struct RectangularView: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Label("\(entry.streak)-day streak", systemImage: "flame.fill")
                .font(.r(14, .heavy))
            Text(entry.goalMet ? "Done for today" : "\(entry.snap.neighbourName): “\(entry.snap.neighbourLine)”")
                .font(.r(12, .medium))
                .lineLimit(2)
        }
        .widgetURL(entry.link)
    }
}

struct InlineView: View {
    let entry: Entry
    var body: some View {
        Label(entry.goalMet ? "\(entry.streak) days · done today" : "\(entry.streak) days · 5 min today?", systemImage: "flame.fill")
    }
}

struct WidgetRoot: View {
    @Environment(\.widgetFamily) private var family
    let entry: Entry

    var body: some View {
        switch family {
        case .accessoryCircular: CircularView(entry: entry)
        case .accessoryRectangular: RectangularView(entry: entry)
        case .accessoryInline: InlineView(entry: entry)
        case .systemMedium: MediumView(entry: entry)
        default: SmallView(entry: entry)
        }
    }
}

struct DailyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "BahasaDaily", provider: Provider()) { entry in
            WidgetRoot(entry: entry)
                .containerBackground(for: .widget) { Ink.card }
        }
        .configurationDisplayName("Daily Bahasa")
        .description("Your streak, today's goal and the neighbour who is waiting.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

@main
struct BahasaWidgetsBundle: WidgetBundle {
    var body: some Widget {
        DailyWidget()
    }
}
