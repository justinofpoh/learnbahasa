import SwiftUI

// MARK: - Concept

struct ConceptStepView: View {
    let concept: Concept
    var tint: Color = Theme.sambal

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text(concept.title)
                    .font(.display(27, .semibold))
                    .foregroundStyle(Theme.ink)
                Text(concept.body)
                    .font(.ui(15))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }

            if !concept.pattern.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pola")
                        .font(.ui(11, .bold))
                        .tracking(0.8)
                        .foregroundStyle(Theme.inkSoft)
                    PatternStrip(chips: concept.pattern)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
            }

            if !concept.examples.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(concept.examples.enumerated()), id: \.element.id) { index, example in
                        ExampleRow(indo: example.indo, en: example.en, note: example.note, tint: tint)
                        if index < concept.examples.count - 1 {
                            Divider().overlay(Theme.line)
                        }
                    }
                }
                .cardStyle()
            }
        }
    }
}

// MARK: - Choice

struct ChoiceStepView: View {
    let choice: Choice
    var tint: Color = Theme.sambal
    var locked: Bool
    @Binding var selection: String?

    @State private var options: [String]

    init(choice: Choice, tint: Color, locked: Bool, selection: Binding<String?>) {
        self.choice = choice
        self.tint = tint
        self.locked = locked
        self._selection = selection
        _options = State(initialValue: choice.options.shuffled())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            StepPrompt(text: choice.prompt, kicker: "Pilih")

            if let say = choice.say {
                HStack(spacing: 12) {
                    Text(say)
                        .font(.display(20))
                        .foregroundStyle(Theme.ink)
                    Spacer(minLength: 0)
                    SpeakerButton(text: say, tint: tint)
                }
                .cardStyle(radius: 18, padding: 16)
            }

            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    OptionButton(
                        text: option,
                        serif: true,
                        selected: selection == option,
                        tint: tint,
                        locked: locked
                    ) {
                        Haptics.select()
                        selection = option
                    }
                }
            }
        }
    }
}

// MARK: - Build

struct BuildStepView: View {
    let build: Build
    var tint: Color = Theme.sambal
    var locked: Bool
    @Binding var answer: String?

    @State private var tokens: [Token]
    @State private var placed: [UUID] = []
    @Namespace private var tiles

    struct Token: Identifiable, Hashable {
        let id = UUID()
        let text: String
    }

    init(build: Build, tint: Color, locked: Bool, answer: Binding<String?>) {
        self.build = build
        self.tint = tint
        self.locked = locked
        self._answer = answer
        let words = build.answer.split(separator: " ").map { Token(text: String($0)) }
        let extras = build.extras.map { Token(text: $0) }
        _tokens = State(initialValue: (words + extras).shuffled())
    }

    private func token(_ id: UUID) -> Token? { tokens.first { $0.id == id } }

    private var sentence: String {
        placed.compactMap { token($0)?.text }.joined(separator: " ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            StepPrompt(text: build.english, kicker: "Susun kalimat")

            // Answer area
            VStack(spacing: 10) {
                FlowLayout(spacing: 8, lineSpacing: 10) {
                    ForEach(placed, id: \.self) { id in
                        if let token = token(id) {
                            WordTile(text: token.text, tint: tint, filled: true)
                                .matchedGeometryEffect(id: id, in: tiles)
                                .onTapGesture {
                                    guard !locked else { return }
                                    Haptics.tap()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                        placed.removeAll { $0 == id }
                                    }
                                    answer = placed.isEmpty ? nil : sentenceAfterRemoving(id)
                                }
                        }
                    }
                }
                .frame(minHeight: 52, alignment: .leading)
                Rectangle()
                    .fill(Theme.line)
                    .frame(height: 1.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Word bank, with ghost slots left behind
            FlowLayout(spacing: 8, lineSpacing: 10) {
                ForEach(tokens) { token in
                    ZStack {
                        WordTile(text: token.text, tint: tint, ghost: true)
                        if !placed.contains(token.id) {
                            WordTile(text: token.text, tint: tint)
                                .matchedGeometryEffect(id: token.id, in: tiles)
                                .onTapGesture {
                                    guard !locked else { return }
                                    Haptics.tap()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                        placed.append(token.id)
                                    }
                                    answer = sentenceAfterAdding(token.id)
                                }
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
    }

    private func sentenceAfterAdding(_ id: UUID) -> String {
        (placed + (placed.contains(id) ? [] : [id])).compactMap { token($0)?.text }.joined(separator: " ")
    }

    private func sentenceAfterRemoving(_ id: UUID) -> String {
        placed.filter { $0 != id }.compactMap { token($0)?.text }.joined(separator: " ")
    }
}

struct WordTile: View {
    let text: String
    var tint: Color = Theme.sambal
    var filled: Bool = false
    var ghost: Bool = false

    var body: some View {
        Text(text)
            .font(.display(18))
            .foregroundStyle(ghost ? .clear : (filled ? .white : Theme.ink))
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(ghost ? Theme.line.opacity(0.35) : (filled ? tint : Theme.card))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(ghost ? .clear : (filled ? .clear : Theme.line), lineWidth: 1.5)
            )
    }
}

// MARK: - Listen

struct ListenStepView: View {
    let listen: Listen
    var tint: Color = Theme.sambal
    var locked: Bool
    var revealed: Bool
    @Binding var selection: String?

    @State private var options: [String]
    @State private var played = false

    init(listen: Listen, tint: Color, locked: Bool, revealed: Bool, selection: Binding<String?>) {
        self.listen = listen
        self.tint = tint
        self.locked = locked
        self.revealed = revealed
        self._selection = selection
        _options = State(initialValue: listen.options.shuffled())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            StepPrompt(text: "What did you hear?", kicker: "Dengarkan")

            VStack(spacing: 16) {
                Button {
                    Haptics.tap()
                    Speaker.shared.say(listen.indo)
                } label: {
                    ZStack {
                        Circle().fill(tint)
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 96, height: 96)
                }
                .buttonStyle(.plain)

                Button {
                    Haptics.tap()
                    Speaker.shared.say(listen.indo, slow: true)
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "tortoise.fill")
                        Text("Pelan-pelan")
                    }
                    .font(.rounded(14))
                    .foregroundStyle(tint)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(Capsule().fill(tint.opacity(0.12)))
                }
                .buttonStyle(.plain)

                Text(revealed ? listen.indo : "• • • • •")
                    .font(.display(revealed ? 20 : 16))
                    .foregroundStyle(revealed ? Theme.ink : Theme.inkSoft.opacity(0.5))
                    .animation(.easeInOut, value: revealed)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)

            VStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    OptionButton(
                        text: option,
                        serif: false,
                        selected: selection == option,
                        tint: tint,
                        locked: locked
                    ) {
                        Haptics.select()
                        selection = option
                    }
                }
            }
        }
        .onAppear {
            guard !played else { return }
            played = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                Speaker.shared.say(listen.indo)
            }
        }
    }
}

// MARK: - Shared pieces

struct StepPrompt: View {
    let text: String
    let kicker: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(text)
                .font(.display(24, .semibold))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct OptionButton: View {
    let text: String
    var serif: Bool = true
    let selected: Bool
    let tint: Color
    let locked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(text)
                    .font(serif ? .display(18) : .ui(16))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                ZStack {
                    Circle()
                        .stroke(selected ? tint : Theme.line, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if selected {
                        Circle().fill(tint).frame(width: 12, height: 12)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selected ? tint.opacity(0.08) : Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? tint : Theme.line, lineWidth: selected ? 2 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(locked)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: selected)
    }
}
