import SwiftUI

/// First run: seven short, friendly pages, including a level check so nobody starts too easy. Every page leads with a drawing and says one thing.
struct OnboardingView: View {
    /// Called with true when the learner wants to jump straight into their first chat.
    var onFinish: (_ startFirstChat: Bool) -> Void

    @EnvironmentObject private var progress: ProgressStore
    @State private var page = 0
    @State private var name = ""
    @State private var country = ""
    @State private var level: Int = -1
    @State private var placed: Int?
    @State private var forward = true

    private let pageCount = 7

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if page < pageCount - 1 {
                    Button("Skip") {
                        Haptics.tap()
                        go(to: pageCount - 1)
                    }
                    .font(.rounded(16, .semibold))
                    .foregroundStyle(Theme.inkSoft)
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 22)

            // A hand-rolled pager: the paging TabView jumps back to page one when a page's state changes.
            ZStack {
                current
                    .id(page)
                    .transition(.asymmetric(
                        insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity)))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        guard abs(value.translation.width) > abs(value.translation.height) * 1.5 else { return }
                        if value.translation.width < -60 { go(to: page + 1) }
                        if value.translation.width > 60 { go(to: page - 1) }
                    }
            )

            VStack(spacing: 18) {
                HStack(spacing: 7) {
                    ForEach(0..<pageCount, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? Theme.sambal : Theme.line)
                            .frame(width: i == page ? 22 : 8, height: 8)
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: page)
                .accessibilityHidden(true)

                ChunkyButton(title: page == pageCount - 1 ? "Start my first chat" : "Next", color: Theme.sambal) {
                    if page < pageCount - 1 {
                        go(to: page + 1)
                    } else {
                        finish(startChat: true)
                    }
                }
                if page == pageCount - 1 {
                    Button("Look around first") { finish(startChat: false) }
                        .font(.rounded(15, .semibold))
                        .foregroundStyle(Theme.inkSoft)
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 14)
        }
        .background(Theme.paper.ignoresSafeArea())
        .onAppear {
            name = progress.profile.name
            country = progress.profile.country
            level = progress.profile.level
        }
    }

    @ViewBuilder
    private var current: some View {
        switch page {
        case 0: WelcomePage()
        case 1: NeighboursPage()
        case 2: HowItWorksPage(active: true)
        case 3: TapAWordPage()
        case 4: LevelPage(level: $level)
        case 5: QuickCheckPage(level: level, active: true, placed: $placed)
        default: AboutYouPage(name: $name, country: $country)
        }
    }

    private func go(to target: Int) {
        let next = min(max(target, 0), pageCount - 1)
        guard next != page else { return }
        forward = next > page
        Haptics.tap()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { page = next }
    }

    private func finish(startChat: Bool) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let chosen = country
        let finalLevel = placed ?? level
        progress.mutateRehearsal { state in
            if !trimmed.isEmpty { state.profile.name = trimmed }
            if !chosen.isEmpty { state.profile.country = chosen }
            if finalLevel >= 0 { state.profile.level = finalLevel }
        }
        // A first chat speed that fits the level, unless the learner already picked one.
        if let l = LearnerLevel(rawValue: finalLevel), UserDefaults.standard.object(forKey: ChatPace.storageKey) == nil {
            UserDefaults.standard.set(l.pace.rawValue, forKey: ChatPace.storageKey)
        }
        Haptics.correct()
        onFinish(startChat)
    }
}

// MARK: - Page frame

/// Drawing on top, then one title and one line.
private struct OnboardingPage<Art: View, Extra: View>: View {
    let title: String
    let text: String
    @ViewBuilder var art: () -> Art
    @ViewBuilder var extra: () -> Extra

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            art()
                .frame(maxWidth: .infinity)
                .frame(minHeight: 240, maxHeight: 440)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: Theme.kopi.opacity(0.12), radius: 14, y: 6)
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.rounded(30, .heavy))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(text)
                    .font(.ui(17, .medium))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
            extra()
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 8)
    }
}

