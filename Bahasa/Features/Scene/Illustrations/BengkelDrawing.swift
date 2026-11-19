import SwiftUI

/// A roadside bengkel: a corrugated tin roof, tyres hanging on the wall, a hand-painted TAMBAL BAN
/// sign, a humming compressor, a glass of kopi on a stool, your scooter up front, and Bli Made
/// turning a wrench.
struct BengkelDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let tin = Color(hex: 0x9AA4AD)
    private let wall = Color(hex: 0xE8D9BC)
    private let tyre = Color(hex: 0x2B2622)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        Illo.sky(&ctx, f, top: Color(hex: 0xF5D7A0), bottom: Color(hex: 0xF6EBD7))
        Illo.sun(&ctx, t: t, center: CGPoint(x: 352, y: 40))
        Illo.clouds(&ctx, f, t: t, count: compact ? 1 : 2)
        Illo.hills(&ctx, f, base: 172)
        Illo.palm(&ctx, t: t, base: CGPoint(x: 384, y: 232), height: 140, phase: 1.1)
        Illo.ground(&ctx, f, y: 226, color: Color(hex: 0xD8C7A5), pebbles: Theme.kopi.opacity(0.22))
        shed(&ctx, t: t)
        sign(&ctx, t: t)
        compressor(&ctx, t: t)
        stool(&ctx, t: t)

        let wrench = CGPoint(x: 262 + sin(t * (busy ? 7 : 4)) * 4, y: 176 + cos(t * (busy ? 7 : 4)) * 3)
        Figure(skin: Color(hex: 0xA8724A), hair: .short, outfit: Color(hex: 0x4A5A7A), trim: Theme.kunyit, collar: .jacket)
            .draw(&ctx, head: CGPoint(x: 226, y: 122), t: t, speaking: speaking, expression: expression,
                  pace: busy ? 1.6 : 1,
                  gesture: .holding(wrench) { ctx, p in spanner(&ctx, at: p, t: t) })
        scooter(&ctx, t: t)
    }

    private func shed(_ ctx: inout GraphicsContext, t: Double) {
        let back = CGRect(x: 120, y: 74, width: 220, height: 154)
        ctx.fill(Path(back), with: .color(wall))
        ctx.fill(Path(CGRect(x: back.minX, y: back.maxY - 26, width: back.width, height: 26)), with: .color(wall.darker(0.08)))
        // Posts
        for x in [back.minX - 2, back.maxX - 6] {
            ctx.fill(Path(CGRect(x: x, y: back.minY, width: 8, height: back.height)), with: .color(Theme.kopi))
        }
        // Tin roof with ridges
        var roof = Path()
        roof.move(to: CGPoint(x: 104, y: 80)); roof.addLine(to: CGPoint(x: 120, y: 50))
        roof.addLine(to: CGPoint(x: 352, y: 46)); roof.addLine(to: CGPoint(x: 360, y: 78))
        roof.closeSubpath()
        ctx.fill(roof, with: .color(tin))
        var ridges = Path()
        for x in stride(from: 112.0, through: 352, by: 10) {
            ridges.move(to: CGPoint(x: x + 8, y: 49)); ridges.addLine(to: CGPoint(x: x, y: 79))
        }
        ctx.stroke(ridges, with: .color(.white.opacity(0.35)), lineWidth: 1.2)
        ctx.fill(Path(CGRect(x: 104, y: 78, width: 256, height: 4)), with: .color(tin.darker(0.2)))
        // Tyres hanging on nails, swaying a little.
        for (i, x) in [150.0, 190, 300].enumerated() {
            let sway = sin(t * 1.3 + Double(i)) * 0.05
            var c = ctx
            c.translateBy(x: x, y: 90)
            c.rotate(by: .radians(sway))
            c.fill(Path(ellipseIn: CGRect(x: -2, y: -2, width: 4, height: 4)), with: .color(Theme.inkSoft))
            let ring = Path(ellipseIn: CGRect(x: -15, y: 2, width: 30, height: 30))
            c.stroke(ring, with: .color(tyre), lineWidth: 7)
            c.stroke(Path(ellipseIn: CGRect(x: -11.5, y: 5.5, width: 23, height: 23)), with: .color(.white.opacity(0.08)), lineWidth: 1)
        }
        // Tool board
        let board = CGRect(x: 266, y: 98, width: 28, height: 36)
        ctx.fill(Path(roundedRect: board, cornerRadius: 3), with: .color(Theme.kopi.lighter(0.15)))
        for (k, color) in [Theme.sambal, Theme.kunyit, Theme.laut].enumerated() {
            ctx.fill(Path(roundedRect: CGRect(x: board.minX + 4 + Double(k) * 8, y: board.minY + 4, width: 4, height: 24), cornerRadius: 2),
                     with: .color(color))
        }
    }

    /// The hand-painted sign every rider looks for, leaning on an old tyre.
    private func sign(_ ctx: inout GraphicsContext, t: Double) {
        ctx.stroke(Path(ellipseIn: CGRect(x: 26, y: 196, width: 40, height: 40)), with: .color(tyre), lineWidth: 9)
        var c = ctx
        c.translateBy(x: 50, y: 170)
        c.rotate(by: .radians(-0.08))
        let board = CGRect(x: -38, y: -40, width: 76, height: 60)
        c.fill(Path(roundedRect: board, cornerRadius: 4), with: .color(.white))
        c.stroke(Path(roundedRect: board, cornerRadius: 4), with: .color(Theme.sambal), lineWidth: 2)
        c.draw(Text("TAMBAL").font(.system(size: 13, weight: .black, design: .rounded)).foregroundColor(Theme.sambal),
               at: CGPoint(x: 0, y: -22))
        c.draw(Text("BAN").font(.system(size: 17, weight: .black, design: .rounded)).foregroundColor(Theme.ink),
               at: CGPoint(x: 0, y: -4))
        // A little arrow that nudges sideways, hand-painted style.
        let nudge = sin(t * 3) * 2
        var arrow = Path()
        arrow.move(to: CGPoint(x: -14 + nudge, y: 12)); arrow.addLine(to: CGPoint(x: 10 + nudge, y: 12))
        arrow.move(to: CGPoint(x: 4 + nudge, y: 7)); arrow.addLine(to: CGPoint(x: 10 + nudge, y: 12)); arrow.addLine(to: CGPoint(x: 4 + nudge, y: 17))
        c.stroke(arrow, with: .color(Theme.sambal), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        c.fill(Path(CGRect(x: -3, y: 20, width: 6, height: 26)), with: .color(Theme.kopi))
    }

    private func compressor(_ ctx: inout GraphicsContext, t: Double) {
        let hum = sin(t * 30) * 0.5
        let tank = CGRect(x: 134 + hum, y: 196, width: 46, height: 26)
        ctx.fill(Path(roundedRect: tank, cornerRadius: 12), with: .color(Theme.sambal))
        ctx.fill(Path(roundedRect: CGRect(x: tank.minX + 10, y: tank.minY - 8, width: 20, height: 10), cornerRadius: 2), with: .color(Theme.inkSoft))
        for dx in [8.0, 38] {
            ctx.fill(Path(ellipseIn: CGRect(x: tank.minX + dx - 4, y: tank.maxY - 2, width: 8, height: 8)), with: .color(tyre))
        }
        // Gauge with a trembling needle
        let g = CGPoint(x: tank.maxX - 10, y: tank.minY + 4)
        ctx.fill(Path(ellipseIn: CGRect(x: g.x - 6, y: g.y - 6, width: 12, height: 12)), with: .color(.white))
        var needle = Path()
        let a = 0.8 + sin(t * 9) * 0.12
        needle.move(to: g); needle.addLine(to: CGPoint(x: g.x + sin(a) * 5, y: g.y - cos(a) * 5))
        ctx.stroke(needle, with: .color(Theme.ink), lineWidth: 1)
        // Hose curling toward the scooter
        var hose = Path()
        hose.move(to: CGPoint(x: tank.minX + 4, y: tank.midY))
        hose.addCurve(to: CGPoint(x: 236, y: 226), control1: CGPoint(x: 110, y: 240), control2: CGPoint(x: 200, y: 246))
        ctx.stroke(hose, with: .color(Theme.ink.opacity(0.8)), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
    }

    private func stool(_ ctx: inout GraphicsContext, t: Double) {
        let seat = CGRect(x: 76, y: 206, width: 34, height: 6)
        ctx.fill(Path(roundedRect: seat, cornerRadius: 3), with: .color(Theme.laut))
        for dx in [4.0, 26] {
            ctx.fill(Path(CGRect(x: seat.minX + dx, y: seat.maxY, width: 4, height: 18)), with: .color(Theme.laut.darker(0.15)))
        }
        // Glass of kopi, steaming.
        let cup = CGRect(x: 86, y: 192, width: 12, height: 14)
        Illo.puffs(&ctx, from: CGPoint(x: cup.midX, y: cup.minY - 2), t: t, rate: 0.35, rise: 26, color: .white, count: 3)
        ctx.fill(Path(roundedRect: cup, cornerRadius: 2), with: .color(.white.opacity(0.75)))
        ctx.fill(Path(roundedRect: CGRect(x: cup.minX + 1.5, y: cup.minY + 4, width: cup.width - 3, height: cup.height - 5.5), cornerRadius: 1.5),
                 with: .color(Theme.kopi))
    }

    /// Your scooter, front wheel slowly turning as he works on it.
    private func scooter(_ ctx: inout GraphicsContext, t: Double) {
        let spin = t * (busy ? 2.4 : 1.2)
        for (x, flat) in [(232.0, true), (330.0, false)] {
            let c = CGPoint(x: x, y: 222)
            let squash = flat ? 3.0 : 0
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - 18, y: c.y - 18 + squash, width: 36, height: 36 - squash)), with: .color(tyre))
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - 8, y: c.y - 8 + squash / 2, width: 16, height: 16 - squash / 2)), with: .color(Color(hex: 0xB9B3A8)))
            var spokes = Path()
            for k in 0..<3 {
                let a = spin + Double(k) * 2 * .pi / 3
                spokes.move(to: c); spokes.addLine(to: CGPoint(x: c.x + cos(a) * 7, y: c.y + sin(a) * 7))
            }
            ctx.stroke(spokes, with: .color(Theme.inkSoft), lineWidth: 1.5)
        }
        // The nail, glinting in the back tyre.
        let glint = 0.5 + 0.5 * sin(t * 4)
        ctx.fill(Path(ellipseIn: CGRect(x: 244, y: 230, width: 4, height: 4)), with: .color(Color(hex: 0xD8D8D8).opacity(0.6 + 0.4 * glint)))
        var body = Path()
        body.move(to: CGPoint(x: 214, y: 214))
        body.addQuadCurve(to: CGPoint(x: 268, y: 196), control: CGPoint(x: 226, y: 192))
        body.addLine(to: CGPoint(x: 300, y: 204))
        body.addQuadCurve(to: CGPoint(x: 322, y: 160), control: CGPoint(x: 318, y: 190))
        body.addLine(to: CGPoint(x: 334, y: 162))
        body.addQuadCurve(to: CGPoint(x: 344, y: 214), control: CGPoint(x: 350, y: 196))
        body.addLine(to: CGPoint(x: 252, y: 220))
        body.addQuadCurve(to: CGPoint(x: 214, y: 214), control: CGPoint(x: 226, y: 222))
        body.closeSubpath()
        ctx.fill(body, with: .color(Theme.sawah))
        ctx.fill(Path(roundedRect: CGRect(x: 226, y: 184, width: 50, height: 10), cornerRadius: 5), with: .color(Theme.ink))
        // Handlebars and headlight
        var bars = Path()
        bars.move(to: CGPoint(x: 326, y: 160)); bars.addLine(to: CGPoint(x: 318, y: 146))
        bars.move(to: CGPoint(x: 310, y: 146)); bars.addLine(to: CGPoint(x: 330, y: 146))
        ctx.stroke(bars, with: .color(Theme.ink), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        ctx.fill(Path(ellipseIn: CGRect(x: 334, y: 166, width: 9, height: 7)), with: .color(Color(hex: 0xFFE7A6)))
        ctx.fill(Path(ellipseIn: CGRect(x: 236, y: 200, width: 18, height: 6)), with: .color(.white.opacity(0.3)))
    }

    private func spanner(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        var c = ctx
        c.translateBy(x: p.x, y: p.y)
        c.rotate(by: .radians(0.6 + sin(t * (busy ? 7 : 4)) * 0.3))
        c.fill(Path(roundedRect: CGRect(x: -2, y: 0, width: 4, height: 18), cornerRadius: 2), with: .color(Color(hex: 0xB9B3A8)))
        var jaw = Path()
        jaw.addArc(center: CGPoint(x: 0, y: 20), radius: 4.5, startAngle: .degrees(-60), endAngle: .degrees(240), clockwise: false)
        c.stroke(jaw, with: .color(Color(hex: 0xB9B3A8)), lineWidth: 3)
    }
}
