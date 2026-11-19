import SwiftUI

/// Trying it for real: a pocket cheat-card for the real place, and the check-in afterwards (spec §5.4).
struct LiveCardView: View {
    let scene: RehearsalScene

    @EnvironmentObject private var progress: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var outcome: LiveOutcome?
    @State private var reason: HardReason?
    @State private var saved = false

    private var tint: Color { scene.color }

    /// Up to three lines: the learner's own most-said lines first, then the scene's first Natural replies.
    private var keyLines: [(text: String, gloss: String)] {
        var seenNodes = Set<String>()
        var picked: [(String, String)] = []
        let order = Dictionary(uniqueKeysWithValues: scene.nodes.enumerated().map { ($1.id, $0) })
        let owned = progress.rehearsal.lines(for: scene.id)
            .sorted { (order[$0.nodeID] ?? 99, -$0.timesSaid) < (order[$1.nodeID] ?? 99, -$1.timesSaid) }
        for line in owned where !seenNodes.contains(line.nodeID) {
            seenNodes.insert(line.nodeID)
            picked.append((line.text, line.gloss))
        }
        if picked.count < 3 && owned.isEmpty {
            for node in scene.nodes where !node.isEnd && !seenNodes.contains(node.id) {
                guard let n = node.naturals.first else { continue }
                seenNodes.insert(node.id)
                picked.append((progress.filler.fill(n.text), progress.filler.fill(n.gloss)))
            }
        }
        return Array(picked.prefix(3)).map { (text: $0.0, gloss: $0.1) }
    }

    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Spacer()
                    Button("Done") { dismiss() }
                        .font(.rounded(15))
                        .foregroundStyle(tint)
                }

                PlaceIllustration(scene: scene, expression: saved && outcome != .notYet ? .happy : .neutral, compact: true)
                    .frame(height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(alignment: .bottomLeading) {
                        Text("Your next visit")
                            .font(.ui(12, .semibold))
                            .foregroundStyle(Theme.ink)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(.ultraThinMaterial))
                            .padding(12)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .bottom, spacing: 10) {
                        CharacterPortrait(characterID: scene.character.id, tint: tint, size: 48, expression: .happy)
                        Text("Semangat! Sampai ketemu, ya.")
                            .font(.rounded(15, .semibold))
                            .foregroundStyle(Theme.ink)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 9)
                            .background(ChatShape(mine: false).fill(Theme.card).shadow(color: Theme.kopi.opacity(0.08), radius: 6, y: 3))
                    }
                    .padding(.bottom, 6)
                    Text("Try it for real")
                        .font(.display(32, .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("Next time you're there, give it a go. Reading from this card counts too.")
                        .font(.ui(15))
                        .foregroundStyle(Theme.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                cheatCard

                checkIn
                Color.clear.frame(height: 1).id("end")
            }
            .padding(20)
        }
        .onChange(of: outcome) { _, value in
            guard value == .hard else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) { proxy.scrollTo("end", anchor: .bottom) }
            }
        }
        .onChange(of: saved) { _, _ in
            withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) { proxy.scrollTo("end", anchor: .bottom) }
        }
        }
        .background(Theme.paper.ignoresSafeArea())
    }

    private var cheatCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(scene.title)
                    .font(.display(16, .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                Image(systemName: scene.symbol)
                    .foregroundStyle(.white.opacity(0.8))
            }
            ForEach(Array(keyLines.enumerated()), id: \.offset) { _, line in
                Button {
                    Haptics.tap()
                    Speaker.shared.say(line.text)
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(line.text)
                                .font(.display(26, .semibold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(line.gloss)
                                .font(.ui(13))
                                .foregroundStyle(.white.opacity(0.78))
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(.white.opacity(0.2)))
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Text("Tip: say \u{201C}\(scene.character.addressAs[0])\u{201D}. \(scene.culture.last ?? "")")
                .font(.ui(12))
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous).fill(tint)
                KawungPattern(color: .white, opacity: 0.13, cell: 58)
            }
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        )
    }

    @ViewBuilder
    private var checkIn: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Check in")
            if saved {
                savedView
            } else {
                Text("Did you try it?")
                    .font(.display(22, .semibold))
                    .foregroundStyle(Theme.ink)
                VStack(spacing: 9) {
                    ForEach(LiveOutcome.allCases, id: \.self) { o in
                        CheckinButton(title: o.label, symbol: o.symbol, selected: outcome == o, tint: tint) {
                            Haptics.select()
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                outcome = o
                                reason = nil
                            }
                            if o != .hard { save() }
                        }
                    }
                }
                if outcome == .hard {
                    Text("What tripped you up?")
                        .font(.display(19, .semibold))
                        .foregroundStyle(Theme.ink)
                        .padding(.top, 6)
                    VStack(spacing: 8) {
                        ForEach(HardReason.allCases, id: \.self) { r in
                            CheckinButton(title: r.label, symbol: nil, selected: reason == r, tint: Theme.kunyit) {
                                Haptics.select()
                                reason = r
                                save()
                            }
                        }
                    }
                }
            }
        }
    }

    private var savedView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: outcome == .notYet ? "clock.fill" : "diamond.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(outcome == .notYet ? Theme.inkSoft : Theme.sawah)
                Text(outcome == .notYet ? "No rush. The card's here when you go." : "Lived. That's the whole point.")
                    .font(.display(20, .semibold))
                    .foregroundStyle(Theme.ink)
            }
            if let reason {
                Text(reason.advice)
                    .font(.ui(14))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(radius: 16, padding: 16)
        .overlay {
            if outcome == .worked { ConfettiBurst().frame(height: 500).offset(y: -250) }
        }
    }

    private func save() {
        guard let outcome else { return }
        let sceneID = scene.id
        let reason = self.reason
        progress.mutateRehearsal { state in
            state.update(sceneID) { r in
                r.checkins.append(.init(date: Date(), outcome: outcome, reason: reason))
                if outcome != .notYet { r.lived = true }
            }
            // "Remembering what to say" sends the Scene's lines back into Recall tomorrow.
            if reason == .remembering || reason == .understanding {
                for line in state.lines(for: sceneID) {
                    state.enqueue(sceneID: sceneID, nodeID: line.nodeID, reason: "live")
                }
            }
        }
        if outcome != .notYet { progress.award(15) }
        outcome == .notYet ? Haptics.tap() : Haptics.correct()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { saved = true }
    }
}

private struct CheckinButton: View {
    let title: String
    let symbol: String?
    let selected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 22)
                }
                Text(title)
                    .font(.ui(16, .medium))
                    .foregroundStyle(Theme.ink)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(selected ? tint.opacity(0.1) : Theme.card))
            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(selected ? tint : Theme.line, lineWidth: selected ? 2 : 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
