import SwiftUI

// MARK: - Entrance

/// Fade-and-rise the first time a view appears. `index` staggers siblings.
struct AppearIn: ViewModifier {
    var index: Int = 0
    var offset: CGFloat = 18

    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown || reduceMotion ? 0 : offset)
            .scaleEffect(shown || reduceMotion ? 1 : 0.97)
            .onAppear {
                guard !shown else { return }
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82).delay(Double(min(index, 12)) * 0.06)) {
                    shown = true
                }
            }
    }
}

extension View {
    func appearIn(_ index: Int = 0, offset: CGFloat = 18) -> some View {
        modifier(AppearIn(index: index, offset: offset))
    }
}

// MARK: - Press

/// Cards squish slightly while pressed.
struct SquishButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.965

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .brightness(configuration.isPressed ? -0.02 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SquishButtonStyle {
    static var squish: SquishButtonStyle { SquishButtonStyle() }
}

// MARK: - Idle motion

/// Gentle continuous float, for decorations. Stops under Reduce Motion.
struct Bob: ViewModifier {
    var amount: CGFloat = 6
    var period: Double = 3.2
    var phase: Double = 0
    var tilt: Double = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate / period * 2 * .pi + phase
            content
                .offset(y: reduceMotion ? 0 : sin(t) * amount)
                .rotationEffect(.degrees(reduceMotion ? 0 : sin(t * 0.7) * tilt))
        }
    }
}

extension View {
    func bob(_ amount: CGFloat = 6, period: Double = 3.2, phase: Double = 0, tilt: Double = 0) -> some View {
        modifier(Bob(amount: amount, period: period, phase: phase, tilt: tilt))
    }
}

/// Deterministic random numbers, so decorations stay put between renders.
struct SeededRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: Int) { state = UInt64(truncatingIfNeeded: seed) &+ 0x9E37_79B9_7F4A_7C15 }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
