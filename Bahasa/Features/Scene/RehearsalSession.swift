import SwiftUI

/// Drives one Rehearsal of a Scene at one Stage: the conversation graph, grading,
/// assists, and what gets written back to the store at the end.
@MainActor
final class RehearsalSession: ObservableObject {
    enum Phase: Equatable {
        case typing          // character is "typing"
        case watching        // Watch auto-play running
        case awaiting        // learner's turn
        case resolving       // reply shown, reaction/next pending
        case listeningCheck  // Watch quiz
        case done
    }

    enum InputMode { case choose, build, type }

    enum Assist: String { case text, firstWord, options }

    struct Item: Identifiable {
        enum Kind {
            case narration(String)
            case them(text: String, gloss: String, chips: String?, reaction: Bool)
            case you(text: String, gloss: String, grade: Grade?)
            case coach(String, Grade)
        }
        let id = UUID()
        let kind: Kind
        let nodeID: String?
    }

    struct Said { let nodeID: String; let text: String; let gloss: String }

    struct Outcome {
        var goalReached = false
        var stars = 0
        var performPassed = false
        var assists = 0
        var nonNatural = 0
        var newLines = 0
        var queued = 0
        var recalled = 0
        var recallRight = 0
        var listeningRight = 0
        var notes: [(text: String, note: String, grade: Grade)] = []
        var xp = 0
    }

    let scene: RehearsalScene
    let stage: Stage
    let mood: Mood
    let filler: SlotFiller
    let matcher: Matcher
    private let store: ProgressStore

    @Published var items: [Item] = []
    @Published var phase: Phase = .typing
    @Published var nodeID: String?
    @Published var flags: Set<String> = []
    @Published var mode: InputMode = .choose
    @Published var options: [ReplyOption] = []
    @Published var ruledOut: Set<UUID> = []
    @Published var buildTarget: ReplyOption?
    @Published var buildAttempt = 0
    @Published var revealed: Set<UUID> = []
    @Published var showText: Bool
    @Published var firstWordHint: String?
    @Published var nodeAssists: Set<Assist> = []
    @Published var shake: CGFloat = 0
    @Published var outcome = Outcome()
    @Published var recallIndex = 0
    /// The character's line currently being voiced, so the illustration can animate her mouth.
    @Published var herLine: String?
    @Published var expression: CharacterExpression = .neutral

    private(set) var assists = 0
    private var nonNatural = 0
    private var missedNodes: Set<String> = []
    private var assistedNodes: Set<String> = []
    private var cleanNodes: [String] = []
    private var said: [Said] = []
    private var wrongAtNode = 0
    private var presented = 0
    private var notes: [(String, String, Grade)] = []
    private var recallQueue: [RehearsalState.RecallItem] = []
    private var recallRight = 0
    private var cancelled = false

    init(scene: RehearsalScene, stage: Stage, store: ProgressStore, recallItems: [RehearsalState.RecallItem] = []) {
        self.scene = scene
        self.stage = stage
        self.store = store
        self.filler = store.filler
        self.matcher = Matcher(pack: SceneLibrary.pack, filler: store.filler)
        self.recallQueue = recallItems
        // Rehearse uses the default mood; Perform picks one the learner hasn't cleared yet (§8.3).
        if stage == .perform {
            let cleared = store.rehearsal.record(scene.id).clearedMoods
            let fresh = scene.character.moods.filter { !cleared.contains($0) }
            self.mood = (fresh.isEmpty ? scene.character.moods : fresh).randomElement() ?? scene.character.defaultMood
        } else {
            self.mood = scene.character.defaultMood
        }
        // Ear before eye: Watch and Perform start with their text hidden.
        self.showText = stage == .rehearse
    }

    var currentNode: SceneNode? { nodeID.flatMap(scene.node) }
    var isPerformLike: Bool { stage == .perform || stage == .recall }
    var recallTotal: Int { recallQueue.count }

    // MARK: - Flow

    func start() {
        guard items.isEmpty else { return }
        items.append(Item(kind: .narration(stage == .recall ? "Callbacks from \(scene.titleEn.lowercased())." : scene.setting), nodeID: nil))
        Task {
            await pause(0.5)
            if stage == .recall {
                await presentRecall()
            } else {
                await present(scene.entry)
            }
        }
    }

    func cancel() {
        cancelled = true
        Speaker.shared.stop()
        continueTapped()
    }

    // MARK: - Pace

