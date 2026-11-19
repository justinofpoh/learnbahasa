import SwiftUI

/// XP, streak and completion, persisted as Codable JSON in UserDefaults.
final class ProgressStore: ObservableObject {
    static let dailyGoal = 30
    private static let key = "bahasa.progress.v1"

    struct State: Codable {
        var lessonsDone: Set<String> = []
        var scenariosDone: Set<String> = []
        var xp: Int = 0
        var todayXP: Int = 0
        var streak: Int = 0
        var lastActiveDay: String = ""
    }

    @Published private(set) var state: State
    /// Rehearsal Learning progress (Scenes, Your Lines, Recall). Stored under its own key.
    @Published var rehearsal: RehearsalState

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static var today: String { dayFormatter.string(from: Date()) }

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.key),
           let decoded = try? JSONDecoder().decode(State.self, from: data) {
            state = decoded
        } else {
            state = State()
        }
        rehearsal = LaunchArgs.resetRehearsal ? RehearsalState() : RehearsalState.load()
        rolloverDayIfNeeded()
    }

    // MARK: Derived

    var xp: Int { state.xp }
    var todayXP: Int { state.todayXP }
    var streak: Int { state.streak }
    var lessonsDone: Int { state.lessonsDone.count }
    var scenariosDone: Int { state.scenariosDone.count }
    var goalFraction: Double { min(1, Double(state.todayXP) / Double(Self.dailyGoal)) }

    func isDone(lesson id: String) -> Bool { state.lessonsDone.contains(id) }
    func isDone(scenario id: String) -> Bool { state.scenariosDone.contains(id) }

    /// First lesson not yet completed, scanning units in order. Starts at the learner's placement
    /// (from onboarding), then comes back for anything earlier they skipped.
    var nextLesson: (unit: Unit, lesson: Lesson)? {
        let start = LearnerLevel(rawValue: rehearsal.profile.level)?.startUnit ?? 1
        let later: [Unit] = Curriculum.units.filter { $0.number >= start }
        let earlier: [Unit] = Curriculum.units.filter { $0.number < start }
        let ordered: [Unit] = later + earlier
        for unit in ordered {
            for lesson in unit.lessons where !isDone(lesson: lesson.id) {
                return (unit, lesson)
            }
        }
        return nil
    }

    // MARK: Mutation

    func complete(lesson id: String, xp: Int) {
        state.lessonsDone.insert(id)
        award(xp)
    }

    func complete(scenario id: String, xp: Int) {
        state.scenariosDone.insert(id)
        award(xp)
    }

    func award(_ amount: Int) {
        rolloverDayIfNeeded()
        state.xp += amount
        state.todayXP += amount
        bumpStreak()
        save()
    }

    /// Same day: no change. Yesterday: +1. Anything else: back to 1.
    private func bumpStreak() {
        let today = Self.today
        guard state.lastActiveDay != today else { return }
        if let last = Self.dayFormatter.date(from: state.lastActiveDay),
           let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()),
           Self.dayFormatter.string(from: last) == Self.dayFormatter.string(from: yesterday) {
            state.streak += 1
        } else {
            state.streak = 1
        }
        state.lastActiveDay = today
    }

    private func rolloverDayIfNeeded() {
        if state.lastActiveDay != Self.today, state.todayXP != 0 {
            state.todayXP = 0
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    // MARK: Account sync

    /// Replaces local progress with a merged copy from the account (see `SyncMerge`). Only grows progress.
    func adopt(_ merged: (State, RehearsalState)) {
        state = merged.0
        save()
        rehearsal = merged.1
        rehearsal.save()
    }

    func reset() {
        state = State()
        save()
        rehearsal = RehearsalState()
        rehearsal.save()
    }
}
