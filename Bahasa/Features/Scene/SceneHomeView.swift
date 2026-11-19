import SwiftUI

/// One Scene: its goal, the Rehearsal Loop ladder, culture notes and the lines you own.
struct SceneHomeView: View {
    let scene: RehearsalScene
    var initialStage: Stage?

    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var playing: PlayRequest?
    @State private var queued: Stage?
    @State private var showLive = false
    @State private var showProfile = false
    @State private var warmUp: WarmUp?
    @State private var didOpenInitial = false

    struct PlayRequest: Identifiable {
        let id = UUID()
        let stage: Stage
        var recall: [RehearsalState.RecallItem] = []
    }

    private var record: RehearsalState.SceneRecord { progress.rehearsal.record(scene.id) }
    private var tint: Color { scene.color }

    @ObservedObject private var speaker = Speaker.shared
    @State private var greeting: String?

    var body: some View {
        CozyPage(title: scene.title, subtitle: scene.titleEn, artHeight: 280, pinned: true) {
            heroArt
        } accessory: {
            topBar
        } content: {
            greetingBubble
            nextButton
            goalCard
            if let tip = scene.culture.first { tipCard(tip) }
            if !scene.warmUps.isEmpty { prep }
            yourLines
        }
        .fullScreenCover(item: $playing, onDismiss: runQueued) { request in
            ScenePlayerView(scene: scene, stage: request.stage, store: progress, recallItems: request.recall) { next in
                queued = next
            }
            .environmentObject(progress)
        }
        .sheet(isPresented: $showLive) {
            LiveCardView(scene: scene)
                .environmentObject(progress)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showProfile) {
            ProfileSheet()
                .environmentObject(progress)
                .presentationDetents([.medium, .large])
        }
        .fullScreenCover(item: Binding(
            get: { warmUp.flatMap { w in Curriculum.lesson(w.lessonID).map { WarmUpRequest(lesson: $0) } } },
            set: { if $0 == nil { warmUp = nil } }
        )) { request in
            if let unit = Curriculum.unit(for: request.lesson.id) {
                LessonPlayerView(lesson: request.lesson, unit: unit)
                    .environmentObject(progress)
            }
        }
        .onAppear {
            guard !didOpenInitial, let initialStage else { return }
            didOpenInitial = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { open(initialStage, force: true) }
        }
    }

    private struct WarmUpRequest: Identifiable {
        let lesson: Lesson
        var id: String { lesson.id }
    }

    private func runQueued() {
        guard let next = queued else { return }
        queued = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { open(next, force: true) }
    }

    private func open(_ stage: Stage, force: Bool = false) {
        guard force || progress.rehearsal.isUnlocked(stage, scene: scene.id) else { return }
        Haptics.select()
        switch stage {
        case .live:
            showLive = true
        case .recall:
            let due = progress.rehearsal.recallItems(for: scene.id).filter { $0.due <= Date() }
            let items = due.isEmpty ? progress.rehearsal.recallItems(for: scene.id) : due
            playing = PlayRequest(stage: .recall, recall: items)
        default:
            playing = PlayRequest(stage: stage)
        }
    }

    // MARK: Sections

