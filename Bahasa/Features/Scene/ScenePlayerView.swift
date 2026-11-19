import SwiftUI

/// Plays one Rehearsal (Watch, Rehearse, Perform or Recall) of a Scene.
struct ScenePlayerView: View {
    @StateObject private var session: RehearsalSession
    @Environment(\.dismiss) private var dismiss
    @State private var lookup: WordLookup?

    var onNext: ((Stage) -> Void)?

    init(scene: RehearsalScene, stage: Stage, store: ProgressStore,
         recallItems: [RehearsalState.RecallItem] = [], onNext: ((Stage) -> Void)? = nil) {
        _session = StateObject(wrappedValue: RehearsalSession(scene: scene, stage: stage, store: store, recallItems: recallItems))
        self.onNext = onNext
    }

    private var scene: RehearsalScene { session.scene }
    private var tint: Color { scene.color }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                PlayerHeader(session: session, topInset: geo.safeAreaInsets.top) {
                    session.cancel()
                    dismiss()
                }
                Transcript(session: session)
                bottom
            }
        }
        .background(Theme.paper.ignoresSafeArea())
        .environment(\.openURL, OpenURLAction { url in
            guard let found = WordLink.lookup(from: url) else { return .systemAction }
            Haptics.select()
            lookup = found
            return .handled
        })
        .sheet(item: $lookup) { item in
            WordLookupSheet(lookup: item, tint: scene.color)
                .presentationDetents([.height(320), .medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .onAppear { session.start() }
        .onDisappear { session.cancel() }
    }

    @ViewBuilder
    private var bottom: some View {
        switch session.phase {
        case .done:
            SummaryCard(session: session, onClose: { dismiss() }, onNext: { stage in
                dismiss()
                onNext?(stage)
            })
            .transition(.move(edge: .bottom).combined(with: .opacity))
        case .listeningCheck:
            ListeningQuiz(checks: scene.listening, tint: tint) { right in
                session.finishListening(right: right)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        case .awaiting:
            InputPanel(session: session)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        case .watching, .typing, .resolving:
            if session.stage == .watch {
                WatchBar(session: session)
            }
        }
    }
}

// MARK: - Header

private struct PlayerHeader: View {
    @ObservedObject var session: RehearsalSession
    @ObservedObject private var speaker = Speaker.shared
    var topInset: CGFloat = 0
    let onClose: () -> Void

    private var scene: RehearsalScene { session.scene }

    private var herSpeaking: Bool {
        guard let line = session.herLine else { return false }
        return speaker.speakingText == line
    }

    /// The stage gets the most room while you're only listening; it shrinks when the input needs space.
    private var bandHeight: CGFloat {
        switch session.phase {
        case .watching, .listeningCheck: return 210
        case .done: return 150
        case .awaiting: return session.mode == .choose ? 160 : 118
        default: return session.stage == .watch ? 210 : 160
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: bandHeight)
                .frame(maxWidth: .infinity)
                .background(alignment: .bottom) {
                    PlaceIllustration(scene: scene, speaking: herSpeaking, expression: session.expression,
                                      mood: session.mood, compact: bandHeight < 130)
                        .frame(height: bandHeight + topInset)
                }
                .overlay(alignment: .top) {
                    HStack(spacing: 10) {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Theme.ink)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                        .buttonStyle(.squish)
                        .accessibilityLabel("Close")
                        Spacer()
                        PaceMenu(tint: scene.color)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }
            .overlay(alignment: .bottomLeading) { nameplate.padding(12) }
            .zIndex(1)
            .animation(.spring(response: 0.5, dampingFraction: 0.86), value: bandHeight)

            Group {
                if session.stage != .recall {
                    GoalStrip(goals: scene.goals, flags: session.flags, tint: scene.color)
                } else {
                    ProgressCapsule(fraction: session.recallTotal == 0 ? 0 : Double(session.recallIndex) / Double(session.recallTotal), tint: scene.color)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Theme.card)
            .overlay(alignment: .bottom) { Rectangle().fill(Theme.line).frame(height: 1) }
        }
    }

    private var nameplate: some View {
        HStack(spacing: 8) {
            CharacterPortrait(characterID: scene.character.id, tint: scene.color, size: 32,
                              speaking: herSpeaking, expression: session.expression)
            VStack(alignment: .leading, spacing: 0) {
                Text(scene.character.name)
                    .font(.ui(13, .semibold))
                    .foregroundStyle(Theme.ink)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.ui(11))
                        .lineLimit(1)
                        .foregroundStyle(session.phase == .typing ? scene.color : Theme.inkSoft)
                        .contentTransition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: subtitle)
                }
            }
        }
        .padding(.leading, 5)
        .padding(.trailing, 12)
        .padding(.vertical, 5)
        .background(Capsule().fill(.ultraThinMaterial))
        .overlay(Capsule().stroke(.white.opacity(0.5), lineWidth: 0.5))
    }

    private var subtitle: String {
        if session.phase == .typing { return "typing…" }
        if herSpeaking { return "speaking" }
        if session.stage == .perform { return session.mood.cue }
        return ""
    }
}

