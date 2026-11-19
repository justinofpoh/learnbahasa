import SwiftUI

// Rehearsal Learning data model (docs/rehearsal-learning-spec.md §8).
// Language-agnostic: nothing here knows about Indonesian except via LanguagePack.

// MARK: - Stages and grades

enum Stage: String, Codable, CaseIterable, Identifiable {
    case watch, rehearse, perform, live, recall

    var id: String { rawValue }

    var title: String {
        switch self {
        case .watch: return "Watch"
        case .rehearse: return "Rehearse"
        case .perform: return "Perform"
        case .live: return "Live"
        case .recall: return "Recall"
        }
    }

    var tagline: String {
        switch self {
        case .watch: return "See it happen. Ears first."
        case .rehearse: return "Guided replies: choose, then build."
        case .perform: return "Your words. Type or say them."
        case .live: return "Do it for real, then check in."
        case .recall: return "Missed lines come back."
        }
    }

    var symbol: String {
        switch self {
        case .watch: return "eye.fill"
        case .rehearse: return "theatermasks.fill"
        case .perform: return "mic.fill"
        case .live: return "sparkles"
        case .recall: return "arrow.triangle.2.circlepath"
        }
    }
}

enum Grade: String, Codable {
    case natural, understood, missed, off

    var passes: Bool { self == .natural || self == .understood }

    var label: String {
        switch self {
        case .natural: return "Natural"
        case .understood: return "Understood"
        case .missed: return "Missed"
        case .off: return "Off"
        }
    }

    var color: Color {
        switch self {
        case .natural: return Theme.benar
        case .understood: return Theme.kunyit
        case .missed: return Theme.salah
        case .off: return Theme.jambu
        }
    }
}

enum Mood: String, Codable, CaseIterable {
    case warm, busy, chatty, tired

    /// How the mood is hinted in the header, in the target language with English.
    var cue: String {
        switch self {
        case .warm: return "ramah · friendly today"
        case .busy: return "sibuk · busy today"
        case .chatty: return "suka ngobrol · chatty"
        case .tired: return "capek · tired"
        }
    }
}

enum Register: String, Codable {
    case formal, neutral, casual
}

enum SceneLevel: String, Codable {
    case survive, getBy, connect

    var label: String {
        switch self {
        case .survive: return "Survive"
        case .getBy: return "Get by"
        case .connect: return "Connect"
        }
    }
}

// MARK: - Lines

/// One utterance. `chips` is role-tagged ("Mau/H makan/V apa/Q") for the ? view.
struct Utterance {
    var text: String
    var casual: String? = nil
    var gloss: String
    var chips: String? = nil

    init(_ text: String, casual: String? = nil, gloss: String, chips: String? = nil) {
        self.text = text
        self.casual = casual
        self.gloss = gloss
        self.chips = chips
    }
}

struct ReplyOption: Identifiable {
    let id = UUID()
    var text: String
    var gloss: String
    var grade: Grade
    var accept: [String] = []
    var sets: [String] = []
    var next: String? = nil
    /// A different next node for some moods (e.g. a busy owner skips small talk).
    var moodNext: [Mood: String] = [:]
    var reaction: Utterance? = nil
    var coach: String? = nil
    var chips: String? = nil

    func nextNode(for mood: Mood) -> String? { moodNext[mood] ?? next }

    // Terse builders for content files.

    static func natural(_ text: String, _ gloss: String, accept: [String] = [], sets: [String] = [], next: String?, moodNext: [Mood: String] = [:], chips: String? = nil) -> ReplyOption {
        ReplyOption(text: text, gloss: gloss, grade: .natural, accept: accept, sets: sets, next: next, moodNext: moodNext, chips: chips)
    }

    static func understood(_ text: String, _ gloss: String, accept: [String] = [], sets: [String] = [], next: String?, moodNext: [Mood: String] = [:], coach: String) -> ReplyOption {
        ReplyOption(text: text, gloss: gloss, grade: .understood, accept: accept, sets: sets, next: next, moodNext: moodNext, coach: coach)
    }

    static func missed(_ text: String, _ gloss: String, reaction: Utterance, coach: String) -> ReplyOption {
        ReplyOption(text: text, gloss: gloss, grade: .missed, reaction: reaction, coach: coach)
    }

    static func off(_ text: String, _ gloss: String, reaction: Utterance, coach: String) -> ReplyOption {
        ReplyOption(text: text, gloss: gloss, grade: .off, reaction: reaction, coach: coach)
    }
}

struct SceneNode: Identifiable {
    let id: String
    var narration: String? = nil
    var them: Utterance
    var variants: [Mood: Utterance] = [:]
    /// Pattern the node drills; forces Build in Rehearse.
    var focus: String? = nil
    var extras: [String] = []
    var replies: [ReplyOption] = []

    var isEnd: Bool { replies.isEmpty }
    var naturals: [ReplyOption] { replies.filter { $0.grade == .natural } }
    var passing: [ReplyOption] { replies.filter { $0.grade.passes } }

    func line(for mood: Mood, casual: Bool) -> Utterance {
        if let v = variants[mood] { return v }
        if casual, let c = them.casual {
            var u = them
            u.text = c
            return u
        }
        return them
    }
}

struct Character {
    let id: String
    let name: String
    let role: String
    let register: Register
    let addressAs: [String]
    let moods: [Mood]
    let defaultMood: Mood
    /// What they say when they didn't understand at all (Perform, unmatched input).
    let confused: [Utterance]
}

struct GoalFlag: Identifiable {
    let id: String
    let label: String
    var optional: Bool = false
}

struct ListeningCheck: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let answer: String
}

