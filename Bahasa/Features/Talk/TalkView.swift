import SwiftUI

struct TalkView: View {
    @EnvironmentObject private var progress: ProgressStore
    @EnvironmentObject private var events: EventRouter
    @EnvironmentObject private var purchases: PurchaseManager
    @State private var paywall: PaywallContext?
    @State private var openScene: SceneOpen?
    @State private var checkinScene: RehearsalScene?

    struct SceneOpen: Identifiable {
        let scene: RehearsalScene
        var stage: Stage?
        var id: String { scene.id }
    }

    var body: some View {
        NavigationStack {
            CozyPage(title: "Ngobrol", subtitle: "Practise here, then try it for real", profile: true) {
                TabArt.talk.view
            } accessory: {
                if progress.livedCount > 0 {
                    ArtChip(text: "\(progress.livedCount) lived", symbol: "sparkles", tint: Theme.sawah)
                }
            } content: {
                if let pending = pendingCheckin {
                    Nudge(symbol: "sparkles", tint: Theme.sawah, title: "Did you try it?",
                          note: pending.titleEn) {
                        checkinScene = pending
                    }
                } else if let recall = recallDue {
                    Nudge(symbol: "arrow.triangle.2.circlepath", tint: Theme.indigo,
                          title: "Quick practice", note: "\(recall.count) \(recall.count == 1 ? "line" : "lines"), two minutes") {
                        open(recall.scene, stage: .recall)
                    }
                } else if !purchases.isPlus && hasFinishedAChat {
                    Nudge(symbol: "sparkles", tint: Theme.sambal, title: "Meet everyone with Plus",
                          note: "\(lockedCount) more neighbours are waiting") {
                        paywall = .general
                    }
                }

                CozySection("Your neighbours") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(SceneLibrary.scenes) { scene in
                                Button {
                                    Haptics.select()
                                    open(scene)
                                } label: {
                                    VStack(spacing: 6) {
                                        CharacterPortrait(characterID: scene.character.id, tint: scene.color, size: 64,
                                                          expression: progress.rehearsal.record(scene.id).lived ? .happy : .neutral)
                                            .overlay(alignment: .bottomTrailing) {
                                                if !Access.scene(scene.id, plan: purchases.plan) { PlusBadge(size: 22) }
                                            }
                                        Text(scene.character.name)
                                            .font(.rounded(13, .bold))
                                            .foregroundStyle(Theme.ink)
                                        Text(scene.place)
                                            .font(.ui(11, .medium))
                                            .foregroundStyle(scene.color)
                                    }
                                }
                                .buttonStyle(.squish)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .scrollClipDisabled()
                }

                LazyVStack(spacing: 18) {
                    ForEach(SceneLibrary.scenes) { scene in
                        Button {
                            Haptics.select()
                            open(scene)
                        } label: {
                            SceneCard(scene: scene, record: progress.rehearsal.record(scene.id),
                                      locked: !Access.scene(scene.id, plan: purchases.plan))
                        }
                        .buttonStyle(.squish)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(item: $openScene) { open in
            SceneHomeView(scene: open.scene, initialStage: open.stage)
                .environmentObject(progress)
        }
        .paywall($paywall)
        .sheet(item: $checkinScene) { scene in
            LiveCardView(scene: scene)
                .environmentObject(progress)
        }
        .onAppear {
            if let id = LaunchArgs.scene ?? LaunchArgs.scenario, let scene = SceneLibrary.resolve(id), openScene == nil {
                open(scene, stage: LaunchArgs.stage)
            }
            present(events.scenarioID)
        }
        .onChange(of: events.scenarioID) { _, id in
            present(id)
        }
    }

    /// A Live card issued a while ago with no check-in yet (spec §5.4: prompted on next app open).
    private var pendingCheckin: RehearsalScene? {
        progress.rehearsal.pendingCheckins(after: LaunchArgs.liveDelay ?? 60 * 60 * 3).compactMap(SceneLibrary.scene).first
    }

    private var hasFinishedAChat: Bool {
        SceneLibrary.scenes.contains { progress.rehearsal.record($0.id).stars > 0 }
    }

    private var lockedCount: Int {
        SceneLibrary.scenes.filter { !Access.scene($0.id, plan: purchases.plan) }.count
    }

    /// The Scene with the most Recall items due today.
    private var recallDue: (scene: RehearsalScene, count: Int)? {
        let due = progress.rehearsal.due().filter { Access.scene($0.sceneID, plan: purchases.plan) }
        let grouped = Dictionary(grouping: due, by: \.sceneID)
        guard let best = grouped.max(by: { $0.value.count < $1.value.count }),
              let scene = SceneLibrary.scene(best.key) else { return nil }
        return (scene, due.count)
    }

    private func present(_ id: String?) {
        guard let id, let scene = SceneLibrary.resolve(id) else { return }
        open(scene)
        events.scenarioID = nil
    }

    /// Every way into a Scene goes through here, so Plus Scenes always meet the paywall first.
    private func open(_ scene: RehearsalScene, stage: Stage? = nil) {
        if Access.scene(scene.id, plan: purchases.plan) {
            openScene = SceneOpen(scene: scene, stage: stage)
        } else {
            paywall = .scene(scene)
        }
    }
}

/// One gentle prompt at the top of the page. Never more than one at a time.
struct Nudge: View {
    let symbol: String
    let tint: Color
    let title: String
    var note: String?
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.select()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(tint))
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.rounded(16, .bold))
                        .foregroundStyle(Theme.ink)
                    if let note {
                        Text(note)
                            .font(.ui(13))
                            .foregroundStyle(Theme.inkSoft)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(tint)
            }
            .cozyCard(padding: 12)
        }
        .buttonStyle(.squish)
    }
}

/// A Scene: its drawing, its name, and five little dots for the five stages.
private struct SceneCard: View {
    let scene: RehearsalScene
    let record: RehearsalState.SceneRecord
    var locked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PlaceIllustration(scene: scene, expression: record.lived ? .happy : .neutral, compact: true)
                .frame(height: 168)
                .overlay(alignment: .topTrailing) {
                    if locked {
                        ArtChip(text: "Plus", symbol: "sparkles", tint: Theme.sambal)
                            .padding(10)
                    } else if record.stars > 0 || record.lived {
                        ArtChip(text: record.lived ? "Lived" : String(repeating: "★", count: record.stars),
                                tint: record.lived ? Theme.sawah : Theme.kunyit)
                            .padding(10)
                    }
                }
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(scene.title)
                        .font(.rounded(20, .heavy))
                        .foregroundStyle(Theme.ink)
                    Text(scene.titleEn)
                        .font(.ui(14, .medium))
                        .foregroundStyle(Theme.inkSoft)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(scene.color)
            }
            .padding(16)
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Theme.kopi.opacity(0.1), radius: 12, y: 5)
    }
}