struct StagePill: View {
    let stage: Stage
    let tint: Color
    var onMaterial: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: stage.symbol)
                .font(.system(size: 10, weight: .bold))
            Text(stage.title)
                .font(.rounded(12))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            if onMaterial {
                Capsule().fill(.ultraThinMaterial)
            } else {
                Capsule().fill(tint.opacity(0.12))
            }
        }
    }
}

private struct GoalStrip: View {
    let goals: [GoalFlag]
    let flags: Set<String>
    let tint: Color

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(goals) { goal in
                    let done = flags.contains(goal.id)
                    HStack(spacing: 4) {
                        Image(systemName: done ? "checkmark.circle.fill" : (goal.optional ? "circle.dashed" : "circle"))
                            .font(.system(size: 11, weight: .bold))
                        Text(goal.label)
                            .font(.ui(12, .medium))
                    }
                    .foregroundStyle(done ? .white : (goal.optional ? Theme.inkSoft.opacity(0.8) : Theme.inkSoft))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(done ? Theme.benar : Theme.line.opacity(0.45)))
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: done)
                }
            }
        }
        .scrollClipDisabled()
    }
}

// MARK: - Transcript

private struct Transcript: View {
    @ObservedObject var session: RehearsalSession
    @ObservedObject private var speaker = Speaker.shared

    private var lastTheirID: UUID? {
        session.items.last(where: { if case .them = $0.kind { return true } else { return false } })?.id
    }

