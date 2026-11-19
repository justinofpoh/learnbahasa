import SwiftUI

struct LessonPlayerView: View {
    let lesson: Lesson
    let unit: Unit

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progress: ProgressStore

    @State private var queue: [Step]
    @State private var index: Int = 0
    @State private var answer: String?
    @State private var feedback: Feedback?
    @State private var requeued: Set<String> = []
    @State private var graded: Int = 0
    @State private var wrong: Int = 0
    @State private var finished = false
    @State private var awarded = false

    init(lesson: Lesson, unit: Unit) {
        self.lesson = lesson
        self.unit = unit
        _queue = State(initialValue: lesson.steps)
    }

    private struct Feedback {
        let correct: Bool
        let answer: String
        let why: String
    }

    private var step: Step? { index < queue.count ? queue[index] : nil }
    private var fraction: Double {
        queue.isEmpty ? 1 : Double(index) / Double(queue.count)
    }

    private var accuracy: Double {
        graded == 0 ? 1 : Double(graded - wrong) / Double(graded)
    }

    private var earnedXP: Int { 10 + Int((accuracy * 10).rounded()) }

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()

            if finished {
                CompletionView(
                    unit: unit,
                    xp: earnedXP,
                    accuracy: accuracy
                ) {
                    dismiss()
                }
                .onAppear(perform: award)
            } else {
                VStack(spacing: 0) {
                    header
                    if let step { TutorLine(step: step, tint: unit.color, expression: feedback.map { $0.correct ? .happy : .neutral } ?? .neutral) }
                    stepContent
                }
            }

            if let feedback {
                FeedbackPanel(
                    correct: feedback.correct,
                    answer: feedback.answer,
                    why: feedback.why,
                    unit: unit
                ) {
                    advance(afterWrong: !feedback.correct)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(2)
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: feedback == nil)
        .onDisappear { Speaker.shared.stop() }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 14) {
            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.inkSoft)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Theme.line.opacity(0.5)))
            }
            .buttonStyle(.plain)

            ProgressCapsule(fraction: fraction, tint: unit.color)

            Text("\(min(index + 1, queue.count))/\(queue.count)")
                .font(.rounded(14, .bold))
                .foregroundStyle(unit.color)
                .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: Step

    @ViewBuilder
    private var stepContent: some View {
        if let step {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        switch step {
                        case .concept(let concept):
                            ConceptStepView(concept: concept, tint: unit.color)
                        case .choice(let choice):
                            ChoiceStepView(
                                choice: choice,
                                tint: unit.color,
                                locked: feedback != nil,
                                selection: $answer
                            )
                            .id(step.id)
                        case .build(let build):
                            BuildStepView(
                                build: build,
                                tint: unit.color,
                                locked: feedback != nil,
                                answer: $answer
                            )
                            .id(step.id)
                        case .listen(let listen):
                            ListenStepView(
                                listen: listen,
                                tint: unit.color,
                                locked: feedback != nil,
                                revealed: feedback != nil,
                                selection: $answer
                            )
                            .id(step.id)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }

                if feedback == nil {
                    ChunkyButton(
                        title: step.isGraded ? "Periksa" : "Lanjut",
                        color: unit.color,
                        enabled: !step.isGraded || answer != nil
                    ) {
                        if step.isGraded {
                            check(step)
                        } else {
                            advance(afterWrong: false)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                }
            }
        }
    }

    // MARK: Grading

    private func check(_ step: Step) {
        guard let given = answer else { return }
        let correct: Bool
        let expected: String
        let why: String

        switch step {
        case .choice(let choice):
            correct = Answer.matches(given, choice.answer)
            expected = choice.answer
            why = choice.why
        case .build(let build):
            correct = Answer.matches(given, build.answer, alt: build.alt)
            expected = build.answer
            why = build.why
        case .listen(let listen):
            correct = Answer.matches(given, listen.answer)
            expected = listen.answer
            why = listen.why
        case .concept:
            return
        }

        graded += 1
        if correct {
            Haptics.correct()
        } else {
            wrong += 1
            Haptics.wrong()
        }
        feedback = Feedback(correct: correct, answer: expected, why: why)
    }

    /// Wrong steps come back once at the end of the queue.
    private func advance(afterWrong: Bool) {
        if afterWrong, let step, !requeued.contains(step.id) {
            requeued.insert(step.id)
            queue.append(step)
        }
        feedback = nil
        answer = nil
        if index + 1 >= queue.count {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { finished = true }
        } else {
            index += 1
        }
    }

    private func award() {
        guard !awarded else { return }
        awarded = true
        progress.complete(lesson: lesson.id, xp: earnedXP)
    }
}

