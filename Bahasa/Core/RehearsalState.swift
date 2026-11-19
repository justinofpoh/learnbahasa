import Foundation

/// Persisted Rehearsal Learning progress: per-Scene marks, Your Lines, the Recall queue
/// and the learner profile used for slots.
struct RehearsalState: Codable {
    private static let key = "bahasa.rehearsal.v1"

    struct SceneRecord: Codable {
        var watched = false
        var stars = 0                       // 1 Rehearse · 2 Perform ≤2 assists · 3 clean Perform
        var performPassed = false
        var clearedMoods: Set<Mood> = []
        var liveIssuedAt: Date?
        var lived = false
        var checkins: [LiveCheckin] = []
        var rehearsals = 0

        init() {}

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            watched = (try? c.decodeIfPresent(Bool.self, forKey: .watched)) ?? false
            stars = (try? c.decodeIfPresent(Int.self, forKey: .stars)) ?? 0
            performPassed = (try? c.decodeIfPresent(Bool.self, forKey: .performPassed)) ?? false
            clearedMoods = (try? c.decodeIfPresent(Set<Mood>.self, forKey: .clearedMoods)) ?? []
            liveIssuedAt = try? c.decodeIfPresent(Date.self, forKey: .liveIssuedAt)
            lived = (try? c.decodeIfPresent(Bool.self, forKey: .lived)) ?? false
            checkins = (try? c.decodeIfPresent([LiveCheckin].self, forKey: .checkins)) ?? []
            rehearsals = (try? c.decodeIfPresent(Int.self, forKey: .rehearsals)) ?? 0
        }

        private enum CodingKeys: String, CodingKey {
            case watched, stars, performPassed, clearedMoods, liveIssuedAt, lived, checkins, rehearsals
        }
    }

    struct LiveCheckin: Codable, Identifiable {
        var id = UUID()
        var date: Date
        var outcome: LiveOutcome
        var reason: HardReason?
    }

    struct OwnedLine: Codable, Identifiable, Hashable {
        var id: String { sceneID + "|" + text }
        let sceneID: String
        let nodeID: String
        let text: String
        let gloss: String
        var addedAt: Date
        var timesSaid: Int
    }

    struct RecallItem: Codable, Identifiable {
        var id: String { sceneID + "|" + nodeID }
        let sceneID: String
        let nodeID: String
        var step: Int                       // index into RecallState.intervals
        var due: Date
        var reason: String                  // "missed", "assist", "sample", "live"
    }

    static let intervals = [1, 3, 7, 21, 60]   // days

    var profile = LearnerProfile()
    var scenes: [String: SceneRecord] = [:]
    var lines: [OwnedLine] = []
    var recall: [RecallItem] = []

    init() {}

    // Missing keys fall back to defaults, so adding fields later never wipes a learner's progress.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        profile = (try? c.decodeIfPresent(LearnerProfile.self, forKey: .profile)) ?? LearnerProfile()
        scenes = (try? c.decodeIfPresent([String: SceneRecord].self, forKey: .scenes)) ?? [:]
        lines = (try? c.decodeIfPresent([OwnedLine].self, forKey: .lines)) ?? []
        recall = ((try? c.decodeIfPresent([RecallItem].self, forKey: .recall)) ?? [])
            .filter { item in SceneLibrary.scene(item.sceneID)?.node(item.nodeID) != nil }
    }

    private enum CodingKeys: String, CodingKey { case profile, scenes, lines, recall }

    // MARK: Persistence

    static func load() -> RehearsalState {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode(RehearsalState.self, from: data) else {
            return RehearsalState()
        }
        return decoded
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    // MARK: Queries

    func record(_ sceneID: String) -> SceneRecord { scenes[sceneID] ?? SceneRecord() }

    func lines(for sceneID: String) -> [OwnedLine] {
        lines.filter { $0.sceneID == sceneID }
    }

    func due(on date: Date = Date()) -> [RecallItem] {
        recall.filter { $0.due <= date }.sorted { $0.due < $1.due }
    }

    func recallItems(for sceneID: String) -> [RecallItem] {
        recall.filter { $0.sceneID == sceneID }.sorted { $0.due < $1.due }
    }

    func isUnlocked(_ stage: Stage, scene: String) -> Bool {
        let r = record(scene)
        switch stage {
        case .watch: return true
        case .rehearse: return r.watched || r.stars >= 1
        case .perform: return r.stars >= 1 || r.performPassed
        case .live: return r.performPassed
        case .recall: return !recallItems(for: scene).isEmpty
        }
    }

    /// Scenes with a Live card out and no check-in yet, issued at least `after` seconds ago.
    func pendingCheckins(after seconds: TimeInterval = 60 * 60 * 3) -> [String] {
        scenes.compactMap { id, r in
            guard let issued = r.liveIssuedAt, r.checkins.isEmpty,
                  Date().timeIntervalSince(issued) >= seconds else { return nil }
            return id
        }
    }

    // MARK: Mutation

    mutating func update(_ sceneID: String, _ change: (inout SceneRecord) -> Void) {
        var r = record(sceneID)
        change(&r)
        scenes[sceneID] = r
    }

    mutating func own(sceneID: String, nodeID: String, text: String, gloss: String) {
        if let i = lines.firstIndex(where: { $0.sceneID == sceneID && $0.text == text }) {
            lines[i].timesSaid += 1
        } else {
            lines.insert(OwnedLine(sceneID: sceneID, nodeID: nodeID, text: text, gloss: gloss, addedAt: Date(), timesSaid: 1), at: 0)
        }
    }

    /// Queue a line for Recall. An existing item keeps the earlier due date.
    mutating func enqueue(sceneID: String, nodeID: String, reason: String, inDays days: Int = 1) {
        let due = Calendar.current.date(byAdding: .day, value: days, to: Calendar.current.startOfDay(for: Date())) ?? Date()
        if let i = recall.firstIndex(where: { $0.sceneID == sceneID && $0.nodeID == nodeID }) {
            if reason != "sample" {
                recall[i].due = min(recall[i].due, due)
                recall[i].reason = reason
                recall[i].step = 0
            }
        } else {
            recall.append(RecallItem(sceneID: sceneID, nodeID: nodeID, step: 0, due: due, reason: reason))
        }
    }

    /// 1 → 3 → 7 → 21 → 60 days. A miss steps back one, not to the start (spec §5.5).
    mutating func review(_ itemID: String, correct: Bool) {
        guard let i = recall.firstIndex(where: { $0.id == itemID }) else { return }
        var step = recall[i].step
        step = correct ? step + 1 : max(0, step - 1)
        if step >= Self.intervals.count {
            recall.remove(at: i)   // graduated
            return
        }
        recall[i].step = step
        let days = correct ? Self.intervals[step] : 1
        recall[i].due = Calendar.current.date(byAdding: .day, value: days, to: Calendar.current.startOfDay(for: Date())) ?? Date()
    }
}