    /// True while the learner is at (or near) the bottom. Scrolling up to reread pauses auto-follow.
    @State private var following = true
    @State private var viewport: CGFloat = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(session.items) { item in
                        row(item)
                    }
                    if session.phase == .typing {
                        HStack(alignment: .bottom, spacing: 8) {
                            CharacterPortrait(characterID: session.scene.character.id, tint: session.scene.color, size: 34)
                            SceneTypingBubble(tint: session.scene.color)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.scale(scale: 0.8, anchor: .bottomLeading).combined(with: .opacity))
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .defaultScrollAnchor(.bottom)
            .modifier(FollowTracker(following: $following))
            // The visible area shrinks when the reply panel slides in; keep the newest line in view.
            .background(GeometryReader { g in
                Color.clear
                    .onAppear { viewport = g.size.height }
                    .onChange(of: g.size.height) { _, h in
                        viewport = h
                        settle(proxy)
                    }
            })
            .onChange(of: session.items.count) { _, _ in settle(proxy) }
            .onChange(of: session.phase) { _, _ in settle(proxy) }
            .onChange(of: session.revealed) { _, _ in settle(proxy) }
            .overlay(alignment: .bottomTrailing) {
                if !following {
                    Button {
                        Haptics.tap()
                        following = true
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { proxy.scrollTo("bottom", anchor: .bottom) }
                    } label: {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(session.scene.color).shadow(color: .black.opacity(0.15), radius: 6, y: 3))
                    }
                    .buttonStyle(.squish)
                    .padding(16)
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityLabel("Jump to the latest message")
                }
            }
        }
    }

    /// Scroll to the newest line now and again once layout and animations finish.
    private func settle(_ proxy: ScrollViewProxy) {
        guard following else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) { proxy.scrollTo("bottom", anchor: .bottom) }
        for delay in [0.25, 0.6] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard following else { return }
                withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    @ViewBuilder
    private func row(_ item: RehearsalSession.Item) -> some View {
        switch item.kind {
        case .narration(let text):
            Text(text)
                .font(.ui(13))
                .italic()
                .foregroundStyle(Theme.inkSoft)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
        case let .them(text, gloss, chips, reaction):
            let latest = item.id == lastTheirID
            HStack(alignment: .bottom, spacing: 8) {
            CharacterPortrait(characterID: session.scene.character.id, tint: session.scene.color, size: 34,
                              speaking: latest && speaker.speakingText == text,
                              expression: latest ? session.expression : .neutral, animated: latest)
                .opacity(latest ? 1 : 0.85)
            TheirLineBubble(
                text: text, gloss: gloss, chips: chips, reaction: reaction,
                tint: session.scene.color,
                textVisible: session.showText || session.revealed.contains(item.id) || reaction,
                glossVisible: session.revealed.contains(item.id),
                canRevealFree: !session.isPerformLike
            ) {
                Haptics.tap()
                if session.revealed.contains(item.id) {
                    session.revealed.remove(item.id)
                } else if session.isPerformLike && !session.showText && !reaction && item.nodeID == session.nodeID && session.phase == .awaiting {
                    session.use(.text)
                } else {
                    session.revealed.insert(item.id)
                }
            }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.scale(scale: 0.85, anchor: .bottomLeading).combined(with: .opacity))
        case let .you(text, gloss, grade):
            YourLineBubble(text: text, gloss: gloss, grade: grade, tint: session.scene.color)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .transition(.scale(scale: 0.85, anchor: .bottomTrailing).combined(with: .opacity))
        case let .coach(text, grade):
            CoachNote(text: text, grade: grade)
        }
    }
}

private struct TheirLineBubble: View {
    let text: String
    let gloss: String
    let chips: String?
    let reaction: Bool
    let tint: Color
    let textVisible: Bool
    let glossVisible: Bool
    let canRevealFree: Bool
    let onTap: () -> Void

    @State private var showChips = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if textVisible {
                TappableLine(text: text, underline: tint.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Waveform(seed: text, tint: tint)
                    .frame(height: 26)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onTap)
            }

            if showChips {
                WordByWord(line: text)
                    .padding(.vertical, 2)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topLeading)))
            }

            HStack(alignment: .bottom, spacing: 8) {
                if glossVisible {
                    Text(gloss)
                        .font(.ui(13))
                        .foregroundStyle(Theme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                        .onTapGesture(perform: onTap)
                } else {
                    Button(action: onTap) {
                        Text(textVisible ? "English" : (canRevealFree ? "show text" : "show text (hint)"))
                            .font(.rounded(12, .semibold))
                            .foregroundStyle(tint)
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 6)
                if textVisible {
                    Button {
                        Haptics.tap()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showChips.toggle() }
                    } label: {
                        Image(systemName: "text.word.spacing")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(tint)
                            .frame(width: 27, height: 27)
                            .background(Circle().fill(tint.opacity(showChips ? 0.24 : 0.12)))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Word by word")
                }
                SpeakerButton(text: text, slow: true, tint: tint, size: 12)
                SpeakerButton(text: text, tint: tint, size: 13)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .frame(maxWidth: 310, alignment: .leading)
        .background(
            ChatShape(mine: false)
                .fill(reaction ? tint.opacity(0.1) : Theme.card)
                .shadow(color: Theme.kopi.opacity(0.08), radius: 6, y: 3)
        )
    }
}

/// Stylised waveform shown instead of text, so the ear goes first.
/// Animates only while this exact line is playing.
private struct Waveform: View {
    let seed: String
    let tint: Color

    @ObservedObject private var speaker = Speaker.shared

    private var bars: [CGFloat] {
        var h = UInt64(5381)
        for b in seed.utf8 { h = h &* 33 &+ UInt64(b) }
        return (0..<min(34, max(10, seed.count))).map { _ in
            h = h &* 6364136223846793005 &+ 1442695040888963407
            return CGFloat(0.25 + Double((h >> 33) % 75) / 100)
        }
    }

    var body: some View {
        let bars = self.bars
        if speaker.isSpeaking(seed) {
            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSinceReferenceDate
                strip(bars, tint: tint.opacity(0.85)) { i, b in
                    b * (0.55 + 0.45 * abs(sin(t * 7 + Double(i) * 0.7)))
                }
            }
        } else {
            strip(bars, tint: tint.opacity(0.45)) { _, b in b }
        }
    }

    private func strip(_ bars: [CGFloat], tint: Color, height: @escaping (Int, CGFloat) -> CGFloat) -> some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(Array(bars.enumerated()), id: \.offset) { i, b in
                Capsule()
                    .fill(tint)
                    .frame(width: 3, height: 26 * height(i, b))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel("Audio line. Tap to show text.")
    }
}

