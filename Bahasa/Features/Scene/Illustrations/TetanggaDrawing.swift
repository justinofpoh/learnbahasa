import SwiftUI

/// Dusk at a Balinese house gate: a brick angkul-angkul with a little roof, stone walls, a lamp
/// coming on, a frangipani, a canang offering with a curl of incense, fireflies, and Pak Nyoman in
/// his udeng holding a plate wrapped in banana leaf.
struct TetanggaDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let brick = Color(hex: 0xB5583A)
    private let stone = Color(hex: 0x9C8F7E)
    private let thatch = Color(hex: 0x5A4334)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        Illo.sky(&ctx, f, top: Color(hex: 0xE7B98C), bottom: Color(hex: 0xF4DDBE))
        moon(&ctx, t: t)
        Illo.hills(&ctx, f, base: 176, color: Theme.sawah.darker(0.1))
        Illo.palm(&ctx, t: t, base: CGPoint(x: 34, y: 230), height: 160, phase: 0.4)
        Illo.ground(&ctx, f, y: 226, color: Color(hex: 0xCDB997), pebbles: Theme.kopi.opacity(0.2))
        walls(&ctx, f)
        gate(&ctx, t: t)
        frangipani(&ctx, t: t)
        canang(&ctx, t: t)

        // Scaled from his feet so he stands in the gateway.
        var person = ctx
        person.translateBy(x: 200, y: 234)
        person.scaleBy(x: 0.78, y: 0.78)
        person.translateBy(x: -200, y: -234)
        Figure(skin: Color(hex: 0xB57D52), hair: .udeng(Theme.card), outfit: Theme.card, trim: Theme.sawah, collar: .crew,
               lower: .sarong(Theme.kopi))
            .draw(&person, head: CGPoint(x: 200, y: 122), t: t, speaking: speaking, expression: expression,
                  pace: busy ? 1.6 : 1,
                  gesture: .holding(CGPoint(x: 240, y: 168)) { ctx, p in plate(&ctx, at: p, t: t) })
        fireflies(&ctx, t: t)
    }

    private func moon(_ ctx: inout GraphicsContext, t: Double) {
        let c = CGPoint(x: 330, y: 44)
        let glow = 0.5 + 0.5 * sin(t * 0.8)
        ctx.fill(Path(ellipseIn: CGRect(x: c.x - 26, y: c.y - 26, width: 52, height: 52)), with: .color(.white.opacity(0.12 + 0.08 * glow)))
        ctx.fill(Path(ellipseIn: CGRect(x: c.x - 14, y: c.y - 14, width: 28, height: 28)), with: .color(Color(hex: 0xFFF3D6)))
        ctx.fill(Path(ellipseIn: CGRect(x: c.x - 6, y: c.y - 16, width: 26, height: 26)), with: .color(Color(hex: 0xEBC79E)))
    }

    private func walls(_ ctx: inout GraphicsContext, _ f: IlloFrame) {
        for (x0, x1) in [(f.left, 136.0), (264.0, f.right)] {
            let r = CGRect(x: x0, y: 168, width: x1 - x0, height: 60)
            ctx.fill(Path(r), with: .color(stone))
            var courses = Path()
            for (k, y) in stride(from: 178.0, through: 222, by: 11).enumerated() {
                courses.move(to: CGPoint(x: x0, y: y)); courses.addLine(to: CGPoint(x: x1, y: y))
                for x in stride(from: x0 + Double(k % 2) * 11, through: x1, by: 22) {
                    courses.move(to: CGPoint(x: x, y: y)); courses.addLine(to: CGPoint(x: x, y: y + 11))
                }
            }
            ctx.stroke(courses, with: .color(.black.opacity(0.12)), lineWidth: 1)
            ctx.fill(Path(CGRect(x: x0, y: 162, width: x1 - x0, height: 8)), with: .color(brick))
        }
    }

    /// The angkul-angkul: two brick pillars and a little thatched roof over the doorway.
    private func gate(_ ctx: inout GraphicsContext, t: Double) {
        let doorway = CGRect(x: 160, y: 96, width: 80, height: 132)
        ctx.fill(Path(doorway), with: .color(Color(hex: 0x6B4A36).opacity(0.55)))
        for x in [136.0, 240] {
            let pillar = CGRect(x: x, y: 90, width: 24, height: 138)
            ctx.fill(Path(pillar), with: .color(brick))
            var lines = Path()
            for y in stride(from: pillar.minY + 8, through: pillar.maxY, by: 8) {
                lines.move(to: CGPoint(x: pillar.minX, y: y)); lines.addLine(to: CGPoint(x: pillar.maxX, y: y))
            }
            ctx.stroke(lines, with: .color(.black.opacity(0.12)), lineWidth: 0.8)
            // Carved stone caps
            ctx.fill(Path(roundedRect: CGRect(x: x - 3, y: 120, width: 30, height: 8), cornerRadius: 2), with: .color(stone.lighter(0.15)))
            ctx.fill(Path(roundedRect: CGRect(x: x - 3, y: 200, width: 30, height: 8), cornerRadius: 2), with: .color(stone.lighter(0.15)))
        }
        // Roof
        var roof = Path()
        roof.move(to: CGPoint(x: 120, y: 98)); roof.addLine(to: CGPoint(x: 200, y: 52)); roof.addLine(to: CGPoint(x: 280, y: 98))
        roof.closeSubpath()
        ctx.fill(roof, with: .color(thatch))
        var straw = Path()
        for k in 0..<9 {
            let x = 132 + Double(k) * 17
            straw.move(to: CGPoint(x: x, y: 96)); straw.addLine(to: CGPoint(x: (x + 200) / 2, y: 74))
        }
        ctx.stroke(straw, with: .color(.white.opacity(0.12)), lineWidth: 1)
        ctx.fill(Path(ellipseIn: CGRect(x: 194, y: 44, width: 12, height: 12)), with: .color(Theme.kunyit))
        // Lamp by the gate, flickering on.
        let flicker = 0.75 + 0.25 * sin(t * 7) * sin(t * 3.1)
        let lamp = CGPoint(x: 272, y: 132)
        ctx.fill(Path(ellipseIn: CGRect(x: lamp.x - 18, y: lamp.y - 16, width: 36, height: 36)), with: .color(Color(hex: 0xFFD98A).opacity(0.3 * flicker)))
        ctx.fill(Path(roundedRect: CGRect(x: lamp.x - 6, y: lamp.y - 6, width: 12, height: 16), cornerRadius: 3), with: .color(Color(hex: 0xFFE7A6).opacity(flicker)))
        ctx.stroke(Path(roundedRect: CGRect(x: lamp.x - 6, y: lamp.y - 6, width: 12, height: 16), cornerRadius: 3), with: .color(thatch), lineWidth: 1.5)
    }

    private func frangipani(_ ctx: inout GraphicsContext, t: Double) {
        var trunk = Path()
        trunk.move(to: CGPoint(x: 330, y: 168))
        trunk.addQuadCurve(to: CGPoint(x: 310, y: 112), control: CGPoint(x: 336, y: 134))
        trunk.move(to: CGPoint(x: 328, y: 140))
        trunk.addQuadCurve(to: CGPoint(x: 360, y: 112), control: CGPoint(x: 348, y: 132))
        ctx.stroke(trunk, with: .color(Color(hex: 0x8C7A66)), style: StrokeStyle(lineWidth: 5, lineCap: .round))
        for (i, tip) in [CGPoint(x: 310, y: 108), CGPoint(x: 360, y: 108)].enumerated() {
            let sway = sin(t * 1.1 + Double(i)) * 2
            for k in 0..<5 {
                var c = ctx
                c.translateBy(x: tip.x + sway, y: tip.y)
                c.rotate(by: .radians(Double(k) / 5 * 2 * .pi + Double(i)))
                c.fill(Path(ellipseIn: CGRect(x: -5, y: -15, width: 10, height: 22)), with: .color(Theme.sawah.opacity(0.9)))
            }
            blossom(&ctx, at: CGPoint(x: tip.x + sway - 3, y: tip.y - 4))
        }
    }

    private func blossom(_ ctx: inout GraphicsContext, at p: CGPoint) {
        for k in 0..<5 {
            var c = ctx
            c.translateBy(x: p.x, y: p.y)
            c.rotate(by: .radians(Double(k) / 5 * 2 * .pi))
            c.fill(Path(ellipseIn: CGRect(x: -2.5, y: -8, width: 5, height: 8)), with: .color(.white))
        }
        ctx.fill(Path(ellipseIn: CGRect(x: p.x - 2.5, y: p.y - 2.5, width: 5, height: 5)), with: .color(Theme.kunyit))
    }

    /// A canang sari on the step: a palm-leaf tray of petals, with incense smoke curling up.
    private func canang(_ ctx: inout GraphicsContext, t: Double) {
        let c = CGPoint(x: 112, y: 234)
        Illo.puffs(&ctx, from: CGPoint(x: c.x + 6, y: c.y - 16), t: t, rate: 0.2, rise: 40, drift: 8, color: .white, count: compact ? 2 : 4)
        var stick = Path()
        stick.move(to: CGPoint(x: c.x + 4, y: c.y - 2)); stick.addLine(to: CGPoint(x: c.x + 7, y: c.y - 16))
        ctx.stroke(stick, with: .color(Theme.kopi), lineWidth: 1.2)
        ctx.fill(Path(ellipseIn: CGRect(x: c.x + 5.5, y: c.y - 18, width: 3, height: 3)), with: .color(Theme.sambal))
        ctx.fill(Path(roundedRect: CGRect(x: c.x - 13, y: c.y - 4, width: 26, height: 8), cornerRadius: 2), with: .color(Color(hex: 0xA8B85A)))
        for (k, color) in [Theme.jambu, Theme.kunyit, Color.white, Theme.sambal].enumerated() {
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - 11 + Double(k) * 5.5, y: c.y - 8 + Double(k % 2) * 2, width: 6, height: 6)), with: .color(color))
        }
    }

    private func plate(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        var c = ctx
        c.translateBy(x: p.x + 6, y: p.y - 4)
        c.rotate(by: .radians(sin(t * 1.5) * 0.04))
        c.fill(Path(ellipseIn: CGRect(x: -20, y: -2, width: 40, height: 10)), with: .color(Theme.card))
        var leaf = Path()
        leaf.move(to: CGPoint(x: -16, y: 2))
        leaf.addQuadCurve(to: CGPoint(x: 16, y: 2), control: CGPoint(x: 0, y: -22))
        leaf.closeSubpath()
        c.fill(leaf, with: .color(Theme.sawah))
        var vein = Path()
        vein.move(to: CGPoint(x: -12, y: 0)); vein.addQuadCurve(to: CGPoint(x: 12, y: 0), control: CGPoint(x: 0, y: -14))
        c.stroke(vein, with: .color(Theme.sawah.lighter(0.3)), lineWidth: 1)
        c.fill(Path(roundedRect: CGRect(x: -2, y: -12, width: 4, height: 6), cornerRadius: 1), with: .color(Theme.kopi))
    }

    private func fireflies(_ ctx: inout GraphicsContext, t: Double) {
        let count = compact ? 3 : 6
        for i in 0..<count {
            let x = 70 + Double(i) * 52 + sin(t * 0.6 + Double(i) * 2) * 16
            let y = 140 + cos(t * 0.5 + Double(i)) * 24 - Double(i % 3) * 18
            let blink = max(0, sin(t * 2 + Double(i) * 1.7))
            ctx.fill(Path(ellipseIn: CGRect(x: x - 5, y: y - 5, width: 10, height: 10)), with: .color(Color(hex: 0xFFE7A6).opacity(0.25 * blink)))
            ctx.fill(Path(ellipseIn: CGRect(x: x - 1.5, y: y - 1.5, width: 3, height: 3)), with: .color(Color(hex: 0xFFF3C4).opacity(blink)))
        }
    }
}
