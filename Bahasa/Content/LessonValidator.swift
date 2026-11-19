import Foundation

/// Checks lesson content at DEBUG launch: ids unique, every graded step answerable,
/// no decoy tile that duplicates an answer word.
enum LessonValidator {
    static func validateAll() -> [String] {
        var problems: [String] = []
        var lessonIDs = Set<String>()
        var unitNumbers = Set<Int>()

        for unit in Curriculum.units {
            if !unitNumbers.insert(unit.number).inserted { problems.append("Unit number \(unit.number) is used twice") }
            if unit.lessons.isEmpty { problems.append("Unit \(unit.number) has no lessons") }

            for lesson in unit.lessons {
                let where_ = "Lesson \(lesson.id)"
                if !lessonIDs.insert(lesson.id).inserted { problems.append("\(where_): id used twice") }
                if !lesson.id.hasPrefix("\(unit.number).") { problems.append("\(where_): id doesn't start with unit \(unit.number)") }
                if !lesson.steps.contains(where: { $0.isGraded }) { problems.append("\(where_): no graded steps") }

                var stepIDs = Set<String>()
                for step in lesson.steps {
                    if !stepIDs.insert(step.id).inserted { problems.append("\(where_): two steps share \"\(step.id)\"") }
                    switch step {
                    case .concept(let c):
                        if c.examples.isEmpty && c.pattern.isEmpty { problems.append("\(where_): concept \"\(c.title)\" has nothing to show") }
                    case .choice(let c):
                        problems += options(c.options, answer: c.answer, at: "\(where_) · \(c.prompt)")
                    case .listen(let l):
                        problems += options(l.options, answer: l.answer, at: "\(where_) · \(l.indo)")
                    case .build(let b):
                        let words = Set(b.answer.split(separator: " ").map(normal))
                        if words.isEmpty { problems.append("\(where_) · \(b.english): empty answer") }
                        for extra in b.extras where words.contains(normal(Substring(extra))) {
                            problems.append("\(where_) · \(b.english): decoy \"\(extra)\" is also in the answer")
                        }
                    }
                }
            }
        }
        return problems
    }

    private static func options(_ options: [String], answer: String, at place: String) -> [String] {
        var out: [String] = []
        if options.count < 2 { out.append("\(place): fewer than two options") }
        if !options.contains(answer) { out.append("\(place): answer isn't one of the options") }
        if Set(options).count != options.count { out.append("\(place): duplicate options") }
        return out
    }

    private static func normal(_ word: Substring) -> String {
        word.lowercased().trimmingCharacters(in: .punctuationCharacters)
    }
}
