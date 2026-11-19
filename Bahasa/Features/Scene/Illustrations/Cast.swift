import SwiftUI

/// Everyone you meet in the app, and how to draw them. One place, so a face looks the same
/// in a Scene drawing, a chat bubble and the neighbours row.
enum Cast {
    static let tutorID = "kak-dewi"

    static func figure(_ id: String) -> Figure {
        switch id {
        case "ibu-wayan":
            return Figure(hair: .bun(flower: Theme.jambu), outfit: Theme.laut)
        case "bu-ketut":
            return Figure(hair: .bun(flower: Theme.kunyit), outfit: Theme.jambu, trim: Theme.kunyit)
        case "pak-agus":
            return Figure(skin: Color(hex: 0xB07A4F), hair: .helmet(Theme.indigo), outfit: Theme.laut, trim: Theme.kunyit, collar: .jacket)
        case "bu-sari":
            return Figure(skin: Color(hex: 0xC9905F), hair: .hijab(Theme.jambu), outfit: Theme.sawah, trim: Theme.kunyit)
        case "putu":
            return Figure(skin: Color(hex: 0xBC8455), hair: .short, outfit: Color(hex: 0x3E7C6B), trim: Theme.kunyit, collar: .crew)
        case "mbok-kadek":
            return Figure(skin: Color(hex: 0xC08657), hair: .bun(flower: Theme.card), outfit: Theme.indigo, trim: Theme.kunyit)
        case "mbak-rina":
            return Figure(skin: Color(hex: 0xC9905F), hair: .hijab(Theme.laut), outfit: Theme.card, trim: Theme.jambu)
        case "bli-made":
            return Figure(skin: Color(hex: 0xA8724A), hair: .short, outfit: Color(hex: 0x4A5A7A), trim: Theme.kunyit, collar: .jacket)
        case "mas-dimas":
            return Figure(skin: Color(hex: 0xC08A5E), hair: .short, outfit: Color(hex: 0x3B3A36), trim: Theme.kunyit, collar: .crew)
        case "pak-gede":
            return Figure(skin: Color(hex: 0xA9764C), hair: .hat(Color(hex: 0xD9B26A)), outfit: Theme.sambal, trim: Theme.card, collar: .crew)
        case "bli-komang":
            return Figure(skin: Color(hex: 0xB27B50), hair: .udeng(Theme.kunyit), outfit: Theme.card, trim: Theme.kunyit, collar: .crew)
        case "pak-nyoman":
            return Figure(skin: Color(hex: 0xB57D52), hair: .udeng(Theme.card), outfit: Theme.card, trim: Theme.sawah, collar: .crew)
        case tutorID:
            return Figure(skin: Color(hex: 0xC48A5C), hair: .bun(flower: Theme.sawah), outfit: Theme.sambal, trim: Theme.card)
        default:
            if let mine = avatars.first(where: { $0.id == id }) { return mine.figure }
            return Figure(hair: .short, outfit: Theme.inkSoft)
        }
    }

    /// Kak Dewi, who explains things in the lessons.
    static let tutorName = "Kak Dewi"

    // MARK: - You

    /// Traveller looks the learner can pick for their profile, drawn in the same style as the neighbours.
    static let avatars: [(id: String, figure: Figure, tint: Color)] = [
        ("you-sunny", Figure(skin: Color(hex: 0xF1C9A5), hair: .long, outfit: Theme.laut, trim: Theme.card,
                             collar: .crew, hairColor: Color(hex: 0xE2B867)), Theme.laut),
        ("you-surf", Figure(skin: Color(hex: 0xE3AE86), hair: .short, outfit: Theme.sawah, trim: Theme.kunyit,
                            collar: .crew, hairColor: Color(hex: 0x6E4428)), Theme.sawah),
        ("you-hat", Figure(skin: Color(hex: 0xD99E78), hair: .hat(Color(hex: 0xE6C27A)), outfit: Theme.jambu,
                           trim: Theme.card), Theme.kunyit),
        ("you-curls", Figure(skin: Color(hex: 0x8D5A3B), hair: .long, outfit: Theme.kunyit, trim: Theme.sambal,
                             hairColor: Color(hex: 0x2B1D14)), Theme.jambu),
        ("you-ginger", Figure(skin: Color(hex: 0xF3D2B5), hair: .long, outfit: Theme.indigo, trim: Theme.kunyit,
                              collar: .crew, hairColor: Color(hex: 0xB4542A)), Theme.sambal),
        ("you-buzz", Figure(skin: Color(hex: 0xA86F48), hair: .short, outfit: Theme.sambal, trim: Theme.card,
                            collar: .jacket), Theme.indigo),
        ("you-silver", Figure(skin: Color(hex: 0xEBC3A0), hair: .short, outfit: Theme.kopi, trim: Theme.kunyit,
                              collar: .crew, hairColor: Color(hex: 0xCFC8BE)), Theme.kopi),
        ("you-hijab", Figure(skin: Color(hex: 0xC9905F), hair: .hijab(Theme.laut), outfit: Theme.sawah,
                             trim: Theme.kunyit), Theme.sawah),
    ]

    static let defaultAvatar = "you-sunny"

    static func avatarTint(_ id: String) -> Color {
        avatars.first { $0.id == id }?.tint ?? Theme.sambal
    }
}

/// A round, drawn portrait of a character. Blinks and talks when `animated`.
struct CharacterPortrait: View {
    let characterID: String
    var tint: Color
    var size: CGFloat = 40
    var speaking: Bool = false
    var expression: CharacterExpression = .neutral
    var animated: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24, paused: !animated || reduceMotion)) { timeline in
            let t = (animated && !reduceMotion) ? timeline.date.timeIntervalSinceReferenceDate : 2.2
            Canvas { ctx, sz in
                let s = sz.width / 100
                ctx.scaleBy(x: s, y: s)
                let disc = Path(ellipseIn: CGRect(x: 0, y: 0, width: 100, height: 100))
                ctx.fill(disc, with: .linearGradient(Gradient(colors: [tint.opacity(0.18), tint.opacity(0.32)]),
                                                     startPoint: .zero, endPoint: CGPoint(x: 0, y: 100)))
                var c = ctx
                c.clip(to: disc)
                c.scaleBy(x: 1.55, y: 1.55)
                Cast.figure(characterID).draw(&c, head: CGPoint(x: 32.3, y: 32), t: t, speaking: speaking,
                                              expression: expression == .confused ? .neutral : expression, gesture: .rest, arms: false)
            }
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(.white, lineWidth: size > 50 ? 3 : 2))
        .shadow(color: tint.opacity(0.25), radius: 4, y: 2)
        .accessibilityHidden(true)
    }
}
