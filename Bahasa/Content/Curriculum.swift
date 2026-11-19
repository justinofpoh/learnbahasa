import SwiftUI

/// All typed content for the app.
enum Curriculum {
    static let units: [Unit] = [unit1, unit2, unit3, unit4, unit5, unit6, unit7, unit8, unit9, unit10, unit11]

    static var allLessons: [Lesson] { units.flatMap(\.lessons) }

    static func unit(for lessonID: String) -> Unit? {
        units.first { $0.lessons.contains { $0.id == lessonID } }
    }

    static func lesson(_ id: String) -> Lesson? {
        allLessons.first { $0.id == id }
    }

    /// Every concept step, kept with its unit and lesson, for the Patterns tab.
    static var patternEntries: [PatternEntry] {
        units.flatMap { unit in
            unit.lessons.flatMap { lesson in
                lesson.steps.compactMap { step -> PatternEntry? in
                    guard case .concept(let concept) = step else { return nil }
                    return PatternEntry(unit: unit, lesson: lesson, concept: concept)
                }
            }
        }
    }
}

struct PatternEntry: Identifiable {
    let unit: Unit
    let lesson: Lesson
    let concept: Concept

    var id: String { unit.id + "/" + lesson.id + "/" + concept.title }
}