    private var topBar: some View {
        HStack {
            Button {
                Haptics.tap()
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .buttonStyle(.squish)
            .accessibilityLabel("Close")
            Spacer()
            if record.stars > 0 || record.lived {
                ArtChip(text: record.lived ? "Lived" : String(repeating: "★", count: record.stars),
                        tint: record.lived ? Theme.sawah : Theme.kunyit)
            }
            Button {
                Haptics.tap()
                showProfile = true
            } label: {
                Image(systemName: "person.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .buttonStyle(.squish)
            .accessibilityLabel("About you")
        }
        .frame(maxWidth: .infinity)
    }

    /// The place. Tap it and the character says hello.
    private var heroArt: some View {
        let hello = progress.filler.fill(scene.node(scene.entry)?.them.text ?? "Halo!")
        let speaking = greeting != nil && speaker.speakingText == greeting
        return PlaceIllustration(scene: scene, speaking: speaking,
                                 expression: speaking ? .neutral : (record.lived ? .happy : .neutral),
                                 groundPad: 30)
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.pop()
                greeting = hello
                speaker.say(hello)
            }
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Says hello")
    }

    /// The character says their first line to you. Tap to hear it.
    private var greetingBubble: some View {
        let hello = progress.filler.fill(scene.node(scene.entry)?.them.text ?? "Halo!")
        let speaking = greeting != nil && speaker.speakingText == greeting
        return Button {
            Haptics.tap()
            greeting = hello
            speaker.say(hello)
        } label: {
            HStack(alignment: .bottom, spacing: 10) {
                CharacterPortrait(characterID: scene.character.id, tint: tint, size: 52, speaking: speaking)
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(scene.character.name)
                            .font(.rounded(12, .bold))
                            .foregroundStyle(tint)
                        Text(hello)
                            .font(.rounded(17, .semibold))
                            .foregroundStyle(Theme.ink)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: speaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(tint)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(ChatShape(mine: false).fill(Theme.card).shadow(color: Theme.kopi.opacity(0.08), radius: 8, y: 3))
            }
        }
        .buttonStyle(.squish)
        .accessibilityLabel("\(scene.character.name) says \(hello). Tap to hear it.")
    }

    /// One obvious next step.
    private var nextButton: some View {
        // The app picks the right kind of practice; the learner just presses one button.
        let stage = nextStage ?? .perform
        let fresh = record.rehearsals == 0
        let title = fresh ? "Start" : (nextStage == nil ? "Play again" : "Continue")
        let line = nextStage == nil ? "She'll say it a little differently" : stage.cozyLine
        return Button {
            Haptics.pop()
            open(stage, force: true)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: stage == .live ? "figure.walk" : "play.fill")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(.white.opacity(0.22)))
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.rounded(22, .heavy))
                    Text(line)
                        .font(.ui(14, .medium))
                        .opacity(0.85)
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(tint)
                    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(tint.darker(0.22)).offset(y: 4))
            )
        }
        .buttonStyle(.squish)
    }

    private var nextStage: Stage? {
        if !record.watched && record.stars == 0 { return .watch }
        if record.stars < 1 { return .rehearse }
        if !record.performPassed { return .perform }
        if !record.lived { return .live }
        if !progress.rehearsal.recallItems(for: scene.id).filter({ $0.due <= Date() }).isEmpty { return .recall }
        return nil
    }

    private var goalCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "flag.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(Circle().fill(tint.opacity(0.14)))
            Text(scene.goalSummary)
                .font(.ui(15, .medium))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cozyCard(padding: 14)
    }

    private func tipCard(_ tip: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.sawah)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Theme.sawah.opacity(0.14)))
            Text(tip)
                .font(.ui(15))
                .foregroundStyle(Theme.ink.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .cozyCard(padding: 14)
    }

    private var prep: some View {
        CozySection("Warm up") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(scene.warmUps, id: \.lessonID) { w in
                        Button {
                            Haptics.select()
                            warmUp = w
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: progress.isDone(lesson: w.lessonID) ? "checkmark" : "bolt.fill")
                                    .font(.system(size: 11, weight: .bold))
                                Text(w.title.components(separatedBy: " · ").first ?? w.title)
                                    .font(.rounded(14, .semibold))
                            }
                            .foregroundStyle(Theme.indigo)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(Theme.indigo.opacity(0.1)))
                        }
                        .buttonStyle(.squish)
                    }
                }
            }
            .scrollClipDisabled()
        }
    }

    @ViewBuilder
    private var yourLines: some View {
        let lines = progress.rehearsal.lines(for: scene.id)
        if !lines.isEmpty {
            CozySection("Your lines") {
                VStack(spacing: 0) {
                    ForEach(Array(lines.prefix(4).enumerated()), id: \.element.id) { i, line in
                        ExampleRow(indo: line.text, en: line.gloss, tint: tint)
                        if i < min(lines.count, 4) - 1 { Divider().overlay(Theme.line.opacity(0.7)) }
                    }
                }
                .cozyCard(padding: 14)
            }
        }
    }
}

extension Stage {
    /// A short, friendly line under the next-step button.
    var cozyLine: String {
        switch self {
        case .watch: return "Listen in first"
        case .rehearse: return "Your turn, with a little help"
        case .perform: return "Now in your own words"
        case .live: return "Ready for the real thing"
        case .recall: return "A quick refresher"
        }
    }
}

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(.ui(11, .bold))
            .tracking(1.1)
            .foregroundStyle(Theme.inkSoft)
    }
}