extension OnboardingPage where Extra == EmptyView {
    init(title: String, text: String, @ViewBuilder art: @escaping () -> Art) {
        self.title = title
        self.text = text
        self.art = art
        self.extra = { EmptyView() }
    }
}

// MARK: - 1 · Welcome

private struct WelcomePage: View {
    var body: some View {
        OnboardingPage(title: "Selamat datang!",
                       text: "Learn Indonesian the way you'll use it: by chatting with friendly neighbours in Bali.") {
            TabArt.talk.view
        }
    }
}

// MARK: - 2 · Neighbours

private struct NeighboursPage: View {
    var body: some View {
        OnboardingPage(title: "Meet your neighbours",
                       text: "Each one runs a little moment from daily life: lunch, a ride, the market, a room, a coffee.") {
            ZStack {
                CalmSurface(color: Theme.kunyit, radius: 0)
                VStack(spacing: 18) {
                    HStack(spacing: 14) {
                        neighbour(SceneLibrary.warungLunch, phase: 0)
                        neighbour(SceneLibrary.jalanOjek, phase: 0.8)
                        neighbour(SceneLibrary.pasarSarong, phase: 1.6)
                    }
                    HStack(spacing: 14) {
                        neighbour(SceneLibrary.kosKamar, phase: 2.4)
                        neighbour(SceneLibrary.temanNgopi, phase: 3.2)
                    }
                }
            }
        }
    }