    /// Set while a listening chat holds for the learner ("Wait for me" in chat speed).
    @Published private(set) var waitingForTap = false
    private var tapContinuation: CheckedContinuation<Void, Never>?

    /// A pause between lines, scaled by the learner's chat speed.
    private func pause(_ seconds: Double) async {
        guard !cancelled else { return }
        try? await Task.sleep(for: .seconds(seconds * ChatPace.current.pauseScale))
    }

    /// Holds until the learner taps Next, when "Wait for me" is on. Returns at once otherwise.
    private func waitForLearner() async {
        guard ChatPace.waitForMe, !cancelled else { return }
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            tapContinuation = c
            waitingForTap = true
        }
    }

    func continueTapped() {
        waitingForTap = false
        let c = tapContinuation
        tapContinuation = nil
        c?.resume()
    }

    private func present(_ id: String) async {
        guard !cancelled, let node = scene.node(id) else { return }
        nodeID = id
        wrongAtNode = 0
        ruledOut = []
        firstWordHint = nil
        nodeAssists = []
        presented += 1

        if let narration = node.narration {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                items.append(Item(kind: .narration(narration), nodeID: id))
            }
            await pause(0.6)
        }

        phase = .typing
        await pause(stage == .watch ? 0.8 : 1.0)
        guard !cancelled else { return }
        let line = node.line(for: mood, casual: isPerformLike)
        let text = filler.fill(line.text)
        expression = .neutral
        herLine = text
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            items.append(Item(kind: .them(text: text, gloss: filler.fill(line.gloss), chips: line.chips, reaction: false), nodeID: id))
        }
        phase = stage == .watch ? .watching : .resolving
        await speak(text, as: scene.character.id)

        if node.isEnd {
            await pause(0.5)
            finish()
            return
        }

        if stage == .watch {
            await modelReply(node)
        } else {
            setUpInput(for: node)
            phase = .awaiting
        }
    }

    /// Watch: the model learner answers with the first Natural reply.
    private func modelReply(_ node: SceneNode) async {
        phase = .watching
        guard let reply = node.naturals.first else { return }
        await waitForLearner()
        await pause(0.7)
        guard !cancelled else { return }
        let text = filler.fill(reply.text)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            items.append(Item(kind: .you(text: text, gloss: filler.fill(reply.gloss), grade: nil), nodeID: node.id))
        }
        flags.formUnion(reply.sets)
        expression = .happy
        await speak(text, as: "learner")
        await waitForLearner()
        await pause(0.3)
        if let next = reply.nextNode(for: mood) { await present(next) }
    }

    private func setUpInput(for node: SceneNode) {
        switch stage {
        case .rehearse:
            // Support fades: Choose for the first two turns, Build after, Build always on focus nodes.
            mode = (node.focus != nil || presented > 2) ? .build : .choose
        default:
            mode = .type
        }
        let natural = node.naturals.randomElement()
        let wrong = node.replies.filter { !$0.grade.passes }.shuffled()
        let understood = node.replies.filter { $0.grade == .understood }.shuffled()
        var picks = [natural].compactMap { $0 } + Array(wrong.prefix(2))
        if picks.count < 3, let u = understood.first { picks.append(u) }
        options = picks.shuffled()
        buildTarget = node.naturals.first
        buildAttempt += 1
    }

    // MARK: - Learner input

    func choose(_ option: ReplyOption) {
        guard phase == .awaiting, !ruledOut.contains(option.id) else { return }
        Haptics.select()
        respond(with: option, said: filler.fill(option.text))
    }

    func submitBuilt(_ text: String) {
        guard phase == .awaiting, let node = currentNode else { return }
        if let hit = matcher.match(text, in: node) {
            respond(with: hit.option, said: filler.fill(hit.option.text))
        } else {
            notUnderstood(said: text, node: node)
        }
    }

    func submitTyped(_ raw: String) {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard phase == .awaiting, !text.isEmpty, let node = currentNode else { return }
        if let hit = matcher.match(text, in: node) {
            respond(with: hit.option, said: Self.tidy(text),
                    canonical: personalFill(hit.option.text, said: text),
                    gloss: personalFill(hit.option.gloss, said: text))
        } else {
            notUnderstood(said: Self.tidy(text), node: node)
        }
    }

    func use(_ assist: Assist) {
        guard phase == .awaiting, let node = currentNode, !nodeAssists.contains(assist) else { return }
        Haptics.tap()
        nodeAssists.insert(assist)
        if isPerformLike {
            assists += 1
            assistedNodes.insert(node.id)
        }
        switch assist {
        case .text:
            if let last = items.last(where: { if case .them = $0.kind { return $0.nodeID == node.id } else { return false } }) {
                revealed.insert(last.id)
            }
        case .firstWord:
            if let first = node.naturals.first.map({ filler.fill($0.text) })?.split(separator: " ").first {
                firstWordHint = String(first).trimmingCharacters(in: .punctuationCharacters)
            }
        case .options:
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { mode = .choose }
        }
    }

    func switchToChoose() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { mode = .choose }
    }

    /// Fills slots with the value the learner actually said ("Kanada"), not the profile fallback.
    private func personalFill(_ template: String, said: String) -> String {
        var out = template
        for slot in Slot.allCases where out.contains(slot.token) {
            if let value = matcher.slotValue(in: said, for: slot) {
                out = out.replacingOccurrences(of: slot.token, with: value)
            }
        }
        return filler.fill(out)
    }

    /// `text` is what appears in the bubble (the learner's own typing); `canonical` is the clean
    /// line that goes into Your Lines.
    private func respond(with option: ReplyOption, said text: String, canonical: String? = nil, gloss override: String? = nil) {
        guard let node = currentNode else { return }
        phase = .resolving
        let gloss = override ?? filler.fill(option.gloss)
        let owned = canonical ?? filler.fill(option.text)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            items.append(Item(kind: .you(text: text, gloss: gloss, grade: option.grade), nodeID: node.id))
        }

        if option.grade.passes {
            option.grade == .natural ? Haptics.correct() : Haptics.select()
            expression = option.grade == .natural ? .happy : .neutral
            if option.grade == .understood {
                nonNatural += 1
                if let coach = option.coach {
                    notes.append((text, filler.fill(coach), .understood))
                }
            }
            flags.formUnion(option.sets)
            said.append(Said(nodeID: node.id, text: owned, gloss: gloss))
            if wrongAtNode == 0 && !assistedNodes.contains(node.id) { cleanNodes.append(node.id) }

            if stage == .recall {
                recallRight += 1
                store.mutateRehearsal { $0.review(recallQueue[recallIndex].id, correct: wrongAtNode == 0) }
            }

            Task {
                await speak(text, as: "learner")
                if option.grade == .understood, let coach = option.coach {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        items.append(Item(kind: .coach(filler.fill(coach), .understood), nodeID: node.id))
                    }
                    await pause(1.2)
                }
                await pause(0.3)
                if stage == .recall {
                    await advanceRecall()
                } else if let next = option.nextNode(for: mood) {
                    await present(next)
                } else {
                    finish()
                }
            }
        } else {
            wrong(node: node, option: option, reaction: option.reaction, coach: option.coach)
        }
    }

    private func notUnderstood(said text: String, node: SceneNode) {
        phase = .resolving
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            items.append(Item(kind: .you(text: text, gloss: "", grade: .missed), nodeID: node.id))
        }
        let reaction = scene.character.confused.randomElement()
        let coach: String
        if wrongAtNode >= 1, let n = node.naturals.first {
            coach = "Try: \(filler.fill(n.text))"
        } else if stage == .rehearse {
            coach = "Not quite. Rearrange the tiles and check again."
        } else {
            coach = "She didn't catch that. Try again, or take a hint."
        }
        wrong(node: node, option: nil, reaction: reaction, coach: coach)
    }

    /// The world reacts first, then the coach note, then a retry (§3.6).
    private func wrong(node: SceneNode, option: ReplyOption?, reaction: Utterance?, coach: String?) {
        Haptics.wrong()
        withAnimation { expression = .confused }
        wrongAtNode += 1
        missedNodes.insert(node.id)
        if let option { ruledOut.insert(option.id) }
        withAnimation(.easeInOut(duration: 0.45)) { shake += 1 }
        if let option, let coach {
            notes.append((filler.fill(option.text), filler.fill(coach), option.grade))
        }

        Task {
            await pause(0.5)
            phase = .typing
            await pause(0.8)
            guard !cancelled else { return }
            if let reaction {
                let text = filler.fill(reaction.text)
                herLine = text
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    items.append(Item(kind: .them(text: text, gloss: filler.fill(reaction.gloss), chips: nil, reaction: true), nodeID: node.id))
                }
                phase = .resolving
                await speak(text, as: scene.character.id)
            }
            if let coach {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    items.append(Item(kind: .coach(filler.fill(coach), option?.grade ?? .missed), nodeID: node.id))
                }
            }
            if stage == .recall {
                store.mutateRehearsal { $0.review(recallQueue[recallIndex].id, correct: false) }
                if let n = node.naturals.first {
                    await pause(0.6)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        items.append(Item(kind: .coach("The line: \(filler.fill(n.text))", .natural), nodeID: node.id))
                    }
                    await speak(filler.fill(n.text), as: "learner")
                }
                await pause(1.2)
                await advanceRecall()
                return
            }
            if stage == .rehearse, mode == .build { buildAttempt += 1 }
            phase = .awaiting
        }
    }

    // MARK: - Recall

    private func presentRecall() async {
        guard recallIndex < recallQueue.count else {
            finish()
            return
        }
        await present(recallQueue[recallIndex].nodeID)
    }

    private func advanceRecall() async {
        recallIndex += 1
        await pause(0.4)
        await presentRecall()
    }

    // MARK: - Watch quiz

    func finishListening(right: Int) {
        outcome.listeningRight = right
        finish()
    }

    // MARK: - End

    private func finish() {
        guard phase != .done else { return }
        if stage == .watch, phase != .listeningCheck {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { phase = .listeningCheck }
            return
        }
        commit()
        expression = outcome.goalReached || stage == .recall || stage == .watch ? .happy : .neutral
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { phase = .done }
        Haptics.correct()
    }

    private func commit() {
        var o = Outcome()
        o.goalReached = scene.requiredGoals.allSatisfy { flags.contains($0.id) }
        o.assists = assists
        o.nonNatural = nonNatural
        o.notes = notes.map { (text: $0.0, note: $0.1, grade: $0.2) }
        o.queued = (stage == .rehearse || stage == .perform) ? missedNodes.union(assistedNodes).count : 0
        o.listeningRight = outcome.listeningRight
        o.recalled = recallQueue.count
        o.recallRight = recallRight

        switch stage {
        case .watch:
            o.xp = 5
        case .rehearse:
            o.stars = o.goalReached ? 1 : 0
            o.xp = 10
        case .perform:
            if o.goalReached && assists <= 2 {
                o.performPassed = true
                o.stars = (assists == 0 && nonNatural == 0 && missedNodes.isEmpty) ? 3 : 2
            }
            o.xp = 10 + o.stars * 5
        case .recall:
            o.xp = 5 + recallRight * 2
        case .live:
            break
        }

        let existing = Set(store.rehearsal.lines(for: scene.id).map(\.text))
        let fresh = said.filter { !existing.contains($0.text) }
        o.newLines = Set(fresh.map(\.text)).count

        let sceneID = scene.id
        let mood = self.mood
        let stage = self.stage
        let missed = missedNodes
        let assisted = assistedNodes
        let clean = cleanNodes
        let said = self.said
        let snapshot = o
        store.mutateRehearsal { state in
            state.update(sceneID) { r in
                r.rehearsals += 1
                if stage == .watch { r.watched = true }
                r.stars = max(r.stars, snapshot.stars)
                if snapshot.performPassed {
                    r.performPassed = true
                    r.clearedMoods.insert(mood)
                    if r.liveIssuedAt == nil { r.liveIssuedAt = Date() }
                }
            }
            if stage == .rehearse || stage == .perform {
                for s in said { state.own(sceneID: sceneID, nodeID: s.nodeID, text: s.text, gloss: s.gloss) }
                for n in missed { state.enqueue(sceneID: sceneID, nodeID: n, reason: "missed") }
                for n in assisted.subtracting(missed) { state.enqueue(sceneID: sceneID, nodeID: n, reason: "assist") }
                if snapshot.performPassed {
                    for n in clean.shuffled().prefix(2) { state.enqueue(sceneID: sceneID, nodeID: n, reason: "sample", inDays: 3) }
                }
            }
        }
        store.award(o.xp)
        outcome = o
    }

    // MARK: - Helpers

    private func speak(_ text: String, as role: String) async {
        guard !cancelled else { return }
        let speaker = Speaker.shared
        speaker.say(text, voice: role)
        let started = Date()
        try? await Task.sleep(for: .seconds(0.2))
        while speaker.speakingText == text, Date().timeIntervalSince(started) < 8 {
            try? await Task.sleep(for: .seconds(0.12))
        }
    }

    static func tidy(_ text: String) -> String {
        guard let first = text.first else { return text }
        return first.uppercased() + text.dropFirst()
    }
}
