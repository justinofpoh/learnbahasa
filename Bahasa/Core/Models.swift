import SwiftUI

// MARK: - Sentence roles

/// Grammatical role of a word chip. Each role has a colour and a short label.
enum Role: String, Codable, CaseIterable, Identifiable {
    case subject, verb, object, time, helper, negation, describe, question, link, other

    var id: String { rawValue }

    /// Single-letter tag used when authoring patterns, e.g. "Saya/S makan/V".
    var tag: String {
        switch self {
        case .subject: return "S"
        case .verb: return "V"
        case .object: return "O"
        case .time: return "T"
        case .helper: return "H"
        case .negation: return "N"
        case .describe: return "D"
        case .question: return "Q"
        case .link: return "L"
        case .other: return "X"
        }
    }

    var label: String {
        switch self {
        case .subject: return "subject"
        case .verb: return "verb"
        case .object: return "object"
        case .time: return "time"
        case .helper: return "helper"
        case .negation: return "negation"
        case .describe: return "describer"
        case .question: return "question"
        case .link: return "linker"
        case .other: return "word"
        }
    }

    var color: Color {
        switch self {
        case .subject: return Theme.indigo
        case .verb: return Theme.sambal
        case .object: return Theme.sawah
        case .time: return Theme.kunyit
        case .helper: return Theme.laut
        case .negation: return Theme.jambu
        case .describe: return Theme.kopi
        case .question: return Theme.laut
        case .link: return Theme.inkSoft
        case .other: return Theme.inkSoft
        }
    }

    static func named(_ tag: String) -> Role {
        Role.allCases.first { $0.tag == tag.uppercased() } ?? .other
    }
}

/// One word (or short phrase) of a pattern, tagged with its role.
struct Chip: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let role: Role

    /// Parses `"Saya/S makan/V nasi_goreng/O"`. Underscores become spaces.
    static func parse(_ source: String) -> [Chip] {
        source.split(separator: " ").map { token in
            let parts = token.split(separator: "/", maxSplits: 1)
            let text = parts[0].replacingOccurrences(of: "_", with: " ")
            let role = parts.count > 1 ? Role.named(String(parts[1])) : .other
            return Chip(text: text, role: role)
        }
    }
}

// MARK: - Lesson content

struct Example: Identifiable {
    let id = UUID()
    let indo: String
    let en: String
    var note: String?

    init(_ indo: String, _ en: String, note: String? = nil) {
        self.indo = indo
        self.en = en
        self.note = note
    }
}

struct Concept {
    let title: String
    let body: String
    var pattern: [Chip] = []
    var examples: [Example] = []
}

struct Choice {
    let prompt: String
    var say: String?
    let options: [String]
    let answer: String
    let why: String
}

struct Build {
    let english: String
    let answer: String
    var alt: [String] = []
    var extras: [String] = []
    let why: String
}

struct Listen {
    let indo: String
    let options: [String]
    let answer: String
    let why: String
}

enum Step: Identifiable {
    case concept(Concept)
    case choice(Choice)
    case build(Build)
    case listen(Listen)

    var id: String {
        switch self {
        case .concept(let c): return "c-" + c.title
        case .choice(let c): return "p-" + c.prompt
        case .build(let b): return "b-" + b.english
        case .listen(let l): return "l-" + l.indo
        }
    }

    var isGraded: Bool {
        if case .concept = self { return false }
        return true
    }

    // Terse builders used by the content files.

    static func learn(_ title: String, _ body: String, pattern: String? = nil, examples: [Example] = []) -> Step {
        .concept(Concept(
            title: title,
            body: body,
            pattern: pattern.map(Chip.parse) ?? [],
            examples: examples
        ))
    }

    static func pick(_ prompt: String, say: String? = nil, _ options: [String], answer: String, why: String) -> Step {
        .choice(Choice(prompt: prompt, say: say, options: options, answer: answer, why: why))
    }

    static func arrange(_ english: String, _ answer: String, alt: [String] = [], extras: [String] = [], why: String) -> Step {
        .build(Build(english: english, answer: answer, alt: alt, extras: extras, why: why))
    }

    static func hear(_ indo: String, _ options: [String], answer: String, why: String) -> Step {
        .listen(Listen(indo: indo, options: options, answer: answer, why: why))
    }
}

struct Lesson: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let steps: [Step]
}

struct Unit: Identifiable {
    let id: String
    let number: Int
    let indoTitle: String
    let title: String
    let blurb: String
    let accent: Accent
    let symbol: String
    let lessons: [Lesson]

    var color: Color { accent.color }
}

// MARK: - Phrasebook

struct Phrase: Identifiable {
    let id = UUID()
    let indo: String
    let en: String
    var note: String?

    init(_ indo: String, _ en: String, note: String? = nil) {
        self.indo = indo
        self.en = en
        self.note = note
    }
}

struct PhraseCategory: Identifiable {
    let id: String
    let title: String
    let indoTitle: String
    let symbol: String
    let accent: Accent
    let phrases: [Phrase]

    var color: Color { accent.color }
}

// MARK: - Answer comparison

enum Answer {
    /// Case- and punctuation-insensitive comparison.
    static func normalise(_ text: String) -> String {
        let stripped = text.lowercased().unicodeScalars.filter { scalar in
            CharacterSet.alphanumerics.contains(scalar) || scalar == " "
        }
        return String(String.UnicodeScalarView(stripped))
            .split(separator: " ")
            .joined(separator: " ")
    }

    static func matches(_ given: String, _ expected: String, alt: [String] = []) -> Bool {
        let g = normalise(given)
        return ([expected] + alt).contains { normalise($0) == g }
    }
}