    private func neighbour(_ scene: RehearsalScene, phase: Double) -> some View {
        VStack(spacing: 6) {
            CharacterPortrait(characterID: scene.character.id, tint: scene.color, size: 76)
                .bob(4, period: 3, phase: phase)
            Text(scene.character.name)
                .font(.rounded(13, .bold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - 3 · How a chat works

private struct HowItWorksPage: View {
    var active: Bool
    @State private var shown = 0

    var body: some View {
        OnboardingPage(title: "Practise here,\nthen do it for real",
                       text: "Chat as often as you like. When you're ready, try it at the real warung.") {
            ZStack {
                IllustrationCanvas(drawing: WarungDrawing(speaking: false, expression: shown >= 2 ? .happy : .neutral,
                                                          busy: false, compact: true))
                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    if shown >= 1 {
                        HStack(alignment: .bottom, spacing: 8) {
                            CharacterPortrait(characterID: "ibu-wayan", tint: Theme.sambal, size: 34)
                            Text("Mau makan apa?")
                                .font(.rounded(16, .semibold))
                                .padding(.horizontal, 13).padding(.vertical, 9)
                                .background(ChatShape(mine: false).fill(Theme.card))
                        }
                        .transition(.scale(scale: 0.8, anchor: .bottomLeading).combined(with: .opacity))
                    }
                    if shown >= 2 {
                        Text("Nasi campur satu, Bu.")
                            .font(.rounded(16, .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 13).padding(.vertical, 9)
                            .background(ChatShape(mine: true).fill(Theme.sambal))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .transition(.scale(scale: 0.8, anchor: .bottomTrailing).combined(with: .opacity))
                    }
                }
                .padding(14)
            }
        }
        .onChange(of: active) { _, now in
            if now { play() } else { shown = 0 }
        }
        .onAppear { if active { play() } }
    }

    private func play() {
        shown = 0
        for (i, delay) in [0.35, 1.1].enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { shown = i + 1 }
            }
        }
    }
}

// MARK: - 4 · Tap a word

private struct TapAWordPage: View {
    @State private var picked: Lexicon.Result? = Lexicon.lookup("mau")

    private let line = "Mau makan apa?"

    var body: some View {
        OnboardingPage(title: "Stuck on a word?\nTap it.",
                       text: "Every word in a chat explains itself, so you're never lost.") {
            ZStack {
                IllustrationCanvas(drawing: NotebookDrawing())
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .bottom, spacing: 8) {
                        CharacterPortrait(characterID: "ibu-wayan", tint: Theme.sambal, size: 36)
                        HStack(spacing: 6) {
                            ForEach(line.split(separator: " ").map(String.init), id: \.self) { word in
                                Button {
                                    Haptics.select()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { picked = Lexicon.lookup(word) }
                                } label: {
                                    Text(word)
                                        .font(.rounded(18, .bold))
                                        .foregroundStyle(picked?.shown == word.lowercased().trimmingCharacters(in: .punctuationCharacters) ? Theme.sambal : Theme.ink)
                                        .underline(pattern: .dot, color: Theme.sambal.opacity(0.5))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(ChatShape(mine: false).fill(Theme.card))
                    }
                    if let picked {
                        HStack(alignment: .bottom, spacing: 8) {
                            CharacterPortrait(characterID: Cast.tutorID, tint: Theme.sawah, size: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(picked.shown) = \(picked.entry.meaning)")
                                    .font(.rounded(16, .heavy))
                                    .foregroundStyle(picked.entry.role.color)
                                if let note = picked.entry.note {
                                    Text(note)
                                        .font(.ui(13, .medium))
                                        .foregroundStyle(Theme.inkSoft)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.horizontal, 13).padding(.vertical, 9)
                            .background(ChatShape(mine: false).fill(Theme.card))
                        }
                        .id(picked.shown)
                        .transition(.scale(scale: 0.85, anchor: .bottomLeading).combined(with: .opacity))
                    }
                }
                .padding(16)
            }
        }
    }
}

// MARK: - 5 · Level

/// "How much Indonesian do you know?" A gauge whose needle follows the pick.
private struct LevelPage: View {
    @Binding var level: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                TutorBubble(indo: "Sudah bisa bahasa Indonesia?", en: "How much Indonesian do you know?")
                    .padding(.top, 8)
                LevelGauge(level: level)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                VStack(spacing: 10) {
                    ForEach(LearnerLevel.allCases) { l in
                        let on = level == l.rawValue
                        Button {
                            Haptics.select()
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.62)) { level = l.rawValue }
                        } label: {
                            HStack(spacing: 14) {
                                Text("\(l.rawValue)")
                                    .font(.rounded(15, .heavy))
                                    .foregroundStyle(.white)
                                    .frame(width: 34, height: 34)
                                    .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(l.color))
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(l.title)
                                        .font(.rounded(17, .bold))
                                        .foregroundStyle(Theme.ink)
                                    Text(l.note)
                                        .font(.ui(13, .medium))
                                        .foregroundStyle(Theme.inkSoft)
                                }
                                Spacer(minLength: 0)
                                if on {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Theme.sambal)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 14).padding(.vertical, 11)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(on ? Theme.sambal.opacity(0.08) : Theme.card)
                                    .shadow(color: Theme.kopi.opacity(on ? 0 : 0.07), radius: 6, y: 3)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(on ? Theme.sambal : .clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.squish)
                        .accessibilityAddTraits(on ? .isSelected : [])
                    }
                }
                Text("Next, three quick lines to check.")
                    .font(.ui(13))
                    .foregroundStyle(Theme.inkSoft)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)
        }
    }
}

/// A half-dial in the four level colours with a needle that springs to the chosen level.
private struct LevelGauge: View {
    var level: Int

    private var angle: Double {
        guard level >= 0 else { return -72 }
        return -90 + (Double(level) + 0.5) * 45
    }

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width, 280)
            let r = w / 2 - 14
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height - 10)
            ZStack {
                ForEach(LearnerLevel.allCases) { l in
                    Path { p in
                        p.addArc(center: center, radius: r,
                                 startAngle: .degrees(180 + Double(l.rawValue) * 45 + 1.5),
                                 endAngle: .degrees(180 + Double(l.rawValue + 1) * 45 - 1.5), clockwise: false)
                    }
                    .stroke(l.rawValue <= level ? l.color : Theme.line, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                }
                Capsule()
                    .fill(Theme.ink)
                    .frame(width: 6, height: r - 22)
                    .rotationEffect(.degrees(angle), anchor: .bottom)
                    .position(x: center.x, y: center.y - (r - 22) / 2)
                Circle()
                    .fill(Theme.sambal)
                    .frame(width: 20, height: 20)
                    .overlay(Circle().stroke(.white, lineWidth: 3))
                    .position(center)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(LearnerLevel(rawValue: level)?.title ?? "No level picked yet")
    }
}