private struct YourLineBubble: View {
    let text: String
    let gloss: String
    let grade: Grade?
    let tint: Color

    private var failed: Bool { grade.map { !$0.passes } ?? false }

    var body: some View {
        VStack(alignment: .trailing, spacing: 3) {
            TappableLine(text: text, color: failed ? Theme.ink : .white,
                         underline: failed ? Theme.salah.opacity(0.5) : .white.opacity(0.5), alignment: .trailing)
                .strikethrough(failed, color: Theme.salah.opacity(0.6))
            if !gloss.isEmpty {
                Text(gloss)
                    .font(.ui(12))
                    .foregroundStyle(failed ? Theme.inkSoft : .white.opacity(0.82))
                    .multilineTextAlignment(.trailing)
            }
            if let grade, grade != .natural {
                Text(grade.label.uppercased())
                    .font(.ui(9, .bold))
                    .tracking(0.8)
                    .foregroundStyle(failed ? grade.color : .white.opacity(0.9))
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .frame(maxWidth: 300, alignment: .trailing)
        .background(
            ChatShape(mine: true)
                .fill(failed ? Theme.card : tint)
                .shadow(color: (failed ? Theme.kopi : tint).opacity(0.15), radius: 6, y: 3)
        )
        .overlay(
            ChatShape(mine: true)
                .stroke(failed ? (grade?.color ?? Theme.salah).opacity(0.5) : .clear, style: StrokeStyle(lineWidth: 1.2, dash: [4, 3]))
        )
    }
}

private struct CoachNote: View {
    let text: String
    let grade: Grade

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: grade == .natural ? "quote.bubble.fill" : "lightbulb.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(grade == .natural ? Theme.benar : Theme.kunyit)
                .padding(.top, 1)
            Text(text)
                .font(.ui(13))
                .foregroundStyle(Theme.ink.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill((grade == .natural ? Theme.benar : Theme.kunyit).opacity(0.11))
        )
        .padding(.horizontal, 12)
    }
}

private struct SceneTypingBubble: View {
    let tint: Color

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    let phase = sin(t * 6 - Double(index) * 0.9)
                    Circle()
                        .fill(tint)
                        .frame(width: 7, height: 7)
                        .opacity(0.3 + 0.6 * max(0, phase))
                        .offset(y: -2.5 * max(0, phase))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(ChatShape(mine: false).fill(Theme.card).shadow(color: Theme.kopi.opacity(0.08), radius: 6, y: 3))
    }
}

// MARK: - Watch bar

/// Chat speed, one tap from any chat: Relaxed, Normal or Like a local, plus "Wait for me".
struct PaceMenu: View {
    var tint: Color
    @AppStorage(ChatPace.storageKey) private var pace: ChatPace = .normal
    @AppStorage(ChatPace.waitKey) private var waitForMe = false

