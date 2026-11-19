import SwiftUI
import UIKit

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

/// Warm, editorial palette with a Bali touch.
enum Theme {
    static let paper = Color(hex: 0xF6F1E8)
    static let card = Color(hex: 0xFFFCF6)
    static let ink = Color(hex: 0x1D1A16)
    static let inkSoft = Color(hex: 0x6B645A)
    static let line = Color(hex: 0xE6DDCD)

    static let sambal = Color(hex: 0xD4512A)
    static let indigo = Color(hex: 0x2F3E6B)
    static let kunyit = Color(hex: 0xE3A126)
    static let sawah = Color(hex: 0x2E7D5B)
    static let jambu = Color(hex: 0xB7385E)
    static let laut = Color(hex: 0x1F7A8C)
    static let kopi = Color(hex: 0x6F4E37)

    static let benar = Color(hex: 0x2E7D5B)
    static let salah = Color(hex: 0xC0392B)
}

/// Colours referenced by name from content files.
enum Accent: String, Codable, CaseIterable {
    case sambal, indigo, kunyit, sawah, jambu, laut, kopi

    var color: Color {
        switch self {
        case .sambal: return Theme.sambal
        case .indigo: return Theme.indigo
        case .kunyit: return Theme.kunyit
        case .sawah: return Theme.sawah
        case .jambu: return Theme.jambu
        case .laut: return Theme.laut
        case .kopi: return Theme.kopi
        }
    }
}

extension Font {
    /// SF Rounded, a notch heavier: headings and Indonesian sentences. Soft and friendly.
    static func display(_ size: CGFloat, _ weight: Font.Weight = .medium) -> Font {
        let w: Font.Weight
        switch weight {
        case .regular: w = .medium
        case .semibold: w = .bold
        default: w = weight
        }
        return .system(size: size, weight: w, design: .rounded)
    }

    /// SF Rounded, for buttons and chips.
    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    /// SF Rounded, for UI text.
    static func ui(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Kawung batik motif

/// Four-petal kawung motif on an offset grid, drawn at low opacity over colour.
struct KawungPattern: View {
    var color: Color = .white
    var opacity: Double = 0.16
    var cell: CGFloat = 54

    var body: some View {
        Canvas { ctx, size in
            let s = cell
            let stroke = GraphicsContext.Shading.color(color.opacity(opacity))
            let cols = Int(size.width / s) + 3
            let rows = Int(size.height / (s * 0.82)) + 3
            for r in -1..<rows {
                for c in -1..<cols {
                    let x = CGFloat(c) * s + (abs(r) % 2 == 0 ? 0 : s / 2)
                    let y = CGFloat(r) * s * 0.82
                    let petals: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                        (-s * 0.20, 0, s * 0.30, s * 0.50),
                        (s * 0.20, 0, s * 0.30, s * 0.50),
                        (0, -s * 0.20, s * 0.50, s * 0.30),
                        (0, s * 0.20, s * 0.50, s * 0.30)
                    ]
                    for (dx, dy, w, h) in petals {
                        let rect = CGRect(x: x + dx - w / 2, y: y + dy - h / 2, width: w, height: h)
                        ctx.stroke(Path(ellipseIn: rect), with: stroke, lineWidth: 1.1)
                    }
                    let dot = CGRect(x: x - s * 0.035, y: y - s * 0.035, width: s * 0.07, height: s * 0.07)
                    ctx.fill(Path(ellipseIn: dot), with: stroke)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Surfaces

struct CardBackground: ViewModifier {
    var radius: CGFloat = 20
    var padding: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius + 2, style: .continuous)
                    .fill(Theme.card)
                    .shadow(color: Theme.kopi.opacity(0.08), radius: 10, y: 4)
            )
    }
}

extension View {
    func cardStyle(radius: CGFloat = 20, padding: CGFloat = 18) -> some View {
        modifier(CardBackground(radius: radius, padding: padding))
    }
}

// MARK: - Shades

extension Color {
    /// Blend toward white by `amount` (0–1). Works on iOS 17.
    func lighter(_ amount: CGFloat) -> Color { shifted(amount) }

    /// Blend toward black by `amount` (0–1).
    func darker(_ amount: CGFloat) -> Color { shifted(-amount) }

    private func shifted(_ amount: CGFloat) -> Color {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, o: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        func f(_ c: CGFloat) -> CGFloat { amount > 0 ? c + (1 - c) * amount : c * (1 + amount) }
        return Color(.sRGB, red: f(r), green: f(g), blue: f(b), opacity: o)
    }
}