// MARK: - 6 · Quick check

/// Three short lines matched to the chosen level. Answers nudge the placement up or down.
private struct QuickCheckPage: View {
    let level: Int
    let active: Bool
    @Binding var placed: Int?

    @State private var index = 0
    @State private var picked: String?
    @State private var right = 0
    @State private var questions: [CheckQuestion] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text(done ? "All done" : "Quick check · \(index + 1) of \(questions.count)")
                        .font(.rounded(14, .bold))
                        .foregroundStyle(Theme.inkSoft)
                    Spacer()
                    HStack(spacing: 6) {
                        ForEach(0..<max(questions.count, 1), id: \.self) { i in
                            Capsule()
                                .fill(i < index || done ? Theme.sambal : Theme.line)
                                .frame(width: 18, height: 6)
                        }
                    }
                }
                .padding(.top, 8)

                if done {
                    result
                        .transition(.scale(scale: 0.9).combined(with: .opacity))
                } else if index < questions.count {
                    let q = questions[index]
                    question(q)
                        .id(index)
                        .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                                removal: .move(edge: .leading).combined(with: .opacity)))
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)
        }
        .onChange(of: active) { _, now in if now { prepare() } }
        .onAppear { if active { prepare() } }
    }

    private var done: Bool { !questions.isEmpty && index >= questions.count }

    private func question(_ q: CheckQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .bottom, spacing: 10) {
                CharacterPortrait(characterID: q.speaker, tint: q.tint, size: 52)
                VStack(alignment: .leading, spacing: 3) {
                    Text(q.indo)
                        .font(.rounded(20, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text(q.place)
                        .font(.ui(12, .medium))
                        .foregroundStyle(Theme.inkSoft)
                }
                .padding(.horizontal, 14).padding(.vertical, 11)
                .background(ChatShape(mine: false).fill(Theme.card).shadow(color: Theme.kopi.opacity(0.08), radius: 6, y: 3))
                Spacer(minLength: 0)
                SpeakerButton(text: q.indo, tint: q.tint)
            }
            Text("What does it mean?")
                .font(.rounded(17, .bold))
                .foregroundStyle(Theme.ink)
            VStack(spacing: 10) {
                ForEach(q.options, id: \.self) { option in
                    Button { answer(option, for: q) } label: {
                        HStack {
                            Text(option)
                                .font(.rounded(16, .semibold))
                                .foregroundStyle(Theme.ink)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                            if let picked, option == picked || (option == q.answer && picked != nil) {
                                Image(systemName: option == q.answer ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(option == q.answer ? Theme.benar : Theme.sambal)
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(fill(option, q))
                                .shadow(color: Theme.kopi.opacity(0.07), radius: 6, y: 3)
                        )
                    }
                    .buttonStyle(.squish)
                    .disabled(picked != nil)
                }
                Button { answer(CheckQuestion.notYet, for: q) } label: {
                    Text(CheckQuestion.notYet)
                        .font(.rounded(15, .semibold))
                        .foregroundStyle(Theme.inkSoft)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .disabled(picked != nil)
            }
        }
    }

    private func fill(_ option: String, _ q: CheckQuestion) -> Color {
        guard let picked else { return Theme.card }
        if option == q.answer { return Theme.benar.opacity(0.14) }
        if option == picked { return Theme.sambal.opacity(0.1) }
        return Theme.card
    }

    private var result: some View {
        let l = LearnerLevel(rawValue: placed ?? 1) ?? .fewWords
        return VStack(alignment: .leading, spacing: 16) {
            TutorBubble(indo: right >= 2 ? "Bagus sekali!" : "Tidak apa-apa!",
                        en: right >= 2 ? "Very good! You know more than you think." : "No worries. We'll start gently.")
            VStack(alignment: .leading, spacing: 6) {
                Text("You're starting at")
                    .font(.ui(14, .medium))
                    .foregroundStyle(.white.opacity(0.85))
                Text(l.title)
                    .font(.rounded(28, .heavy))
                    .foregroundStyle(.white)
                Text(startLine(l))
                    .font(.ui(14, .medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CalmSurface(color: l.color))
            Text("\(right) of \(questions.count) right. You can change your level in Profile any time.")
                .font(.ui(13))
                .foregroundStyle(Theme.inkSoft)
        }
    }

    private func startLine(_ l: LearnerLevel) -> String {
        switch l {
        case .new: return "From hello, at a relaxed pace."
        case .fewWords: return "Quick basics, then your first chat."
        case .getBy: return "Skipping the basics. Lessons start at time words."
        case .chat: return "Straight to questions, prices and real small talk."
        }
    }

    private func prepare() {
        guard questions.isEmpty else { return }
        questions = CheckQuestion.set(for: level)
        index = 0
        right = 0
        picked = nil
    }

    private func answer(_ option: String, for q: CheckQuestion) {
        guard picked == nil else { return }
        picked = option
        let correct = option == q.answer
        if correct { right += 1; Haptics.correct() } else { Haptics.select() }
        DispatchQueue.main.asyncAfter(deadline: .now() + (correct ? 0.8 : 1.4)) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                picked = nil
                index += 1
                if index >= questions.count { place() }
            }
        }
    }

    /// All right keeps the chosen level (one up if they picked none); one or none right moves down one.
    private func place() {
        let chosen = level >= 0 ? level : 1
        let result: Int
        if right == questions.count {
            result = level >= 0 ? chosen : 2
        } else if right <= 1 {
            result = max(0, chosen - 1)
        } else {
            result = chosen
        }
        placed = result
        Haptics.pop()
    }
}

private struct CheckQuestion {
    let indo: String
    let answer: String
    let wrong: [String]
    let speaker: String
    let tint: Color
    let place: String
    /// Shuffled once, when the question set is built.
    var options: [String] = []

    static let notYet = "I don't know yet"

    private static let easy = [
        CheckQuestion(indo: "Terima kasih!", answer: "Thank you!", wrong: ["Good morning!", "Excuse me!"],
                      speaker: "ibu-wayan", tint: Theme.sambal, place: "Ibu Wayan, at the warung"),
        CheckQuestion(indo: "Selamat pagi!", answer: "Good morning!", wrong: ["Good night!", "Enjoy your meal!"],
                      speaker: "putu", tint: Theme.kopi, place: "Putu, at the café"),
    ]
    private static let middle = [
        CheckQuestion(indo: "Sudah makan?", answer: "Have you eaten?", wrong: ["Are you full?", "Do you want to eat?"],
                      speaker: "ibu-wayan", tint: Theme.sambal, place: "Ibu Wayan, at the warung"),
        CheckQuestion(indo: "Berapa harganya?", answer: "How much is it?", wrong: ["How many are there?", "Which one is it?"],
                      speaker: "bu-ketut", tint: Theme.kunyit, place: "Bu Ketut, at the market"),
    ]
    private static let hard = [
        CheckQuestion(indo: "Saya belum pernah ke Lombok.", answer: "I haven't been to Lombok yet.",
                      wrong: ["I'm going to Lombok soon.", "I was in Lombok yesterday."],
                      speaker: "pak-agus", tint: Theme.laut, place: "Pak Agus, on the ojek"),
        CheckQuestion(indo: "Kalau sewa enam bulan, bisa lebih murah?", answer: "If I rent for six months, can it be cheaper?",
                      wrong: ["Is it cheaper in six months?", "Can I pay for six months later?"],
                      speaker: "bu-sari", tint: Theme.sawah, place: "Bu Sari, at the kos"),
    ]

    static func set(for level: Int) -> [CheckQuestion] {
        let picks: [CheckQuestion]
        switch level {
        case ...0: picks = [easy[0], easy[1], middle[0]]
        case 1: picks = [easy[0], middle[0], middle[1]]
        case 2: picks = [middle[0], middle[1], hard[0]]
        default: picks = [middle[1], hard[0], hard[1]]
        }
        return picks.map { q in
            var q = q
            q.options = ([q.answer] + q.wrong).shuffled()
            return q
        }
    }
}

/// Kak Dewi saying one line, with the English underneath.
private struct TutorBubble: View {
    let indo: String
    let en: String

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            CharacterPortrait(characterID: Cast.tutorID, tint: Theme.sawah, size: 56, expression: .happy)
            VStack(alignment: .leading, spacing: 2) {
                Text("Kak Dewi")
                    .font(.rounded(12, .bold))
                    .foregroundStyle(Theme.sawah)
                Text(indo)
                    .font(.rounded(18, .bold))
                    .foregroundStyle(Theme.ink)
                Text(en)
                    .font(.ui(13, .medium))
                    .foregroundStyle(Theme.inkSoft)
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
            .background(ChatShape(mine: false).fill(Theme.card).shadow(color: Theme.kopi.opacity(0.08), radius: 6, y: 3))
        }
    }
}

// MARK: - 7 · About you

private struct AboutYouPage: View {
    @Binding var name: String
    @Binding var country: String
    @FocusState private var nameFocused: Bool

    private var popular: [(en: String, local: String)] {
        let order = ["Australia", "Amerika", "Inggris", "Kanada", "Jerman", "Belanda", "Prancis", "Selandia Baru", "Singapura", "Rusia"]
        return order.compactMap { local in SceneLibrary.pack.countries.first { $0.local == local } }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .bottom, spacing: 10) {
                    CharacterPortrait(characterID: Cast.tutorID, tint: Theme.sawah, size: 64, expression: .happy)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Kak Dewi")
                            .font(.rounded(12, .bold))
                            .foregroundStyle(Theme.sawah)
                        Text("Hai! Siapa namamu? Dari mana?")
                            .font(.rounded(18, .bold))
                            .foregroundStyle(Theme.ink)
                        Text("Hi! What's your name? Where are you from?")
                            .font(.ui(13, .medium))
                            .foregroundStyle(Theme.inkSoft)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 11)
                    .background(ChatShape(mine: false).fill(Theme.card).shadow(color: Theme.kopi.opacity(0.08), radius: 6, y: 3))
                }
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your name")
                        .font(.rounded(15, .bold))
                        .foregroundStyle(Theme.ink)
                    TextField("e.g. Alex", text: $name)
                        .font(.rounded(18, .semibold))
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .focused($nameFocused)
                        .submitLabel(.done)
                        .padding(.horizontal, 16).padding(.vertical, 13)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.card)
                            .shadow(color: Theme.kopi.opacity(0.07), radius: 8, y: 3))
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Where you're from")
                        .font(.rounded(15, .bold))
                        .foregroundStyle(Theme.ink)
                    FlowLayout(spacing: 8, lineSpacing: 8) {
                        ForEach(popular, id: \.local) { c in
                            let on = country == c.local
                            Button {
                                Haptics.select()
                                nameFocused = false
                                country = on ? "" : c.local
                            } label: {
                                Text(c.en)
                                    .font(.rounded(15, .semibold))
                                    .foregroundStyle(on ? .white : Theme.ink)
                                    .padding(.horizontal, 14).padding(.vertical, 9)
                                    .background(Capsule().fill(on ? Theme.sambal : Theme.card)
                                        .shadow(color: Theme.kopi.opacity(on ? 0 : 0.07), radius: 5, y: 2))
                            }
                            .buttonStyle(.squish)
                        }
                    }
                }

                // A peek at how it shows up in your chats.
                HStack {
                    Spacer()
                    Text("Saya \(name.isEmpty ? "" : name + ", ")dari \(country.isEmpty ? "…" : country + ".")")
                        .font(.rounded(17, .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(ChatShape(mine: true).fill(Theme.sambal))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: country)
                }
                Text("You can change this any time.")
                    .font(.ui(13))
                    .foregroundStyle(Theme.inkSoft)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
