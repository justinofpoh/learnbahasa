import SwiftUI

struct PhrasesView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var query = ""
    @State private var category: String = Curriculum.phrasebook.first?.id ?? "basics"

    private var searching: Bool { !query.trimmingCharacters(in: .whitespaces).isEmpty }

    private var results: [(category: PhraseCategory, phrases: [Phrase])] {
        let needle = query.lowercased()
        return Curriculum.phrasebook.compactMap { cat in
            let hits = cat.phrases.filter {
                $0.indo.lowercased().contains(needle) || $0.en.lowercased().contains(needle)
            }
            return hits.isEmpty ? nil : (cat, hits)
        }
    }

    private var current: PhraseCategory {
        Curriculum.phrasebook.first { $0.id == category } ?? Curriculum.phrasebook[0]
    }

    @State private var showAllLines = false

    var body: some View {
        NavigationStack {
            CozyPage(title: "Frasa", subtitle: "Tap a line to hear it", profile: true) {
                TabArt.phrases.view
            } content: {
                SearchField(text: $query)
                if searching {
                    if results.isEmpty {
                        Text("Nothing yet for \u{201C}\(query)\u{201D}.")
                            .font(.ui(15))
                            .foregroundStyle(Theme.inkSoft)
                    }
                    ForEach(results, id: \.category.id) { group in
                        CozySection(group.category.title) {
                            PhraseList(phrases: group.phrases, tint: group.category.color)
                        }
                    }
                } else {
                    if !progress.rehearsal.lines.isEmpty {
                        yourLines
                    }
                    CozySection("Phrasebook") {
                        VStack(alignment: .leading, spacing: 14) {
                            CategoryPicker(selected: $category)
                            PhraseList(phrases: current.phrases, tint: current.color)
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

extension PhrasesView {
    /// The learner's own lines from Scenes: the real record of progress (spec §3.10).
    fileprivate var yourLines: some View {
        let lines = progress.rehearsal.lines
        let shown = showAllLines ? Array(lines) : Array(lines.prefix(3))
        let phrases = shown.map { Phrase($0.text, $0.gloss) }
        return CozySection(title: "Your Lines") {
            if lines.count > 3 {
                Button(showAllLines ? "Less" : "All \(lines.count)") {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { showAllLines.toggle() }
                }
                .font(.rounded(14, .bold))
                .foregroundStyle(Theme.sambal)
            }
        } content: {
            PhraseList(phrases: phrases, tint: Theme.sambal)
        }
    }
}

private struct SearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.inkSoft)
            TextField("Find a phrase", text: $text)
                .font(.rounded(16, .medium))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.inkSoft.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Capsule().fill(Theme.card).shadow(color: Theme.kopi.opacity(0.07), radius: 8, y: 3))
    }
}

private struct CategoryPicker: View {
    @Binding var selected: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                ForEach(Curriculum.phrasebook) { category in
                    let active = category.id == selected
                    Button {
                        Haptics.select()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selected = category.id
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.symbol)
                                .font(.system(size: 12, weight: .semibold))
                            Text(category.title)
                                .font(.rounded(14))
                        }
                        .foregroundStyle(active ? .white : category.color)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            Capsule().fill(active ? category.color : category.color.opacity(0.12))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollClipDisabled()
    }
}

private struct PhraseList: View {
    let phrases: [Phrase]
    let tint: Color

    @ObservedObject private var speaker = Speaker.shared

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(phrases.enumerated()), id: \.element.id) { index, phrase in
                Button {
                    Haptics.tap()
                    speaker.say(phrase.indo)
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(phrase.indo)
                                .font(.rounded(17, .semibold))
                                .foregroundStyle(Theme.ink)
                                .multilineTextAlignment(.leading)
                            Text(phrase.en)
                                .font(.ui(13))
                                .foregroundStyle(Theme.inkSoft)
                                .multilineTextAlignment(.leading)
                            if let note = phrase.note {
                                Text(note)
                                    .font(.ui(12))
                                    .foregroundStyle(tint.opacity(0.9))
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        Spacer(minLength: 0)
                        Image(systemName: speaker.isSpeaking(phrase.indo) ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(tint)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(tint.opacity(0.12)))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 13)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if index < phrases.count - 1 {
                    Divider().overlay(Theme.line).padding(.leading, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Theme.card)
                .shadow(color: Theme.kopi.opacity(0.08), radius: 10, y: 4)
        )
    }
}