    var body: some View {
        Menu {
            Picker("Chat speed", selection: $pace) {
                ForEach(ChatPace.allCases) { p in
                    Label(p.title, systemImage: p.symbol).tag(p)
                }
            }
            Toggle(isOn: $waitForMe) {
                Label("Wait for me", systemImage: "hand.tap")
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: pace.symbol)
                    .font(.system(size: 12, weight: .bold))
                Text(pace == .local ? "Local" : pace.title)
                    .font(.rounded(13, .bold))
            }
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 12)
            .frame(height: 34)
            .background(Capsule().fill(Theme.card.opacity(0.92)).shadow(color: Theme.kopi.opacity(0.15), radius: 4, y: 2))
            .contentShape(Capsule())
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .onChange(of: pace) { _, _ in Haptics.select() }
        .accessibilityLabel("Chat speed: \(pace.title)")
    }
}

private struct WatchBar: View {
    @ObservedObject var session: RehearsalSession

    var body: some View {
        if session.waitingForTap {
            Button {
                Haptics.tap()
                session.continueTapped()
            } label: {
                HStack(spacing: 8) {
                    Text("Next")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .font(.rounded(17, .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(session.scene.color))
            }
            .buttonStyle(.squish)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Theme.card.shadow(color: Theme.ink.opacity(0.06), radius: 12, y: -4).ignoresSafeArea(edges: .bottom))
            .transition(.opacity)
        } else {
            listening
        }
    }

    private var listening: some View {
        HStack {
            Image(systemName: "ear")
                .foregroundStyle(session.scene.color)
            Text("Just listen")
                .font(.rounded(15, .semibold))
                .foregroundStyle(Theme.inkSoft)
            Spacer()
            Toggle("Text", isOn: $session.showText)
                .labelsHidden()
                .tint(session.scene.color)
            Text("Text")
                .font(.ui(12, .medium))
                .foregroundStyle(Theme.inkSoft)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Theme.card.shadow(color: Theme.ink.opacity(0.06), radius: 12, y: -4).ignoresSafeArea(edges: .bottom))
    }
}

// MARK: - Input

private struct InputPanel: View {
    @ObservedObject var session: RehearsalSession
    @State private var showEnglish = false
    @State private var built: String?
    @State private var typed = ""
    @StateObject private var speech = SpeechInput()
    @FocusState private var fieldFocused: Bool

