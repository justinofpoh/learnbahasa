import SwiftUI

// MARK: - Kawung flower

enum Kawung {
    /// Draws one four-petal kawung flower centred on `center`, `size` across.
    static func draw(
        in ctx: GraphicsContext,
        center: CGPoint,
        size: CGFloat,
        angle: Angle = .zero,
        color: Color,
        filled: Bool,
        lineWidth: CGFloat = 1.4
    ) {
        var ctx = ctx
        ctx.translateBy(x: center.x, y: center.y)
        ctx.rotate(by: angle)
        let s = size / 0.9
        let petals: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (-0.2, 0, 0.30, 0.50),
            (0.2, 0, 0.30, 0.50),
            (0, -0.2, 0.50, 0.30),
            (0, 0.2, 0.50, 0.30)
        ]
        for (dx, dy, w, h) in petals {
            let rect = CGRect(x: (dx - w / 2) * s, y: (dy - h / 2) * s, width: w * s, height: h * s)
            let path = Path(ellipseIn: rect)
            if filled {
                ctx.fill(path, with: .color(color))
            } else {
                ctx.stroke(path, with: .color(color), lineWidth: lineWidth)
            }
        }
        let dot = CGRect(x: -s * 0.045, y: -s * 0.045, width: s * 0.09, height: s * 0.09)
        ctx.fill(Path(ellipseIn: dot), with: .color(color))
    }
}

/// A single kawung flower that turns slowly.
struct SpinningFlower: View {
    var color: Color = Theme.sambal
    var filled: Bool = true
    var period: Double = 14

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                Kawung.draw(
                    in: ctx,
                    center: CGPoint(x: size.width / 2, y: size.height / 2),
                    size: min(size.width, size.height),
                    angle: .degrees(reduceMotion ? 0 : (t / period).truncatingRemainder(dividingBy: 1) * 360),
                    color: color,
                    filled: filled
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// A loose field of kawung flowers and dots that drift and turn.
struct DriftField: View {
    var color: Color = .white
    var count: Int = 10
    var seed: Int = 1
    var minSize: CGFloat = 14
    var maxSize: CGFloat = 46
    var opacity: Double = 0.16

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct Item {
        let x, y, size: CGFloat
        let speed, phase: Double
        let filled, dot: Bool
    }

    private var items: [Item] {
        var rng = SeededRandom(seed: seed)
        return (0..<count).map { _ in
            Item(
                x: .random(in: 0...1, using: &rng),
                y: .random(in: 0...1, using: &rng),
                size: .random(in: minSize...maxSize, using: &rng),
                speed: .random(in: 0.25...0.6, using: &rng),
                phase: .random(in: 0...(2 * .pi), using: &rng),
                filled: .random(using: &rng),
                dot: Double.random(in: 0...1, using: &rng) < 0.3
            )
        }
    }

    var body: some View {
        let items = items
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let t = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                for item in items {
                    let center = CGPoint(
                        x: item.x * size.width + CGFloat(cos(t * item.speed * 0.6 + item.phase)) * 6,
                        y: item.y * size.height + CGFloat(sin(t * item.speed + item.phase)) * 9
                    )
                    let shade = color.opacity(item.filled ? opacity * 0.8 : opacity)
                    if item.dot {
                        let r = item.size * 0.14
                        ctx.fill(Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)), with: .color(shade))
                    } else {
                        Kawung.draw(
                            in: ctx,
                            center: center,
                            size: item.size,
                            angle: .degrees(t * item.speed * 14 + item.phase * 57),
                            color: shade,
                            filled: item.filled
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Coloured hero surface

/// Accent gradient + static kawung + drifting flowers. Used behind hero cards.
struct HeroSurface: View {
    var color: Color
    var radius: CGFloat = 28
    var seed: Int = 1

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [color.lighter(0.12), color, color.darker(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            KawungPattern(color: .white, opacity: 0.07, cell: 64)
            DriftField(color: .white, count: 9, seed: seed, opacity: 0.22)
        }
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

// MARK: - Character avatar

/// Initial in a gradient disc. Rings ripple out while the character is talking.
struct CharacterAvatar: View {
    let name: String
    let color: Color
    var size: CGFloat = 44
    var active: Bool = false
    var onColor: Bool = false

    @State private var ripple = false

    private var initial: String {
        let parts = name.split(separator: " ")
        let word = parts.count > 1 && ["Ibu", "Bu", "Pak", "Mas", "Mbak"].contains(String(parts[0])) ? parts[1] : parts.first ?? ""
        return String(word.prefix(1))
    }

    var body: some View {
        ZStack {
            if active {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .stroke(onColor ? Color.white : color, lineWidth: 2)
                        .scaleEffect(ripple ? 1.6 : 1)
                        .opacity(ripple ? 0 : 0.5)
                        .animation(
                            .easeOut(duration: 1.3).repeatForever(autoreverses: false).delay(Double(i) * 0.6),
                            value: ripple
                        )
                }
                .onAppear { ripple = true }
                .onDisappear { ripple = false }
            }
            Circle()
                .fill(
                    LinearGradient(
                        colors: onColor
                            ? [Color.white.opacity(0.95), Color.white.opacity(0.8)]
                            : [color.lighter(0.15), color.darker(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(initial)
                .font(.display(size * 0.44, .semibold))
                .foregroundStyle(onColor ? color : .white)
        }
        .frame(width: size, height: size)
        .accessibilityLabel(name)
    }
}
