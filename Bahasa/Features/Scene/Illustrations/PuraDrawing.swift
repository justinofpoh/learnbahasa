import SwiftUI

/// A temple gate: a split candi bentar with stone steps, a tiered meru roof beyond, yellow tedung
/// umbrellas swaying, frangipani, offerings with incense, and Bli Komang holding out a folded kamen.
struct PuraDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let brick = Color(hex: 0xB5583A)
    private let stone = Color(hex: 0x9C8F7E)
    private let thatch = Color(hex: 0x4A3A2E)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        Illo.sky(&ctx, f, top: Color(hex: 0xF2D9AC), bottom: Color(hex: 0xF6EBD7))
        Illo.sun(&ctx, t: t, center: CGPoint(x: 340, y: 40))
        Illo.clouds(&ctx, f, t: t, count: compact ? 1 : 2)
        Illo.hills(&ctx, f, base: 172)
        meru(&ctx, t: t)
        Illo.ground(&ctx, f, y: 222, color: Color(hex: 0xD9C9A8), pebbles: Theme.kopi.opacity(0.2))
        steps(&ctx)
        gate(&ctx, x: 96, mirrored: false)
        gate(&ctx, x: 304, mirrored: true)
        umbrella(&ctx, at: CGPoint(x: 52, y: 228), t: t, phase: 0)
        umbrella(&ctx, at: CGPoint(x: 352, y: 228), t: t, phase: 1.4)
        offering(&ctx, at: CGPoint(x: 150, y: 232), t: t)

        var person = ctx
        person.translateBy(x: 236, y: 236)
        person.scaleBy(x: 0.76, y: 0.76)
        person.translateBy(x: -236, y: -236)
        Figure(skin: Color(hex: 0xB27B50), hair: .udeng(Theme.kunyit), outfit: Theme.card, trim: Theme.kunyit, collar: .crew,
               lower: .sarong(Theme.sawah))
            .draw(&person, head: CGPoint(x: 236, y: 122), t: t, speaking: speaking, expression: expression,
                  pace: busy ? 1.6 : 1,
                  gesture: .holding(CGPoint(x: 276, y: 166)) { ctx, p in kamen(&ctx, at: p, t: t) })
    }

    /// A multi-tiered shrine roof seen through the gap in the gate.
    private func meru(_ ctx: inout GraphicsContext, t: Double) {
        let cx = 200.0
        ctx.fill(Path(CGRect(x: cx - 14, y: 120, width: 28, height: 60)), with: .color(brick.darker(0.1)))
        for k in 0..<4 {
            let w = 76.0 - Double(k) * 14
            let y = 128 - Double(k) * 18
            var tier = Path()
            tier.move(to: CGPoint(x: cx - w / 2, y: y)); tier.addLine(to: CGPoint(x: cx - w / 2 + 10, y: y - 12))
            tier.addLine(to: CGPoint(x: cx + w / 2 - 10, y: y - 12)); tier.addLine(to: CGPoint(x: cx + w / 2, y: y))
            tier.closeSubpath()
            ctx.fill(tier, with: .color(thatch))
        }
        ctx.fill(Path(ellipseIn: CGRect(x: cx - 4, y: 60, width: 8, height: 8)), with: .color(Theme.kunyit))
    }

    private func steps(_ ctx: inout GraphicsContext) {
        for k in 0..<4 {
            let w = 92.0 + Double(k) * 14
            let y = 188 + Double(k) * 9
            ctx.fill(Path(CGRect(x: 200 - w / 2, y: y, width: w, height: 9)), with: .color(stone.lighter(Double(k) * 0.04)))
            ctx.fill(Path(CGRect(x: 200 - w / 2, y: y, width: w, height: 1.5)), with: .color(.white.opacity(0.25)))
        }
    }

    /// One half of the split gate: a stepped brick tower with a sheer inner edge.
    private func gate(_ ctx: inout GraphicsContext, x: Double, mirrored: Bool) {
        var c = ctx
        c.translateBy(x: x, y: 0)
        if mirrored { c.scaleBy(x: -1, y: 1) }
        var tower = Path()
        let base = 226.0
        tower.move(to: CGPoint(x: -44, y: base))
        var y = base
        var left = -44.0
        for step in 0..<6 {
            let h = step == 0 ? 44.0 : 22
            y -= h
            tower.addLine(to: CGPoint(x: left, y: y))
            left += 7
            tower.addLine(to: CGPoint(x: left, y: y))
        }
        tower.addLine(to: CGPoint(x: left, y: y - 16))
        tower.addLine(to: CGPoint(x: 52, y: y - 16))
        tower.addLine(to: CGPoint(x: 52, y: base))
        tower.closeSubpath()
        c.fill(tower, with: .color(brick))
        var lines = Path()
        for ly in stride(from: y, through: base, by: 7) {
            lines.move(to: CGPoint(x: -44, y: ly)); lines.addLine(to: CGPoint(x: 52, y: ly))
        }
        var clipped = c
        clipped.clip(to: tower)
        clipped.stroke(lines, with: .color(.black.opacity(0.12)), lineWidth: 0.8)
        // Carved stone bands
        for by in [base - 44, base - 110] {
            clipped.fill(Path(CGRect(x: -50, y: by - 4, width: 104, height: 6)), with: .color(stone.lighter(0.15)))
        }
        c.fill(Path(ellipseIn: CGRect(x: left + 10, y: y - 26, width: 10, height: 10)), with: .color(stone.lighter(0.1)))
    }

    private func umbrella(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double, phase: Double) {
        let sway = sin(t * 0.9 + phase) * 0.04
        var c = ctx
        c.translateBy(x: p.x, y: p.y)
        c.rotate(by: .radians(sway))
        c.fill(Path(CGRect(x: -1.5, y: -110, width: 3, height: 110)), with: .color(Theme.kopi))
        var canopy = Path()
        canopy.move(to: CGPoint(x: -26, y: -96))
        canopy.addQuadCurve(to: CGPoint(x: 26, y: -96), control: CGPoint(x: 0, y: -126))
        canopy.closeSubpath()
        c.fill(canopy, with: .color(Theme.kunyit))
        // Fringe that flutters
        var fringe = Path()
        for k in 0..<9 {
            let x = -24 + Double(k) * 6
            fringe.move(to: CGPoint(x: x, y: -96))
            fringe.addLine(to: CGPoint(x: x + sin(t * 3 + Double(k) + phase) * 1.5, y: -86))
        }
        c.stroke(fringe, with: .color(Theme.kunyit.darker(0.1)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        c.fill(Path(ellipseIn: CGRect(x: -3, y: -124, width: 6, height: 6)), with: .color(Theme.kunyit.darker(0.2)))
    }

    private func offering(_ ctx: inout GraphicsContext, at c: CGPoint, t: Double) {
        Illo.puffs(&ctx, from: CGPoint(x: c.x + 6, y: c.y - 16), t: t, rate: 0.2, rise: 40, drift: -6, color: .white, count: compact ? 2 : 4)
        var stick = Path()
        stick.move(to: CGPoint(x: c.x + 4, y: c.y - 2)); stick.addLine(to: CGPoint(x: c.x + 7, y: c.y - 16))
        ctx.stroke(stick, with: .color(Theme.kopi), lineWidth: 1.2)
        ctx.fill(Path(ellipseIn: CGRect(x: c.x + 5.5, y: c.y - 18, width: 3, height: 3)), with: .color(Theme.sambal))
        ctx.fill(Path(roundedRect: CGRect(x: c.x - 13, y: c.y - 4, width: 26, height: 8), cornerRadius: 2), with: .color(Color(hex: 0xA8B85A)))
        for (k, color) in [Theme.jambu, Theme.kunyit, Color.white, Theme.sambal].enumerated() {
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - 11 + Double(k) * 5.5, y: c.y - 8 + Double(k % 2) * 2, width: 6, height: 6)), with: .color(color))
        }
    }

    private func kamen(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        var c = ctx
        c.translateBy(x: p.x + 4, y: p.y - 6)
        c.rotate(by: .radians(sin(t * 1.6) * 0.04))
        for (k, color) in [Theme.indigo, Theme.sambal, Theme.sawah].enumerated() {
            let r = CGRect(x: -2, y: Double(k) * -6, width: 30, height: 6)
            c.fill(Path(roundedRect: r, cornerRadius: 2), with: .color(color))
            Kawung.draw(in: c, center: CGPoint(x: r.midX, y: r.midY), size: 5, color: .white.opacity(0.5), filled: false, lineWidth: 0.6)
        }
    }
}