    private var tint: Color { session.scene.color }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            switch session.mode {
            case .choose: choose
            case .build: build
            case .type: typeField
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 16)
        .background(Theme.paper.shadow(color: Theme.ink.opacity(0.07), radius: 14, y: -4))
        .shake(session.shake)
        .onChange(of: speech.transcript) { _, text in
            if !text.isEmpty { typed = text }
        }
        .onChange(of: speech.listening) { was, now in
            if was && !now && !typed.isEmpty { send() }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            if session.mode != .build {
                Text(kicker)
                    .font(.rounded(15, .bold))
                    .foregroundStyle(Theme.ink)
            }
            Spacer()
            if session.mode == .choose {
                Button {
                    Haptics.tap()
                    withAnimation(.easeInOut(duration: 0.2)) { showEnglish.toggle() }
                } label: {
                    Image(systemName: showEnglish ? "character.bubble.fill" : "character.bubble")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 34, height: 30)
                        .accessibilityLabel(showEnglish ? "Hide English" : "Show English")
                }
                .buttonStyle(.plain)
            }
            if session.stage == .rehearse && session.mode == .build {
                Button {
                    Haptics.tap()
                    session.switchToChoose()
                } label: {
                    Text("Options")
                        .font(.rounded(13, .bold))
                        .foregroundStyle(tint)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var kicker: String {
        switch session.mode {
        case .choose: return "Your turn"
        case .build: return "Build it"
        case .type: return session.stage == .recall ? "What do you say?" : "Your turn"
        }
    }

    // Choose

    private var choose: some View {
        VStack(spacing: 9) {
            ForEach(session.options) { option in
                let out = session.ruledOut.contains(option.id)
                Button {
                    session.choose(option)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.filler.fill(option.text))
                            .font(.display(17))
                            .foregroundStyle(out ? Theme.inkSoft.opacity(0.5) : Theme.ink)
                            .strikethrough(out)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        if showEnglish {
                            Text(session.filler.fill(option.gloss))
                                .font(.ui(12))
                                .foregroundStyle(Theme.inkSoft)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ChatShape(mine: true).fill(out ? Theme.line.opacity(0.3) : Theme.card))
                    .overlay(ChatShape(mine: true).stroke(out ? Theme.line : tint.opacity(0.35), lineWidth: 1.5))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.squish)
                .disabled(out)
            }
        }
    }

    // Build

    @ViewBuilder
    private var build: some View {
        if let target = session.buildTarget, let node = session.currentNode {
            let answer = session.filler.fill(target.text)
                .components(separatedBy: CharacterSet.punctuationCharacters.subtracting(CharacterSet(charactersIn: "-")))
                .joined()
            VStack(spacing: 14) {
                BuildStepView(
                    build: Build(english: session.filler.fill(target.gloss), answer: answer,
                                 extras: node.extras.isEmpty ? autoExtras(node, answer: answer) : node.extras, why: ""),
                    tint: tint, locked: false, answer: $built
                )
                .id(session.buildAttempt)
                ChunkyButton(title: "Check", color: tint, enabled: !(built ?? "").isEmpty) {
                    let text = built ?? ""
                    built = nil
                    session.submitBuilt(text)
                }
            }
        }
    }

    private func autoExtras(_ node: SceneNode, answer: String) -> [String] {
        let have = Set(answer.lowercased().split(separator: " ").map(String.init))
        let pool = node.replies.filter { !$0.grade.passes }
            .flatMap { session.filler.fill($0.text).split(separator: " ") }
            .map { String($0).trimmingCharacters(in: .punctuationCharacters) }
            .filter { !have.contains($0.lowercased()) && !$0.isEmpty }
        return Array(Set(pool)).shuffled().prefix(2).map { $0 }
    }

    // Type / speak

    private var typeField: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let unavailable = speech.unavailable {
                Text(unavailable)
                    .font(.ui(12))
                    .foregroundStyle(Theme.inkSoft)
            }
            HStack(spacing: 10) {
                TextField(placeholder, text: $typed, axis: .vertical)
                    .font(.display(18))
                    .foregroundStyle(Theme.ink)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled()
                    .focused($fieldFocused)
                    .submitLabel(.send)
                    .onSubmit(send)
                    .lineLimit(1...3)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(speech.listening ? tint : Theme.line, lineWidth: speech.listening ? 2 : 1)
                    )

                if typed.trimmingCharacters(in: .whitespaces).isEmpty || speech.listening {
                    Button {
                        fieldFocused = false
                        speech.toggle()
                    } label: {
                        Image(systemName: speech.listening ? "stop.fill" : "mic.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(Circle().fill(speech.listening ? Theme.salah : tint))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(speech.listening ? "Stop listening" : "Speak your reply")
                } else {
                    Button(action: send) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(Circle().fill(tint))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Send")
                }
            }

            HStack(spacing: 8) {
                AssistChip(title: "Text", symbol: "text.bubble", used: session.nodeAssists.contains(.text), tint: tint) { session.use(.text) }
                AssistChip(title: "First word", symbol: "character.cursor.ibeam", used: session.nodeAssists.contains(.firstWord), tint: tint) { session.use(.firstWord) }
                AssistChip(title: "Options", symbol: "list.bullet", used: session.nodeAssists.contains(.options), tint: tint) { session.use(.options) }
                Spacer(minLength: 0)
                if session.stage == .perform {
                    Text("hints \(session.assists)")
                        .font(.ui(11, .medium))
                        .foregroundStyle(session.assists > 2 ? Theme.salah : Theme.inkSoft.opacity(0.7))
                }
            }
        }
    }

    private var placeholder: String {
        if let first = session.firstWordHint { return "\(first)…" }
        return speech.listening ? "Listening…" : "Type or tap the mic"
    }

    private func send() {
        let text = typed
        typed = ""
        speech.stop()
        session.submitTyped(text)
    }
}

private struct AssistChip: View {
    let title: String
    let symbol: String
    let used: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 10, weight: .bold))
                Text(title)
                    .font(.rounded(12, .semibold))
            }
            .foregroundStyle(used ? Theme.inkSoft.opacity(0.5) : tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(used ? Theme.line.opacity(0.4) : tint.opacity(0.1)))
        }
        .buttonStyle(.plain)
        .disabled(used)
    }
}

