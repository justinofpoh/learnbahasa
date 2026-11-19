import SwiftUI

/// Picks up exactly where the launch screen leaves off (same paper, same portrait, same spot),
/// then Ibu Wayan says hello and the name appears. Everything moves (breathing portrait, bouncing
/// typing dots, a filling bar) so it's clear the app is loading. About two seconds; tap to skip.
struct SplashView: View {
    var onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var step = 0          // 0 portrait · 1 typing · 2 "Halo!" · 3 name
    @State private var finished = false
    @State private var loaded: CGFloat = 0

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            KawungPattern(color: Theme.sambal, opacity: step >= 3 ? 0.07 : 0, cell: 64)
                .ignoresSafeArea()
                .animation(.easeOut(duration: 0.8), value: step)

            CharacterPortrait(characterID: "ibu-wayan", tint: Theme.sambal, size: 150,
                              speaking: step == 2, expression: step >= 3 ? .happy : .neutral)
                .bob(reduceMotion ? 0 : 3, period: 2.4)
                .overlay(alignment: .topTrailing) {
                    bubble
                        .offset(x: 78, y: -34)
                }
                .scaleEffect(step >= 3 ? 0.92 : 1)
                .offset(y: step >= 3 ? -48 : 0)
                .overlay(alignment: .bottom) {
                    VStack(spacing: 6) {
                        Text("Learn Bahasa")
                            .font(.rounded(42, .heavy))
                            .foregroundStyle(Theme.sambal)
                        Text("Learn Indonesian by chatting")
                            .font(.ui(17, .semibold))
                            .foregroundStyle(Theme.inkSoft)
                    }
                    .fixedSize()
                    .offset(y: step >= 3 ? 112 : 132)
                    .opacity(step >= 3 ? 1 : 0)
                }

            // Loading bar: fills over the splash, so the wait never looks stuck.
            VStack {
                Spacer()
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.line)
                    Capsule().fill(Theme.sambal).frame(width: 140 * loaded)
                }
                .frame(width: 140, height: 6)
                .padding(.bottom, 64)
                .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { finish() }
        .onAppear(perform: run)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Learn Bahasa. Loading.")
    }

    @ViewBuilder
    private var bubble: some View {
        if step >= 1 {
            ZStack {
                if step == 1 {
                    TimelineView(.animation(paused: reduceMotion)) { timeline in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        HStack(spacing: 5) {
                            ForEach(0..<3, id: \.self) { i in
                                let wave = reduceMotion ? 0 : max(0, sin(t * 9 - Double(i) * 0.9))
                                Circle()
                                    .fill(Theme.sambal.opacity(0.45 + 0.45 * wave))
                                    .frame(width: 7, height: 7)
                                    .offset(y: -3 * wave)
                            }
                        }
                    }
                    .transition(.opacity)
                } else {
                    Text("Halo!")
                        .font(.rounded(20, .heavy))
                        .foregroundStyle(Theme.sambal)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(ChatShape(mine: false).fill(Theme.card).shadow(color: Theme.kopi.opacity(0.12), radius: 8, y: 4))
            .transition(.scale(scale: 0.3, anchor: .bottomLeading).combined(with: .opacity))
        }
    }

    private func run() {
        let pace = reduceMotion ? 0.5 : 1.0
        let spring = Animation.spring(response: 0.45, dampingFraction: 0.7)
        withAnimation(.easeInOut(duration: 2.2 * pace)) { loaded = 1 }
        schedule(0.25 * pace) { withAnimation(spring) { step = 1 } }
        schedule(0.75 * pace) { withAnimation(spring) { step = 2 }; Haptics.tap() }
        schedule(1.15 * pace) { withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { step = 3 } }
        schedule(2.3 * pace) { finish() }
    }

    private func schedule(_ delay: Double, _ work: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard !finished else { return }
            work()
        }
    }

    private func finish() {
        guard !finished else { return }
        finished = true
        onFinish()
    }
}