struct WarmUp {
    let title: String
    let lessonID: String
}

struct RehearsalScene: Identifiable {
    let id: String              // <lang>.<place>.<slug>
    let language: String
    let place: String
    let title: String           // target language
    let titleEn: String
    let setting: String
    let level: SceneLevel
    let accent: Accent
    let symbol: String
    let character: Character
    let goalSummary: String
    let goals: [GoalFlag]
    let warmUps: [WarmUp]
    let culture: [String]
    let slots: [Slot]
    let entry: String
    let nodes: [SceneNode]
    let listening: [ListeningCheck]

    var color: Color { accent.color }

    func node(_ id: String) -> SceneNode? { nodes.first { $0.id == id } }

    var requiredGoals: [GoalFlag] { goals.filter { !$0.optional } }
}

// MARK: - Personal slots (§8.2)

enum Slot: String, Codable, CaseIterable {
    case name, country, city, job

    var token: String { "{\(rawValue)}" }
}

struct LearnerProfile: Codable, Equatable {
    var name: String = ""
    var country: String = ""
    var city: String = ""
    var job: String = ""
    /// Profile look, an id from `Cast.avatars`.
    var avatar: String = ""
    /// Starting level from onboarding: 0 brand new · 1 a few words · 2 can get by · 3 can chat. -1 = not asked yet.
    var level: Int = -1

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = (try? c.decodeIfPresent(String.self, forKey: .name)) ?? ""
        country = (try? c.decodeIfPresent(String.self, forKey: .country)) ?? ""
        city = (try? c.decodeIfPresent(String.self, forKey: .city)) ?? ""
        job = (try? c.decodeIfPresent(String.self, forKey: .job)) ?? ""
        avatar = (try? c.decodeIfPresent(String.self, forKey: .avatar)) ?? ""
        level = (try? c.decodeIfPresent(Int.self, forKey: .level)) ?? -1
    }

    private enum CodingKeys: String, CodingKey { case name, country, city, job, avatar, level }

    func value(_ slot: Slot) -> String {
        switch slot {
        case .name: return name
        case .country: return country
        case .city: return city
        case .job: return job
        }
    }
}

/// Fills `{slot}` tokens with the learner's values, or pack fallbacks.
struct SlotFiller {
    let profile: LearnerProfile
    let pack: LanguagePack

    func fill(_ text: String) -> String {
        var out = text
        for slot in Slot.allCases where out.contains(slot.token) {
            let value = profile.value(slot)
            out = out.replacingOccurrences(of: slot.token, with: value.isEmpty ? pack.slotFallback(slot) : value)
        }
        return out
    }

    /// Every way a slotted line could be said: the learner's value plus all pack forms.
    func expansions(_ text: String) -> [String] {
        guard let slot = Slot.allCases.first(where: { text.contains($0.token) }) else { return [text] }
        var values = pack.slotForms(slot)
        let own = profile.value(slot)
        if !own.isEmpty { values.insert(own, at: 0) }
        if values.isEmpty { values = [pack.slotFallback(slot)] }
        // Expand the first slot over every known form; fill any others with the learner's values.
        return values.map { fill(text.replacingOccurrences(of: slot.token, with: $0)) }
    }
}

// MARK: - Language Pack (§10)

struct LanguagePack {
    let code: String
    let name: String
    let voice: String
    /// Interchangeable forms, folded onto the first item when matching.
    let casualEquivalents: [[String]]
    /// Multi-word forms folded into one token before matching.
    let phraseEquivalents: [(from: String, to: String)]
    /// Softeners and address words: cheap to add or drop when matching.
    let particles: Set<String>
    let countries: [(en: String, local: String)]
    let fallbacks: [Slot: String]

    func slotForms(_ slot: Slot) -> [String] {
        slot == .country ? countries.map(\.local) : []
    }

    func slotFallback(_ slot: Slot) -> String {
        fallbacks[slot] ?? ""
    }
}

extension LanguagePack {
    static let indonesian = LanguagePack(
        code: "id",
        name: "Bahasa Indonesia",
        voice: "id-ID",
        casualEquivalents: [
            ["tidak", "gak", "nggak", "ngga", "enggak", "ga", "tak"],
            ["sudah", "udah", "dah"],
            ["saja", "aja"],
            ["iya", "ya", "yah"],
            ["bu", "ibu"],
            ["pak", "bapak"],
            ["mau", "mo"],
            ["bagaimana", "gimana"],
            ["sedikit", "dikit"],
            ["terimakasih", "makasih", "makasi", "trims", "thanks"]
        ],
        phraseEquivalents: [
            ("terima kasih", "terimakasih"),
            ("disini", "di sini"),
            ("disitu", "di situ"),
            ("apa apa", "apaapa")
        ],
        particles: ["bu", "pak", "iya", "deh", "dong", "kak", "mas", "mbak", "mbok", "bli", "nih", "sih", "kok"],
        countries: [
            ("Australia", "Australia"), ("Canada", "Kanada"), ("United States", "Amerika"),
            ("United Kingdom", "Inggris"), ("Germany", "Jerman"), ("Netherlands", "Belanda"),
            ("France", "Prancis"), ("New Zealand", "Selandia Baru"), ("Japan", "Jepang"),
            ("Singapore", "Singapura"), ("Malaysia", "Malaysia"), ("Russia", "Rusia"),
            ("Spain", "Spanyol"), ("Italy", "Italia"), ("Ireland", "Irlandia"),
            ("Sweden", "Swedia"), ("India", "India"), ("China", "Tiongkok"), ("Korea", "Korea")
        ],
        fallbacks: [.country: "Australia", .city: "Canggu", .name: "Alex"]
    )
}