// MARK: - Watch quiz

private struct ListeningQuiz: View {
    let checks: [ListeningCheck]
    let tint: Color
    let onDone: (Int) -> Void

    @State private var index = 0
    @State private var picked: String?
    @State private var right = 0
    @State private var shuffled: [[String]]

    init(checks: [ListeningCheck], tint: Color, onDone: @escaping (Int) -> Void) {
        self.checks = checks
        self.tint = tint
        self.onDone = onDone
        _shuffled = State(initialValue: checks.map { $0.options.shuffled() })
    }

    var body: some View {
        if index < checks.count {
            let check = checks[index]
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Did you catch it? \(index + 1)/\(checks.count)")
                        .font(.rounded(14, .bold))
                        .foregroundStyle(Theme.inkSoft)
                    Spacer()
                }
                Text(check.question)
                    .font(.display(21, .semibold))
                    .foregroundStyle(Theme.ink)
                VStack(spacing: 8) {
                    ForEach(shuffled[index], id: \.self) { option in
                        OptionButton(text: option, serif: false, selected: picked == option || (picked != nil && option == check.answer),
                                     tint: color(for: option), locked: false) {
                            guard picked == nil else { return }
                            Haptics.select()
                            picked = option
                            if option == check.answer { right += 1; Haptics.correct() } else { Haptics.wrong() }
                        }
                    }
                }
                ChunkyButton(title: index == checks.count - 1 ? "Finish" : "Next", color: tint, enabled: picked != nil) {
                    if index == checks.count - 1 {
                        onDone(right)
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            index += 1
                            picked = nil
                        }
                    }
                }
            }
            .padding(18)
            .background(Theme.paper.shadow(color: Theme.ink.opacity(0.07), radius: 14, y: -4))
        }
    }

    private func color(for option: String) -> Color {
        guard let picked else { return tint }
        if option == checks[index].answer { return Theme.benar }
        return option == picked ? Theme.salah : tint
    }
}

// MARK: - Summary

private struct SummaryCard: View {
    @ObservedObject var session: RehearsalSession
    let onClose: () -> Void
    let onNext: (Stage) -> Void

