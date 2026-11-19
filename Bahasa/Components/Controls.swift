import SwiftUI

/// Primary button with a darker base layer that presses down.
struct ChunkyButtonStyle: ButtonStyle {
    var color: Color = Theme.sambal
    var depth: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.rounded(17))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous).fill(color)
            )
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(color)
                    .brightness(-0.22)
                    .offset(y: configuration.isPressed ? 1 : depth)
            )
            .offset(y: configuration.isPressed ? depth - 1 : 0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ChunkyButton: View {
    var title: String
    var color: Color = Theme.sambal
    var enabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(title) {
            Haptics.pop()
            action()
        }
        .buttonStyle(ChunkyButtonStyle(color: enabled ? color : Theme.inkSoft.opacity(0.35)))
        .disabled(!enabled)
    }
}

/// Speaks Indonesian text. Pulses while that exact line is playing.
struct SpeakerButton: View {
    let text: String
    var slow: Bool = false
    var tint: Color = Theme.sambal
    var size: CGFloat = 15

    @ObservedObject private var speaker = Speaker.shared

    private var active: Bool { speaker.isSpeaking(text) }

    var body: some View {
        Button {
            Haptics.tap()
            speaker.say(text, slow: slow)
        } label: {
            Image(systemName: slow ? "tortoise.fill" : (active ? "speaker.wave.3.fill" : "speaker.wave.2.fill"))
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: size * 2.1, height: size * 2.1)
                .background(Circle().fill(tint.opacity(active ? 0.22 : 0.12)))
                .scaleEffect(active ? 1.08 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: active)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(slow ? "Play slowly" : "Play")
    }
}

/// Coloured role chip. Optionally labelled underneath.
struct RoleChipView: View {
    let chip: Chip
    var showLabel: Bool = true
    var compact: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Text(chip.text)
                .font(.rounded(compact ? 14 : 16))
                .foregroundStyle(chip.role.color)
                .padding(.horizontal, compact ? 10 : 12)
                .padding(.vertical, compact ? 6 : 8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(chip.role.color.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(chip.role.color.opacity(0.28), lineWidth: 1)
                )
            if showLabel {
                Text(chip.role.label)
                    .font(.ui(10, .semibold))
                    .foregroundStyle(chip.role.color.opacity(0.75))
            }
        }
    }
}

struct PatternStrip: View {
    let chips: [Chip]
    var showLabels: Bool = true

    var body: some View {
        FlowLayout(spacing: 8, lineSpacing: 10) {
            ForEach(chips) { chip in
                RoleChipView(chip: chip, showLabel: showLabels)
            }
        }
    }
}

/// Indonesian line with its English underneath and a speaker button.
struct ExampleRow: View {
    let indo: String
    let en: String
    var note: String?
    var tint: Color = Theme.sambal

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(indo)
                    .font(.display(18))
                    .foregroundStyle(Theme.ink)
                Text(en)
                    .font(.ui(14))
                    .foregroundStyle(Theme.inkSoft)
                if let note {
                    Text(note)
                        .font(.ui(12))
                        .foregroundStyle(tint.opacity(0.9))
                }
            }
            Spacer(minLength: 0)
            SpeakerButton(text: indo, tint: tint)
        }
        .padding(.vertical, 6)
    }
}

/// Animated progress capsule for the lesson header.
struct ProgressCapsule: View {
    var fraction: Double
    var tint: Color = Theme.sambal

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.line)
                Capsule()
                    .fill(tint)
                    .frame(width: max(8, geo.size.width * min(1, max(0, fraction))))
            }
        }
        .frame(height: 10)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: fraction)
    }
}

/// Daily-goal ring.
struct GoalRing: View {
    var fraction: Double
    var tint: Color = Theme.sambal
    var size: CGFloat = 64
    var lineWidth: CGFloat = 8

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.line, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.001, min(1, fraction)))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int((min(1, fraction) * 100).rounded()))%")
                .font(.rounded(13))
                .foregroundStyle(Theme.ink)
        }
        .frame(width: size, height: size)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: fraction)
    }
}

/// Horizontal shake for a wrong answer.
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakes: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(animatableData * .pi * shakes), y: 0)
        )
    }
}

extension View {
    func shake(_ trigger: CGFloat) -> some View {
        modifier(ShakeEffect(animatableData: trigger))
    }
}

/// One-shot confetti burst for the completion screen.
struct ConfettiBurst: View {
    var colors: [Color] = [Theme.sambal, Theme.kunyit, Theme.sawah, Theme.laut, Theme.jambu, Theme.indigo]
    var count: Int = 46

    @State private var fired = false

    private struct Piece: Identifiable {
        let id = UUID()
        let x: CGFloat
        let delay: Double
        let spin: Double
        let drift: CGFloat
        let color: Color
        let width: CGFloat
        let height: CGFloat
    }

    @State private var pieces: [Piece] = []

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(piece.color)
                        .frame(width: piece.width, height: piece.height)
                        .rotationEffect(.degrees(fired ? piece.spin : 0))
                        .offset(
                            x: piece.x * geo.size.width + (fired ? piece.drift : 0),
                            y: fired ? geo.size.height * 1.05 : -40
                        )
                        .opacity(fired ? 0.0 : 1)
                        .animation(
                            .easeIn(duration: 2.1).delay(piece.delay),
                            value: fired
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            pieces = (0..<count).map { _ in
                Piece(
                    x: CGFloat.random(in: 0.02...0.96),
                    delay: Double.random(in: 0...0.5),
                    spin: Double.random(in: 180...900),
                    drift: CGFloat.random(in: -60...60),
                    color: colors.randomElement() ?? Theme.sambal,
                    width: CGFloat.random(in: 5...9),
                    height: CGFloat.random(in: 9...16)
                )
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { fired = true }
        }
    }
}

/// Small pill label, e.g. "Unit 2" or "done".
struct PillLabel: View {
    let text: String
    var color: Color = Theme.sambal
    var filled: Bool = false

    var body: some View {
        Text(text)
            .font(.rounded(12))
            .foregroundStyle(filled ? .white : color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(filled ? color : color.opacity(0.12))
            )
    }
}
