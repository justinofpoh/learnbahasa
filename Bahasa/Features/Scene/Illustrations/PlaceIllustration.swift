import SwiftUI

/// How the character in an illustration is reacting right now.
enum CharacterExpression: Equatable {
    case neutral, happy, confused
}

/// Animated editorial drawing of a Scene's place, with its character reacting live.
struct PlaceIllustration: View {
    let scene: RehearsalScene
    var speaking: Bool = false
    var expression: CharacterExpression = .neutral
    var mood: Mood = .warm
    /// Lower detail and frame rate for small sizes.
    var compact: Bool = false
    /// Extra ground below the scene, for when something overlaps the bottom edge.
    var groundPad: CGFloat = 0

    var body: some View {
        content
            .accessibilityElement()
            .accessibilityLabel(accessibilityText)
    }

    @ViewBuilder
    private var content: some View {
        let fps: Double = compact ? 20 : 30
        let busy = mood == .busy
        switch scene.place {
        case "Warung":
            IllustrationCanvas(drawing: WarungDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        case "Pasar":
            IllustrationCanvas(drawing: PasarDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        case "Jalan":
            IllustrationCanvas(drawing: JalanDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        case "Kos":
            IllustrationCanvas(drawing: KosDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        case "Teman":
            IllustrationCanvas(drawing: NgopiDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        case "Laundry":
            IllustrationCanvas(drawing: LaundryDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        case "Apotek":
            IllustrationCanvas(drawing: ApotekDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        case "Bengkel":
            IllustrationCanvas(drawing: BengkelDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        case "Kafe":
            IllustrationCanvas(drawing: KafeDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        case "Rental":
            IllustrationCanvas(drawing: RentalDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        case "Pura":
            IllustrationCanvas(drawing: PuraDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        case "Tetangga":
            IllustrationCanvas(drawing: TetanggaDrawing(speaking: speaking, expression: expression, busy: busy, compact: compact),
                               groundPad: groundPad, fps: fps)
        default:
            ZStack {
                scene.color
                DriftField(color: .white, count: 10, seed: 3, opacity: 0.22)
                Image(systemName: scene.symbol)
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(.white)
                    .bob(5)
            }
        }
    }

    private var accessibilityText: String {
        let state: String
        if speaking { state = "is talking" }
        else if expression == .happy { state = "is smiling" }
        else if expression == .confused { state = "looks puzzled" }
        else { state = "is waiting" }
        return "Illustration: \(scene.character.name) at the \(scene.place.lowercased()) \(state)."
    }
}

// MARK: - Warung

/// A Balinese warung at midday: penjor, palm, tiled roof with a scalloped awning, a swinging
/// sign, the glass case of dishes, a steaming pot, Ibu Wayan behind the counter, plastic stools
/// and a sleeping cat.
struct WarungDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let wall = Color(hex: 0xF0E2C6)
    private let wood = Color(hex: 0x8A5E3F)
    private let woodDark = Color(hex: 0x6F4E37)
    private let roof = Color(hex: 0xC4482A)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        Illo.sky(&ctx, f, top: Color(hex: 0xF7D9A8), bottom: Color(hex: 0xF6EBD7))
        Illo.sun(&ctx, t: t, center: CGPoint(x: 336, y: 44))
        Illo.clouds(&ctx, f, t: t, count: compact ? 1 : 2)
        Illo.hills(&ctx, f)
        Illo.palm(&ctx, t: t, base: CGPoint(x: 372, y: 232))
        penjor(&ctx, t: t)
        Illo.ground(&ctx, f, color: Color(hex: 0xE9DABD), pebbles: woodDark.opacity(0.18))
        stall(&ctx, t: t, pace: busy ? 1.6 : 1.0)
        stools(&ctx)
        if !compact { cat(&ctx, t: t) }
    }

    /// Bali's penjor: a tall bamboo pole arching over, with a dangling ornament.
    private func penjor(_ ctx: inout GraphicsContext, t: Double) {
        let base = CGPoint(x: 30, y: 232)
        let sway = sin(t * 0.7) * 3
        let tip = CGPoint(x: 96 + sway, y: 28 + abs(sway) * 0.4)
        var pole = Path()
        pole.move(to: base)
        pole.addQuadCurve(to: tip, control: CGPoint(x: 22, y: 30))
        ctx.stroke(pole, with: .color(Color(hex: 0xC9A15A)), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        // Woven fringe along the arch
        for i in 0..<9 {
            let f = 0.45 + Double(i) / 9 * 0.5
            let x = (1 - f) * (1 - f) * base.x + 2 * (1 - f) * f * 22 + f * f * tip.x
            let y = (1 - f) * (1 - f) * base.y + 2 * (1 - f) * f * 30 + f * f * tip.y
            var fringe = Path()
            fringe.move(to: CGPoint(x: x, y: y))
            fringe.addLine(to: CGPoint(x: x + sin(t * 2 + Double(i)) * 1.5, y: y + 9))
            ctx.stroke(fringe, with: .color(Color(hex: 0xE8C77A)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
        // Ornament on a string, swinging
        let swing = sin(t * 1.6) * 0.25
        let len = 26.0
        let orn = CGPoint(x: tip.x + sin(swing) * len, y: tip.y + cos(swing) * len)
        var string = Path()
        string.move(to: tip)
        string.addLine(to: orn)
        ctx.stroke(string, with: .color(Color(hex: 0xC9A15A)), lineWidth: 1.2)
        Kawung.draw(in: ctx, center: CGPoint(x: orn.x, y: orn.y + 7), size: 16, angle: .radians(swing),
                    color: Theme.sambal, filled: true)
    }

    // MARK: Stall

    private func stall(_ ctx: inout GraphicsContext, t: Double, pace: Double) {
        // Back wall + shelf
        ctx.fill(Path(CGRect(x: 96, y: 86, width: 208, height: 146)), with: .color(wall))
        var shelf = Path()
        shelf.move(to: CGPoint(x: 100, y: 124))
        shelf.addLine(to: CGPoint(x: 300, y: 124))
        ctx.stroke(shelf, with: .color(woodDark.opacity(0.6)), lineWidth: 2.5)
        let jarColors = [Theme.kunyit, Theme.sawah, Theme.jambu, Theme.laut, Theme.sambal, Theme.kunyit]
        for (i, c) in jarColors.enumerated() {
            let x = 108.0 + Double(i) * 30 + (i > 2 ? 30 : 0)
            let h = 14.0 + Double(i % 3) * 3
            let jar = Path(roundedRect: CGRect(x: x, y: 124 - h, width: 13, height: h), cornerRadius: 2.5)
            ctx.fill(jar, with: .color(c.opacity(0.75)))
            ctx.fill(Path(CGRect(x: x - 1, y: 124 - h - 3, width: 15, height: 3)), with: .color(woodDark.opacity(0.7)))
        }

        // Posts
        for x in [88.0, 304] {
            ctx.fill(Path(roundedRect: CGRect(x: x, y: 72, width: 9, height: 160), cornerRadius: 2), with: .color(woodDark))
        }

        lamp(&ctx, t: t)
        Figure(hair: .bun(flower: Theme.jambu), outfit: Theme.laut)
            .draw(&ctx, head: CGPoint(x: 226, y: 126), t: t, speaking: speaking, expression: expression, pace: pace)
        counter(&ctx, t: t)
        pot(&ctx, t: t, pace: pace)
        roofAndAwning(&ctx, t: t)
        sign(&ctx, t: t)
    }

    private func roofAndAwning(_ ctx: inout GraphicsContext, t: Double) {
        var roofPath = Path()
        roofPath.move(to: CGPoint(x: 66, y: 74))
        roofPath.addLine(to: CGPoint(x: 112, y: 38))
        roofPath.addLine(to: CGPoint(x: 288, y: 38))
        roofPath.addLine(to: CGPoint(x: 334, y: 74))
        roofPath.closeSubpath()
        ctx.fill(roofPath, with: .linearGradient(Gradient(colors: [roof.lighter(0.08), roof.darker(0.1)]),
                                                 startPoint: CGPoint(x: 0, y: 38), endPoint: CGPoint(x: 0, y: 74)))
        // Tile rows
        var tiles = Path()
        for row in 1..<4 {
            let y = 38.0 + Double(row) * 9
            let inset = 46.0 * (1 - Double(row) * 9 / 36)
            tiles.move(to: CGPoint(x: 66 + inset, y: y))
            tiles.addLine(to: CGPoint(x: 334 - inset, y: y))
        }
        for i in 0..<14 {
            let x = 116.0 + Double(i) * 13
            tiles.move(to: CGPoint(x: x, y: 38))
            tiles.addLine(to: CGPoint(x: x + (x - 200) * 0.26, y: 74))
        }
        ctx.stroke(tiles, with: .color(.black.opacity(0.12)), lineWidth: 1)
        // Ridge
        ctx.fill(Path(roundedRect: CGRect(x: 108, y: 34, width: 184, height: 6), cornerRadius: 3), with: .color(roof.darker(0.25)))

        // Scalloped striped awning
        let count = 14
        let w = 268.0 / Double(count)
        for i in 0..<count {
            let x = 66.0 + Double(i) * w
            let flutter = sin(t * 2.4 + Double(i) * 0.6) * 1.4
            var flap = Path()
            flap.move(to: CGPoint(x: x, y: 74))
            flap.addLine(to: CGPoint(x: x + w, y: 74))
            flap.addLine(to: CGPoint(x: x + w, y: 84 + flutter))
            flap.addQuadCurve(to: CGPoint(x: x, y: 84 + flutter), control: CGPoint(x: x + w / 2, y: 95 + flutter))
            flap.closeSubpath()
            ctx.fill(flap, with: .color(i % 2 == 0 ? Theme.sambal : Theme.card))
        }
        var edge = Path()
        edge.move(to: CGPoint(x: 66, y: 74))
        edge.addLine(to: CGPoint(x: 334, y: 74))
        ctx.stroke(edge, with: .color(roof.darker(0.3)), lineWidth: 2)
    }

    private func sign(_ ctx: inout GraphicsContext, t: Double) {
        let pivot = CGPoint(x: 152, y: 90)
        let angle = sin(t * 1.25) * 0.05
        var c = ctx
        c.translateBy(x: pivot.x, y: pivot.y)
        c.rotate(by: .radians(angle))
        var strings = Path()
        strings.move(to: CGPoint(x: -26, y: -4)); strings.addLine(to: CGPoint(x: -22, y: 8))
        strings.move(to: CGPoint(x: 26, y: -4)); strings.addLine(to: CGPoint(x: 22, y: 8))
        c.stroke(strings, with: .color(woodDark), lineWidth: 1.2)
        let board = Path(roundedRect: CGRect(x: -36, y: 8, width: 72, height: 22), cornerRadius: 4)
        c.fill(board, with: .color(woodDark))
        c.stroke(board, with: .color(Theme.kunyit.opacity(0.8)), lineWidth: 1.2)
        c.draw(Text("WARUNG").font(.system(size: 11, weight: .heavy, design: .rounded)).tracking(1.4)
                .foregroundColor(Theme.card), at: CGPoint(x: 0, y: 19))
    }

    private func lamp(_ ctx: inout GraphicsContext, t: Double) {
        for (x, phase) in [(104.0, 0.0), (284.0, 1.4)] {
            let swing = sin(t * 1.1 + phase) * 1.5
            let bulb = CGPoint(x: x + swing, y: 112)
            var cord = Path()
            cord.move(to: CGPoint(x: x, y: 86))
            cord.addLine(to: bulb)
            ctx.stroke(cord, with: .color(.black.opacity(0.4)), lineWidth: 1)
            let glow = 0.25 + 0.1 * sin(t * 2 + phase)
            ctx.fill(Path(ellipseIn: CGRect(x: bulb.x - 14, y: bulb.y - 10, width: 28, height: 28)),
                     with: .radialGradient(Gradient(colors: [Theme.kunyit.opacity(glow), .clear]),
                                           center: CGPoint(x: bulb.x, y: bulb.y + 4), startRadius: 0, endRadius: 14))
            ctx.fill(Path(ellipseIn: CGRect(x: bulb.x - 4.5, y: bulb.y, width: 9, height: 10)), with: .color(Color(hex: 0xFFE7A6)))
            ctx.fill(Path(CGRect(x: bulb.x - 3, y: bulb.y - 3, width: 6, height: 4)), with: .color(.black.opacity(0.55)))
        }
    }

    private func counter(_ ctx: inout GraphicsContext, t: Double) {
        // Front
        let front = Path(CGRect(x: 100, y: 176, width: 200, height: 56))
        ctx.fill(front, with: .color(wood))
        var planks = Path()
        for i in 1..<4 {
            let y = 176.0 + Double(i) * 14
            planks.move(to: CGPoint(x: 100, y: y)); planks.addLine(to: CGPoint(x: 300, y: y))
        }
        ctx.stroke(planks, with: .color(woodDark.opacity(0.5)), lineWidth: 1)
        // Batik band
        ctx.fill(Path(CGRect(x: 100, y: 198, width: 200, height: 12)), with: .color(Theme.indigo))
        for i in 0..<10 {
            Kawung.draw(in: ctx, center: CGPoint(x: 110 + Double(i) * 20, y: 204), size: 9, color: Theme.card.opacity(0.7), filled: false, lineWidth: 0.8)
        }
        // Top
        ctx.fill(Path(roundedRect: CGRect(x: 94, y: 170, width: 212, height: 8), cornerRadius: 2), with: .color(woodDark))

        // Glass case of dishes
        let glass = CGRect(x: 108, y: 140, width: 84, height: 30)
        ctx.fill(Path(roundedRect: glass, cornerRadius: 3), with: .color(Theme.laut.opacity(0.12)))
        let dishes: [(Double, Double, Color)] = [(118, 152, Theme.sambal), (136, 150, Theme.kunyit), (154, 153, Theme.sawah),
                                                (172, 151, woodDark), (124, 162, Theme.kunyit.darker(0.2)), (148, 163, Theme.card),
                                                (170, 162, Theme.sambal.darker(0.15))]
        for (x, y, color) in dishes {
            ctx.fill(Path(ellipseIn: CGRect(x: x - 7, y: y - 3, width: 14, height: 7)), with: .color(.white.opacity(0.9)))
            ctx.fill(Path(ellipseIn: CGRect(x: x - 5, y: y - 3.5, width: 10, height: 5)), with: .color(color))
        }
        ctx.stroke(Path(roundedRect: glass, cornerRadius: 3), with: .color(.white.opacity(0.9)), lineWidth: 1.4)
        // Moving glint
        let g = (t * 0.35).truncatingRemainder(dividingBy: 1.6)
        if g < 1 {
            var glint = Path()
            let gx = glass.minX + g * (glass.width + 20) - 10
            glint.move(to: CGPoint(x: gx, y: glass.maxY))
            glint.addLine(to: CGPoint(x: gx + 10, y: glass.minY))
            var clipped = ctx
            clipped.clip(to: Path(roundedRect: glass, cornerRadius: 3))
            clipped.stroke(glint, with: .color(.white.opacity(0.6)), lineWidth: 4)
        }
        // Krupuk tin
        let tin = CGRect(x: 276, y: 136, width: 20, height: 34)
        ctx.fill(Path(roundedRect: tin, cornerRadius: 3), with: .color(Theme.card.opacity(0.75)))
        for i in 0..<4 {
            ctx.fill(Path(ellipseIn: CGRect(x: tin.minX + 2 + Double(i % 2) * 7, y: tin.minY + 6 + Double(i) * 6, width: 10, height: 7)),
                     with: .color(Theme.kunyit.lighter(0.3)))
        }
        ctx.fill(Path(roundedRect: CGRect(x: tin.minX - 1, y: tin.minY - 4, width: 22, height: 5), cornerRadius: 2), with: .color(Theme.laut))
    }

    private func pot(_ ctx: inout GraphicsContext, t: Double, pace: Double) {
        let base = CGPoint(x: 250, y: 170)
        // Steam puffs
        for i in 0..<4 {
            let p = (t * 0.45 * pace + Double(i) / 4).truncatingRemainder(dividingBy: 1)
            let y = base.y - 22 - p * 58
            let x = base.x + sin(p * 6 + Double(i)) * 6
            let r = 4 + p * 7
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                     with: .color(.white.opacity((1 - p) * 0.75)))
        }
        // Pot body + lid + handles
        ctx.fill(Path(roundedRect: CGRect(x: base.x - 14, y: base.y - 18, width: 28, height: 18), cornerRadius: 4), with: .color(Color(hex: 0x5B5E66)))
        ctx.fill(Path(roundedRect: CGRect(x: base.x - 16, y: base.y - 21, width: 32, height: 4), cornerRadius: 2), with: .color(Color(hex: 0x474A52)))
        ctx.fill(Path(ellipseIn: CGRect(x: base.x - 3, y: base.y - 25, width: 6, height: 4)), with: .color(Color(hex: 0x474A52)))
    }

    private func stools(_ ctx: inout GraphicsContext) {
        for (x, color) in [(58.0, Theme.sambal), (338.0, Theme.indigo)] {
            var legs = Path()
            legs.move(to: CGPoint(x: x - 12, y: 216)); legs.addLine(to: CGPoint(x: x - 15, y: 236))
            legs.move(to: CGPoint(x: x + 12, y: 216)); legs.addLine(to: CGPoint(x: x + 15, y: 236))
            legs.move(to: CGPoint(x: x - 4, y: 218)); legs.addLine(to: CGPoint(x: x - 5, y: 236))
            legs.move(to: CGPoint(x: x + 4, y: 218)); legs.addLine(to: CGPoint(x: x + 5, y: 236))
            ctx.stroke(legs, with: .color(color.darker(0.12)), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
            ctx.fill(Path(ellipseIn: CGRect(x: x - 17, y: 210, width: 34, height: 9)), with: .color(color))
            ctx.fill(Path(ellipseIn: CGRect(x: x - 10, y: 212, width: 20, height: 4)), with: .color(color.lighter(0.2)))
        }
        // An iced tea waiting on the red stool
        let cup = CGRect(x: 52, y: 196, width: 11, height: 15)
        ctx.fill(Path(roundedRect: cup, cornerRadius: 2), with: .color(Color(hex: 0xC97B2E).opacity(0.85)))
        ctx.fill(Path(CGRect(x: cup.minX + 2, y: cup.minY + 2, width: 3, height: 3)), with: .color(.white.opacity(0.8)))
        var straw = Path()
        straw.move(to: CGPoint(x: cup.midX + 2, y: cup.minY + 2)); straw.addLine(to: CGPoint(x: cup.midX + 5, y: cup.minY - 7))
        ctx.stroke(straw, with: .color(Theme.jambu), lineWidth: 1.6)
    }

    private func cat(_ ctx: inout GraphicsContext, t: Double) {
        let c = CGPoint(x: 372, y: 238)
        let orange = Color(hex: 0xE39B4A)
        // Tail swish
        let swish = sin(t * 1.4) * 0.5
        var tail = Path()
        tail.move(to: CGPoint(x: c.x + 12, y: c.y))
        tail.addQuadCurve(to: CGPoint(x: c.x + 22 + cos(swish) * 4, y: c.y - 12 + sin(swish) * 6),
                          control: CGPoint(x: c.x + 26, y: c.y + 2))
        ctx.stroke(tail, with: .color(orange), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
        // Body (breathing)
        let breathe = 1 + 0.04 * sin(t * 2)
        ctx.fill(Path(ellipseIn: CGRect(x: c.x - 14, y: c.y - 8 * breathe, width: 28, height: 12 * breathe)), with: .color(orange))
        // Head
        let head = CGPoint(x: c.x - 13, y: c.y - 4)
        ctx.fill(Path(ellipseIn: CGRect(x: head.x - 7, y: head.y - 6, width: 14, height: 11)), with: .color(orange))
        var ears = Path()
        ears.move(to: CGPoint(x: head.x - 6, y: head.y - 3)); ears.addLine(to: CGPoint(x: head.x - 5, y: head.y - 10)); ears.addLine(to: CGPoint(x: head.x - 1, y: head.y - 5))
        ears.move(to: CGPoint(x: head.x + 1, y: head.y - 5)); ears.addLine(to: CGPoint(x: head.x + 5, y: head.y - 10)); ears.addLine(to: CGPoint(x: head.x + 6, y: head.y - 3))
        ctx.fill(ears, with: .color(orange))
        // Sleeping eyes
        var eyes = Path()
        eyes.move(to: CGPoint(x: head.x - 4, y: head.y)); eyes.addLine(to: CGPoint(x: head.x - 1.5, y: head.y))
        eyes.move(to: CGPoint(x: head.x + 1.5, y: head.y)); eyes.addLine(to: CGPoint(x: head.x + 4, y: head.y))
        ctx.stroke(eyes, with: .color(Theme.ink.opacity(0.7)), lineWidth: 1)
        // Zzz
        let z = (t * 0.4).truncatingRemainder(dividingBy: 1)
        ctx.draw(Text("z").font(.system(size: 7 + z * 4, weight: .bold, design: .rounded)).foregroundColor(Theme.inkSoft.opacity(1 - z)),
                 at: CGPoint(x: head.x - 4 - z * 4, y: head.y - 12 - z * 14))
    }
}