enum LiveOutcome: String, Codable, CaseIterable {
    case worked, hard, notYet

    var label: String {
        switch self {
        case .worked: return "Yes, it worked"
        case .hard: return "Yes, but it was hard"
        case .notYet: return "Not yet"
        }
    }

    var symbol: String {
        switch self {
        case .worked: return "hand.thumbsup.fill"
        case .hard: return "figure.climbing"
        case .notYet: return "clock"
        }
    }
}

enum HardReason: String, Codable, CaseIterable {
    case understanding, remembering, unknownWords, nerves

    var label: String {
        switch self {
        case .understanding: return "Understanding them"
        case .remembering: return "Remembering what to say"
        case .unknownWords: return "They used words I didn't know"
        case .nerves: return "Nerves"
        }
    }

    var advice: String {
        switch self {
        case .understanding: return "Watch again with text off, and try Perform: she speaks casually there."
        case .remembering: return "Your key lines are now in Recall, so they'll come back tomorrow."
        case .unknownWords: return "Real speech goes off-script. Perform varies her mood and wording, so it's good practice for surprises."
        case .nerves: return "Totally normal. Keep the Live card open on your phone. Even reading from it counts."
        }
    }
}

// MARK: - Store helpers

extension ProgressStore {
    func mutateRehearsal(_ change: (inout RehearsalState) -> Void) {
        change(&rehearsal)
        rehearsal.save()
    }

    var profile: LearnerProfile { rehearsal.profile }

    var filler: SlotFiller { SlotFiller(profile: rehearsal.profile, pack: SceneLibrary.pack) }

    var livedCount: Int { rehearsal.scenes.values.filter(\.lived).count }
    var ownedLineCount: Int { rehearsal.lines.count }
}
