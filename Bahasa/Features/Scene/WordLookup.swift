import SwiftUI

/// The word the learner tapped, ready to show.
struct WordLookup: Identifiable {
    let id = UUID()
    let tapped: String
    let result: Lexicon.Result?
    var sentence: String?
}

enum WordLink {
    static let scheme = "bahasaword"

    /// An Indonesian line where every word is a tappable link. Punctuation and spaces stay plain.
    static func attributed(_ line: String, underline: Color) -> AttributedString {
        var out = AttributedString()
        var word = ""
        func flush() {
            guard !word.isEmpty else { return }
            var run = AttributedString(word)
            let encoded = word.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? word
            if let url = URL(string: "\(scheme)://w/\(encoded)?s=\(line.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")") {
                run.link = url
            }
            run.underlineStyle = Text.LineStyle(pattern: .dot, color: underline)
            out += run
            word = ""
        }
        for ch in line {
            if ch.isLetter || ch.isNumber || (ch == "-" && !word.isEmpty) {
                word.append(ch)
            } else {
                flush()
                out += AttributedString(String(ch))
            }
        }
        flush()
        return out
    }

    /// Turns a tapped link back into a lookup, or nil if it isn't a word link.
    static func lookup(from url: URL) -> WordLookup? {
        guard url.scheme == scheme else { return nil }
        let word = url.lastPathComponent.removingPercentEncoding ?? url.lastPathComponent
        let sentence = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first { $0.name == "s" }?.value
        return WordLookup(tapped: word, result: Lexicon.lookup(word), sentence: sentence)
    }
}

/// A line of Indonesian you can tap word by word.
struct TappableLine: View {
    let text: String
    var font: Font = .display(18)
    var color: Color = Theme.ink
    var underline: Color = Theme.inkSoft.opacity(0.35)
    var alignment: TextAlignment = .leading

    var body: some View {
        Text(WordLink.attributed(text, underline: underline))
            .font(font)
            .foregroundStyle(color)
            .tint(color)
            .multilineTextAlignment(alignment)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// Kak Dewi explains one word: what it means, what job it does, and a tip.
struct WordLookupSheet: View {
    let lookup: WordLookup
    var tint: Color = Theme.sambal

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Text(lookup.result?.shown ?? lookup.tapped.lowercased())
                    .font(.rounded(32, .heavy))
                    .foregroundStyle(Theme.ink)
                if let role = lookup.result?.entry.role, role != .other {
                    Text(role.label)
                        .font(.rounded(13, .bold))
                        .foregroundStyle(role.color)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(role.color.opacity(0.12)))
                }
                Spacer()
                SpeakerButton(text: lookup.tapped, tint: tint, size: 16)
            }

            if let result = lookup.result {
                Text(result.entry.meaning)
                    .font(.rounded(22, .semibold))
                    .foregroundStyle(tint)
                if result.shown != result.entry.word {
                    Text("from \(result.entry.word)")
                        .font(.ui(14, .medium))
                        .foregroundStyle(Theme.inkSoft)
                }
                let tips = [result.extra, result.entry.note].compactMap { $0 }
                if !tips.isEmpty {
                    HStack(alignment: .bottom, spacing: 10) {
                        CharacterPortrait(characterID: Cast.tutorID, tint: tint, size: 44)
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(tips, id: \.self) { tip in
                                Text(tip)
                                    .font(.ui(15, .medium))
                                    .foregroundStyle(Theme.ink.opacity(0.85))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(ChatShape(mine: false).fill(Theme.card).shadow(color: Theme.kopi.opacity(0.08), radius: 6, y: 3))
                    }
                }
            } else {
                HStack(alignment: .bottom, spacing: 10) {
                    CharacterPortrait(characterID: Cast.tutorID, tint: tint, size: 44)
                    Text("Hmm, that one's not in my pocket dictionary yet. Tap English on the bubble for the whole line.")
                        .font(.ui(15, .medium))
                        .foregroundStyle(Theme.ink.opacity(0.85))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(ChatShape(mine: false).fill(Theme.card))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.paper.ignoresSafeArea())
        .onAppear { Speaker.shared.say(lookup.tapped, slow: true) }
    }
}

/// Word by word: each word with its meaning underneath, in sentence order.
/// Shows how Indonesian order differs from English.
struct WordByWord: View {
    let line: String

    private var words: [String] {
        line.components(separatedBy: CharacterSet.letters.union(.decimalDigits).union(CharacterSet(charactersIn: "-")).inverted)
            .filter { !$0.isEmpty && $0 != "-" }
    }

    var body: some View {
        FlowLayout(spacing: 6, lineSpacing: 8) {
            ForEach(Array(words.enumerated()), id: \.offset) { _, word in
                let result = Lexicon.lookup(word)
                let color = result?.entry.role.color ?? Theme.inkSoft
                VStack(spacing: 3) {
                    Text(word)
                        .font(.rounded(15, .bold))
                        .foregroundStyle(color)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(color.opacity(0.12)))
                    Text(result.map { shortMeaning($0.entry.meaning) } ?? "…")
                        .font(.ui(10, .semibold))
                        .foregroundStyle(Theme.inkSoft)
                        .lineLimit(1)
                }
            }
        }
    }

    private func shortMeaning(_ m: String) -> String {
        let first = m.components(separatedBy: CharacterSet(charactersIn: ",;(")).first ?? m
        return first.trimmingCharacters(in: .whitespaces)
    }
}
