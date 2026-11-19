import Foundation

// Writes the app's typed content (lessons, phrasebook, lexicon, free Scenes) to JSON for the website.
// Swift stays the source of truth; run tools/content-export/export.sh after changing content.

struct OutChip: Encodable { let text: String; let role: String }
struct OutExample: Encodable { let indo: String; let en: String; let note: String? }
struct OutStep: Encodable {
    let kind: String            // learn · pick · arrange · hear
    var title: String? = nil
    var body: String? = nil
    var pattern: [OutChip]? = nil
    var examples: [OutExample]? = nil
    var prompt: String? = nil
    var say: String? = nil
    var options: [String]? = nil
    var answer: String? = nil
    var alt: [String]? = nil
    var extras: [String]? = nil
    var why: String? = nil
}
struct OutLesson: Encodable { let id: String; let title: String; let subtitle: String; let steps: [OutStep] }
struct OutUnit: Encodable {
    let id: String; let number: Int; let indoTitle: String; let title: String; let blurb: String
    let accent: String; let free: Bool; let lessons: [OutLesson]
}
struct OutPhrase: Encodable { let indo: String; let en: String; let note: String? }
struct OutCategory: Encodable { let id: String; let title: String; let indoTitle: String; let accent: String; let phrases: [OutPhrase] }
struct OutEntry: Encodable { let meaning: String; let role: String; let note: String? }

struct OutUtterance: Encodable { let text: String; let casual: String?; let gloss: String }
struct OutReply: Encodable {
    let text: String; let gloss: String; let grade: String
    let sets: [String]; let next: String?; let reaction: OutUtterance?; let coach: String?
}
struct OutNode: Encodable { let id: String; let narration: String?; let them: OutUtterance; let replies: [OutReply] }
struct OutGoal: Encodable { let id: String; let label: String; let optional: Bool }
struct OutScene: Encodable {
    let id: String; let place: String; let title: String; let titleEn: String; let setting: String
    let accent: String; let character: String; let characterName: String; let characterRole: String
    let goalSummary: String; let goals: [OutGoal]; let culture: [String]
    let entry: String; let nodes: [OutNode]; let free: Bool
}
struct OutAll: Encodable {
    let generated: String
    let units: [OutUnit]
    let phrasebook: [OutCategory]
    let lexicon: [String: OutEntry]
    let places: [String: String]
    let fallbacks: [String: String]
    let scenes: [OutScene]
}

func chips(_ list: [Chip]) -> [OutChip]? { list.isEmpty ? nil : list.map { OutChip(text: $0.text, role: $0.role.rawValue) } }
func utter(_ u: Utterance) -> OutUtterance { OutUtterance(text: u.text, casual: u.casual, gloss: u.gloss) }

func step(_ s: Step) -> OutStep {
    switch s {
    case .concept(let c):
        return OutStep(kind: "learn", title: c.title, body: c.body, pattern: chips(c.pattern),
                       examples: c.examples.map { OutExample(indo: $0.indo, en: $0.en, note: $0.note) })
    case .choice(let c):
        return OutStep(kind: "pick", prompt: c.prompt, say: c.say, options: c.options, answer: c.answer, why: c.why)
    case .build(let b):
        return OutStep(kind: "arrange", prompt: b.english, answer: b.answer, alt: b.alt, extras: b.extras, why: b.why)
    case .listen(let l):
        return OutStep(kind: "hear", say: l.indo, options: l.options, answer: l.answer, why: l.why)
    }
}

let units = Curriculum.units.map { u in
    OutUnit(id: u.id, number: u.number, indoTitle: u.indoTitle, title: u.title, blurb: u.blurb,
            accent: u.accent.rawValue, free: Access.freeUnitNumbers.contains(u.number),
            // The website is free: every lesson ships in full. `free` still says what the app gives away.
            lessons: u.lessons.map { l in
                OutLesson(id: l.id, title: l.title, subtitle: l.subtitle, steps: l.steps.map(step))
            })
}
let phrasebook = Curriculum.phrasebook.map { c in
    OutCategory(id: c.id, title: c.title, indoTitle: c.indoTitle, accent: c.accent.rawValue,
                phrases: c.phrases.map { OutPhrase(indo: $0.indo, en: $0.en, note: $0.note) })
}
var lexicon: [String: OutEntry] = [:]
for (word, e) in Lexicon.entries { lexicon[word] = OutEntry(meaning: e.meaning, role: e.role.rawValue, note: e.note) }

let scenes = SceneLibrary.scenes.map { s in
    OutScene(id: s.id, place: s.place, title: s.title, titleEn: s.titleEn, setting: s.setting,
             accent: s.accent.rawValue, character: s.character.id, characterName: s.character.name,
             characterRole: s.character.role, goalSummary: s.goalSummary,
             goals: s.goals.map { OutGoal(id: $0.id, label: $0.label, optional: $0.optional) },
             culture: s.culture, entry: s.entry,
             nodes: s.nodes.map { n in
                 OutNode(id: n.id, narration: n.narration, them: utter(n.them),
                         replies: n.replies.map { r in
                             OutReply(text: r.text, gloss: r.gloss, grade: r.grade.rawValue, sets: r.sets,
                                      next: r.next, reaction: r.reaction.map(utter), coach: r.coach)
                         })
             },
             free: Access.freeSceneIDs.contains(s.id))
}

var fallbacks: [String: String] = [:]
for (slot, value) in SceneLibrary.pack.fallbacks { fallbacks[slot.rawValue] = value }

let out = OutAll(generated: ISO8601DateFormatter().string(from: Date()), units: units, phrasebook: phrasebook,
                 lexicon: lexicon, places: Lexicon.places, fallbacks: fallbacks, scenes: scenes)
let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
let data = try encoder.encode(out)
let path = CommandLine.arguments.dropFirst().first ?? "content.json"
try data.write(to: URL(fileURLWithPath: path))
print("wrote \(path): \(units.count) units, \(units.reduce(0) { $0 + $1.lessons.count }) lessons, \(phrasebook.count) phrase groups, \(lexicon.count) words, \(scenes.count) scenes")
