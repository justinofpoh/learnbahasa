import Foundation

/// Every Rehearsal Scene, in the order a newcomer meets their Places (spec §11).
enum SceneLibrary {
    static let pack = LanguagePack.indonesian

    static let scenes: [RehearsalScene] = [
        warungLunch, jalanOjek, pasarSarong, kosKamar, temanNgopi,
        laundryKiloan, apotekObat, bengkelBan, tetanggaMampir,
        kafeKopi, rentalMotor, puraKamen
    ]

    static func scene(_ id: String) -> RehearsalScene? {
        scenes.first { $0.id == id }
    }

    /// Old Quick-chat ids (used by the App Store event deep links) mapped to their Scenes.
    static let legacyIDs: [String: String] = [
        "s1": "id.warung.lunch",
        "s2": "id.pasar.sarong",
        "s3": "id.jalan.ojek",
        "s4": "id.kos.kamar",
        "s5": "id.teman.ngopi"
    ]

    /// Resolves a Scene id or a legacy Quick-chat id.
    static func resolve(_ id: String) -> RehearsalScene? {
        scene(legacyIDs[id] ?? id)
    }
}

/// Checks a Scene against the authoring rules (spec §7, §8.1, §12). Returns human-readable problems.
enum SceneValidator {
    static func validate(_ scene: RehearsalScene, pack: LanguagePack = SceneLibrary.pack) -> [String] {
        var problems: [String] = []
        let ids = Set(scene.nodes.map(\.id))
        func fail(_ s: String) { problems.append("\(scene.id): \(s)") }

        if ids.count != scene.nodes.count { fail("duplicate node ids") }
        if scene.node(scene.entry) == nil { fail("entry \(scene.entry) missing") }
        if !scene.nodes.contains(where: \.isEnd) { fail("no end node") }

        for node in scene.nodes where !node.isEnd {
            if node.naturals.count < 2 { fail("\(node.id) has \(node.naturals.count) natural replies (need ≥2)") }
            if !node.replies.contains(where: { !$0.grade.passes }) { fail("\(node.id) has no wrong option for Choose") }
            for r in node.replies {
                if r.grade.passes {
                    guard let next = r.next else { fail("\(node.id) '\(r.text)' passes but has no next"); continue }
                    if !ids.contains(next) { fail("\(node.id) → missing \(next)") }
                    for (_, n) in r.moodNext where !ids.contains(n) { fail("\(node.id) moodNext → missing \(n)") }
                    if r.grade == .understood && r.coach == nil { fail("\(node.id) understood '\(r.text)' has no coach note") }
                } else {
                    if r.reaction == nil { fail("\(node.id) '\(r.text)' has no reaction") }
                    if r.coach == nil { fail("\(node.id) '\(r.text)' has no coach note") }
                }
            }
            // Each passing reply must match itself, not a wrong option.
            let matcher = Matcher(pack: pack, filler: SlotFiller(profile: LearnerProfile(), pack: pack))
            for r in node.replies {
                let filled = SlotFiller(profile: LearnerProfile(), pack: pack).fill(r.text)
                guard let hit = matcher.match(filled, in: node) else { fail("\(node.id) '\(r.text)' doesn't match itself"); continue }
                if hit.option.grade != r.grade { fail("\(node.id) '\(r.text)' matches a \(hit.option.grade.rawValue) option instead") }
            }
        }

        for check in scene.listening where !check.options.contains(check.answer) {
            fail("listening '\(check.question)' answer not among options")
        }

        // Every path through passing replies, in every mood, must end and reach the required goals.
        let required = Set(scene.requiredGoals.map(\.id))
        for mood in scene.character.moods {
            var stack: [(String, Set<String>, Int)] = [(scene.entry, [], 0)]
            var paths = 0
            while let (id, flags, depth) = stack.popLast() {
                guard depth < 30, let node = scene.node(id) else { fail("path too long or broken at \(id)"); break }
                if node.isEnd {
                    paths += 1
                    let missing = required.subtracting(flags)
                    if !missing.isEmpty { fail("[\(mood.rawValue)] path ends without \(missing.sorted().joined(separator: ", "))") }
                    continue
                }
                for r in node.replies where r.grade.passes {
                    if let next = r.nextNode(for: mood) { stack.append((next, flags.union(r.sets), depth + 1)) }
                }
            }
            if paths == 0 { fail("[\(mood.rawValue)] no path reaches an end") }
        }
        return problems
    }

    static func validateAll() -> [String] {
        SceneLibrary.scenes.flatMap { validate($0) + lexiconGaps($0) }
    }

    /// Words shown in chat bubbles (their lines, reactions, replies) that Kak Dewi's sheet can't explain.
    static func lexiconGaps(_ scene: RehearsalScene) -> [String] {
        var lines: [String] = scene.character.confused.map(\.text)
        for node in scene.nodes {
            lines.append(node.them.text)
            if let c = node.them.casual { lines.append(c) }
            lines += node.variants.values.map(\.text)
            for r in node.replies {
                lines.append(r.text)
                if let reaction = r.reaction { lines.append(reaction.text) }
            }
        }
        var missing = Set<String>()
        for line in lines {
            // Slots ({name}, {city}…) hold the learner's own words, so they're skipped.
            let words = line.replacingOccurrences(of: "\\{[a-z]+\\}", with: " ", options: .regularExpression)
                .components(separatedBy: CharacterSet.letters.union(CharacterSet(charactersIn: "-")).inverted)
                .filter { !$0.isEmpty && $0 != "-" }
            for w in words where Lexicon.lookup(w) == nil { missing.insert(w.lowercased()) }
        }
        return missing.isEmpty ? [] : ["\(scene.id): no Lexicon entry for \(missing.sorted().joined(separator: ", "))"]
    }
}