    private var o: RehearsalSession.Outcome { session.outcome }
    private var tint: Color { session.scene.color }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    CharacterPortrait(characterID: session.scene.character.id, tint: tint, size: 64,
                                      expression: o.goalReached || session.stage == .watch || session.stage == .recall ? .happy : .neutral)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.rounded(24, .heavy))
                            .foregroundStyle(Theme.ink)
                        Text(subtitle)
                            .font(.ui(14, .medium))
                            .foregroundStyle(Theme.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(ChatShape(mine: false).fill(Theme.paper))
                    Spacer(minLength: 0)
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill").font(.system(size: 11, weight: .bold))
                        Text("+\(o.xp)").font(.rounded(15))
                    }
                    .foregroundStyle(Theme.kunyit)
                }

                if session.stage == .rehearse || session.stage == .perform {
                    StarRow(stars: o.stars, tint: tint)
                    stats
                }

                if !o.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes")
                            .font(.rounded(15, .bold))
                            .foregroundStyle(Theme.ink)
                        ForEach(Array(o.notes.enumerated()), id: \.offset) { _, n in
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(n.grade.label.uppercased())
                                        .font(.ui(9, .bold))
                                        .foregroundStyle(n.grade.color)
                                    Text(n.text)
                                        .font(.display(15))
                                        .foregroundStyle(Theme.ink)
                                }
                                Text(n.note)
                                    .font(.ui(13))
                                    .foregroundStyle(Theme.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .cardStyle(radius: 16, padding: 14)
                }

                if let next = nextStage {
                    ChunkyButton(title: nextTitle(next), color: tint) { onNext(next) }
                }
                Button("Back to the scene", action: onClose)
                    .font(.rounded(15))
                    .foregroundStyle(tint)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .padding(20)
        }
        .frame(maxHeight: 470)
        .fixedSize(horizontal: false, vertical: true)
        .background(Theme.card.shadow(color: Theme.ink.opacity(0.08), radius: 16, y: -4))
        .overlay(alignment: .top) {
            if o.stars >= 2 { ConfettiBurst().frame(height: 400).offset(y: -300) }
        }
    }

    private var stats: some View {
        HStack(spacing: 10) {
            Stat(value: o.goalReached ? "✓" : "–", label: "goal", tint: o.goalReached ? Theme.benar : Theme.inkSoft)
            if session.stage == .perform {
                Stat(value: "\(o.assists)", label: "hints", tint: o.assists > 2 ? Theme.salah : Theme.ink)
            }
            Stat(value: "+\(o.newLines)", label: "Your Lines", tint: tint)
            Stat(value: "\(o.queued)", label: "to recall", tint: Theme.kunyit)
        }
    }

    private var title: String {
        switch session.stage {
        case .watch: return o.listeningRight == session.scene.listening.count ? "Dengar baik!" : "Pelan-pelan aja"
        case .rehearse: return o.goalReached ? "Bagus!" : "Hampir!"
        case .perform: return o.performPassed ? "Bagus sekali!" : "Hampir!"
        case .recall: return "Ingat!"
        case .live: return ""
        }
    }

    private var subtitle: String {
        switch session.stage {
        case .watch:
            let total = session.scene.listening.count
            return o.listeningRight == total ? "You caught every bit." : "You caught \(o.listeningRight) of \(total). It gets easier."
        case .rehearse:
            return "Nice. Next time, no options."
        case .perform:
            if o.performPassed {
                return o.stars == 3 ? "No hints, all natural. You're ready." : "All in your own words. You're ready."
            }
            return "You got there with a few hints. Once more?"
        case .recall:
            return "\(o.recallRight) of \(o.recalled) came back first time."
        case .live:
            return ""
        }
    }

    private var nextStage: Stage? {
        switch session.stage {
        case .watch: return .rehearse
        case .rehearse: return .perform
        case .perform: return o.performPassed ? .live : .perform
        default: return nil
        }
    }

    private func nextTitle(_ stage: Stage) -> String {
        if stage == .perform && session.stage == .perform { return "Try again" }
        return "Continue"
    }
}

struct StarRow: View {
    let stars: Int
    let tint: Color
    var size: CGFloat = 26

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...3, id: \.self) { i in
                Image(systemName: i <= stars ? "star.fill" : "star")
                    .font(.system(size: size, weight: .semibold))
                    .foregroundStyle(i <= stars ? Theme.kunyit : Theme.line)
                    .scaleEffect(i <= stars ? 1 : 0.9)
            }
        }
    }
}

private struct Stat: View {
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.rounded(20))
                .foregroundStyle(tint)
            Text(label)
                .font(.ui(11))
                .foregroundStyle(Theme.inkSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.paper))
    }
}

/// A chat bubble: round everywhere except the corner nearest the speaker.
struct ChatShape: Shape {
    let mine: Bool

    func path(in rect: CGRect) -> Path {
        UnevenRoundedRectangle(topLeadingRadius: 20,
                               bottomLeadingRadius: mine ? 20 : 6,
                               bottomTrailingRadius: mine ? 6 : 20,
                               topTrailingRadius: 20,
                               style: .continuous)
            .path(in: rect)
    }
}

/// Tracks whether the chat is scrolled to the bottom (iOS 18+). On iOS 17 it always follows.
private struct FollowTracker: ViewModifier {
    @Binding var following: Bool
    /// Only the learner's own drag can turn following off; new messages growing the content can't.
    @State private var userDriven = false

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .onScrollPhaseChange { _, phase in
                    userDriven = phase == .interacting || phase == .decelerating
                }
                .onScrollGeometryChange(for: Bool.self) { geo in
                    geo.contentOffset.y + geo.containerSize.height >= geo.contentSize.height - 80
                } action: { _, atBottom in
                    let next = atBottom ? true : (userDriven ? false : following)
                    if next != following {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { following = next }
                    }
                }
        } else {
            content
        }
    }
}
