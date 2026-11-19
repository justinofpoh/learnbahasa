import Foundation

/// Matches typed or spoken input against a node's replies (spec §9).
/// Token-level edit distance where particles (Bu, ya, dong…) are cheap to add or drop,
/// casual forms fold together (gak ≈ tidak), and each word tolerates ~1 typo per 5 letters.
struct Matcher {
    let pack: LanguagePack
    let filler: SlotFiller

    struct Result {
        let option: ReplyOption
        let cost: Double
    }

    /// Maximum total cost for a match. One dropped particle (0.4) plus a typo-free sentence passes;
    /// one missing content word (1.0) does not.
    static let threshold = 0.85

    func normalise(_ text: String) -> [String] {
        var s = text.lowercased()
        s = s.replacingOccurrences(of: "-", with: " ")
        let kept = s.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) || $0 == " " }
        s = String(String.UnicodeScalarView(kept))
        s = s.split(separator: " ").joined(separator: " ")
        for (from, to) in pack.phraseEquivalents {
            s = s.replacingOccurrences(of: from, with: to)
        }
        return s.split(separator: " ").map { fold(String($0)) }
    }

    private func fold(_ token: String) -> String {
        for group in pack.casualEquivalents where group.contains(token) {
            return group[0]
        }
        return token
    }

    /// Best-matching reply for the input, across every grade. Nil if nothing is close.
    func match(_ input: String, in node: SceneNode) -> Result? {
        let given = normalise(input)
        guard !given.isEmpty else { return nil }
        // Input made only of particles ("iya bu") may only match a reply that is also only particles,
        // so "bu" alone can't pass for "Nasi campur satu, Bu".
        let givenIsParticles = given.allSatisfy { pack.particles.contains($0) }

        var best: Result?
        for option in node.replies {
            let forms = ([option.text] + option.accept).flatMap(filler.expansions)
            for form in forms {
                let expected = normalise(form)
                if givenIsParticles && !expected.allSatisfy({ pack.particles.contains($0) }) { continue }
                let cost = min(distance(given, expected), squashed(given, expected))
                guard cost <= Self.threshold else { continue }
                if best == nil || cost < best!.cost - 0.001 || (abs(cost - best!.cost) < 0.001 && rank(option.grade) < rank(best!.option.grade)) {
                    best = Result(option: option, cost: cost)
                }
            }
        }
        return best
    }

    /// True if `input` says the same thing as `expected` (used by Build and Recall).
    func same(_ input: String, _ expected: String) -> Bool {
        distance(normalise(input), normalise(filler.fill(expected))) <= Self.threshold
    }

    private func rank(_ grade: Grade) -> Int {
        switch grade {
        case .natural: return 0
        case .understood: return 1
        case .missed: return 2
        case .off: return 3
        }
    }

    private func indelCost(_ token: String) -> Double {
        pack.particles.contains(token) ? 0.4 : 1.0
    }

    private func subCost(_ a: String, _ b: String) -> Double {
        if a == b { return 0 }
        let allowed = max(a.count, b.count) / 5
        return allowed > 0 && Self.levenshtein(a, b) <= allowed ? 0.25 : 2.0
    }

    /// Catches dropped or extra spaces ("inibu makasih"): compare with spaces removed.
    private func squashed(_ a: [String], _ b: [String]) -> Double {
        let x = a.joined(), y = b.joined()
        let d = Self.levenshtein(x, y)
        return d <= max(1, max(x.count, y.count) / 8) ? 0.3 + 0.1 * Double(d) : .infinity
    }

    /// Which slot value (e.g. a country) the learner actually said, if any.
    func slotValue(in input: String, for slot: Slot) -> String? {
        let said = normalise(input).joined(separator: " ")
        var values = pack.slotForms(slot)
        let own = filler.profile.value(slot)
        if !own.isEmpty { values.insert(own, at: 0) }
        return values.first { said.contains(normalise($0).joined(separator: " ")) }
    }

    private func distance(_ a: [String], _ b: [String]) -> Double {
        if a.isEmpty { return b.reduce(0) { $0 + indelCost($1) } }
        if b.isEmpty { return a.reduce(0) { $0 + indelCost($1) } }
        var prev = [Double](repeating: 0, count: b.count + 1)
        for j in 1...b.count { prev[j] = prev[j - 1] + indelCost(b[j - 1]) }
        for i in 1...a.count {
            var cur = [Double](repeating: 0, count: b.count + 1)
            cur[0] = prev[0] + indelCost(a[i - 1])
            for j in 1...b.count {
                cur[j] = min(
                    prev[j] + indelCost(a[i - 1]),
                    cur[j - 1] + indelCost(b[j - 1]),
                    prev[j - 1] + subCost(a[i - 1], b[j - 1])
                )
            }
            prev = cur
        }
        return prev[b.count]
    }

    static func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }
        var prev = Array(0...b.count)
        for i in 1...a.count {
            var cur = [i] + Array(repeating: 0, count: b.count)
            for j in 1...b.count {
                cur[j] = min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1))
            }
            prev = cur
        }
        return prev[b.count]
    }
}