// MARK: - Feedback panel

private struct FeedbackPanel: View {
    let correct: Bool
    let answer: String
    let why: String
    let unit: Unit
    let onContinue: () -> Void

    private var tint: Color { correct ? Theme.benar : Theme.salah }

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    CharacterPortrait(characterID: Cast.tutorID, tint: tint, size: 44, expression: correct ? .happy : .neutral)
                    Text(correct ? "Benar!" : "Belum tepat")
                        .font(.display(24, .semibold))
                        .foregroundStyle(tint)
                    Spacer()
                    SpeakerButton(text: answer, tint: tint)
                }
                if !correct {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Jawaban:")
                            .font(.ui(12, .semibold))
                            .foregroundStyle(Theme.inkSoft)
                        Text(answer)
                            .font(.display(19))
                            .foregroundStyle(Theme.ink)
                    }
                }
                Text(why)
                    .font(.ui(14))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                ChunkyButton(title: "Lanjut", color: correct ? Theme.benar : unit.color) {
                    onContinue()
                }
            }
            .padding(22)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Theme.card)
                    .shadow(color: Theme.ink.opacity(0.12), radius: 22, y: -6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(tint.opacity(0.35), lineWidth: 1.5)
            )
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Completion

private struct CompletionView: View {
    let unit: Unit
    let xp: Int
    let accuracy: Double
    let onDone: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 22) {
                Spacer()
                CharacterPortrait(characterID: Cast.tutorID, tint: unit.color, size: 132, expression: .happy)
                VStack(spacing: 6) {
                    Text("Bagus sekali!")
                        .font(.display(32, .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("Lesson done. See you next time!")
                        .font(.ui(15))
                        .foregroundStyle(Theme.inkSoft)
                }
                HStack(spacing: 14) {
                    ScoreTile(value: "+\(xp)", label: "XP", symbol: "bolt.fill", tint: Theme.kunyit)
                    ScoreTile(
                        value: "\(Int((accuracy * 100).rounded()))%",
                        label: "accuracy",
                        symbol: "target",
                        tint: Theme.sawah
                    )
                }
                Spacer()
                ChunkyButton(title: "Selesai", color: unit.color) { onDone() }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
            ConfettiBurst()
        }
    }
}

private struct ScoreTile: View {
    let value: String
    let label: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
            Text(value)
                .font(.rounded(22))
                .foregroundStyle(Theme.ink)
            Text(label)
                .font(.ui(12))
                .foregroundStyle(Theme.inkSoft)
        }
        .frame(width: 110)
        .cardStyle(radius: 18, padding: 16)
    }
}

/// Kak Dewi, the tutor, says what this step is about in one friendly line.
private struct TutorLine: View {
    let step: Step
    let tint: Color
    var expression: CharacterExpression = .neutral

    private var line: String {
        switch step {
        case .concept: return "Here's the trick ✨"
        case .choice: return "Which one sounds right?"
        case .build: return "Put it together, pelan-pelan."
        case .listen: return "Listen closely…"
        }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            CharacterPortrait(characterID: Cast.tutorID, tint: tint, size: 40, expression: expression)
            Text(line)
                .font(.rounded(15, .semibold))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(ChatShape(mine: false).fill(Theme.card).shadow(color: Theme.kopi.opacity(0.08), radius: 6, y: 3))
                .id(line)
                .transition(.scale(scale: 0.85, anchor: .bottomLeading).combined(with: .opacity))
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: line)
    }
}
