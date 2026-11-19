import SwiftUI

/// A café terrace: a big window onto palms and the sea, twinkling string lights, hanging plants,
/// two steaming coffees, and Putu sketching across the table, with a volleyball under the chair.
struct NgopiDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let wall = Color(hex: 0xEAD2B0)
    private let wood = Color(hex: 0x8A5E3F)
    private let floor = Color(hex: 0xB98A5E)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        ctx.fill(Path(CGRect(x: f.left, y: f.top, width: f.width, height: 210 - f.top)), with: .color(wall))
        window(&ctx, t: t)
        ctx.fill(Path(CGRect(x: f.left, y: 200, width: f.width, height: max(70, f.bottomY - 190))), with: .color(floor))
        var planks = Path()
        for x in stride(from: f.left, through: f.right, by: 28) {
            planks.move(to: CGPoint(x: x, y: 200)); planks.addLine(to: CGPoint(x: x - 20, y: f.bottomY + 10))
        }
        ctx.stroke(planks, with: .color(.black.opacity(0.08)), lineWidth: 1)
        ctx.fill(Path(CGRect(x: f.left, y: 198, width: f.width, height: 4)), with: .color(wood.darker(0.1)))

        lights(&ctx, f, t: t)
        hangingPlant(&ctx, x: 30, t: t, phase: 0)
        hangingPlant(&ctx, x: 372, t: t, phase: 1.3)
        monstera(&ctx, at: CGPoint(x: 40, y: 230), t: t)

        // Chair back behind Putu
        ctx.fill(Path(roundedRect: CGRect(x: 196, y: 140, width: 72, height: 66), cornerRadius: 10), with: .color(Color(hex: 0xC9A15A)))
        var weave = Path()
        for x in stride(from: 202.0, through: 262, by: 7) {
            weave.move(to: CGPoint(x: x, y: 146)); weave.addLine(to: CGPoint(x: x, y: 200))
        }
        ctx.stroke(weave, with: .color(wood.opacity(0.35)), lineWidth: 1.5)

        let pencil = CGPoint(x: 206 + sin(t * 3) * 9, y: 176 + cos(t * 6) * 2)
        Figure(skin: Color(hex: 0xBC8455), hair: .short, outfit: Color(hex: 0x3E7C6B), trim: Theme.kunyit, collar: .crew)
            .draw(&ctx, head: CGPoint(x: 232, y: 124), t: t, speaking: speaking, expression: expression,
                  pace: busy ? 0.7 : 1,
                  gesture: .holding(pencil) { ctx, p in
                      var stick = Path()
                      stick.move(to: CGPoint(x: p.x - 2, y: p.y + 3))
                      stick.addLine(to: CGPoint(x: p.x + 8, y: p.y - 12))
                      ctx.stroke(stick, with: .color(Theme.kunyit), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                  })
        table(&ctx, t: t)
        volleyball(&ctx, t: t)
    }

    private func window(_ ctx: inout GraphicsContext, t: Double) {
        let frame = CGRect(x: 66, y: 30, width: 268, height: 116)
        var c = ctx
        c.clip(to: Path(roundedRect: frame, cornerRadius: 6))
        c.fill(Path(frame), with: .linearGradient(Gradient(colors: [Color(hex: 0xF7D9A8), Color(hex: 0xF6EBD7)]),
                                                  startPoint: CGPoint(x: 0, y: frame.minY), endPoint: CGPoint(x: 0, y: frame.maxY)))
        let sun = CGPoint(x: 140, y: 70)
        c.fill(Path(ellipseIn: CGRect(x: sun.x - 14, y: sun.y - 14, width: 28, height: 28)), with: .color(Theme.kunyit))
        // Sea with a shimmer
        c.fill(Path(CGRect(x: frame.minX, y: 104, width: frame.width, height: 42)), with: .color(Theme.laut.opacity(0.75)))
        var shimmer = Path()
        for k in 0..<6 {
            let x = frame.minX + 20 + Double(k) * 44 + sin(t * 1.4 + Double(k)) * 6
            shimmer.move(to: CGPoint(x: x, y: 112 + Double(k % 3) * 8))
            shimmer.addLine(to: CGPoint(x: x + 14, y: 112 + Double(k % 3) * 8))
        }
        c.stroke(shimmer, with: .color(.white.opacity(0.6)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
        Illo.palm(&c, t: t, base: CGPoint(x: 300, y: 150), height: 100, phase: 2)
        Illo.palm(&c, t: t, base: CGPoint(x: 90, y: 150), height: 80, phase: 0.6)
        // Frame and mullions
        ctx.stroke(Path(roundedRect: frame, cornerRadius: 6), with: .color(wood), lineWidth: 6)
        var mullions = Path()
        mullions.move(to: CGPoint(x: frame.midX, y: frame.minY)); mullions.addLine(to: CGPoint(x: frame.midX, y: frame.maxY))
        mullions.move(to: CGPoint(x: frame.minX, y: 72)); mullions.addLine(to: CGPoint(x: frame.maxX, y: 72))
        ctx.stroke(mullions, with: .color(wood), lineWidth: 3)
        ctx.fill(Path(roundedRect: CGRect(x: frame.minX - 8, y: frame.maxY, width: frame.width + 16, height: 6), cornerRadius: 2), with: .color(wood.darker(0.1)))
    }

    private func lights(_ ctx: inout GraphicsContext, _ f: IlloFrame, t: Double) {
        let a = CGPoint(x: f.left, y: 12), b = CGPoint(x: f.right, y: 18)
        let c = CGPoint(x: 200, y: 38)
        var wire = Path()
        wire.move(to: a); wire.addQuadCurve(to: b, control: c)
        ctx.stroke(wire, with: .color(Theme.ink.opacity(0.5)), lineWidth: 1)
        let n = 13
        for i in 1..<n {
            let p = Illo.quad(a, c, b, Double(i) / Double(n))
            let glow = 0.55 + 0.45 * sin(t * 2.2 + Double(i) * 1.7)
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - 7, y: p.y - 2, width: 14, height: 14)), with: .color(Theme.kunyit.opacity(0.25 * glow)))
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - 3, y: p.y + 2, width: 6, height: 7)), with: .color(Color(hex: 0xFFE7A6).opacity(0.6 + 0.4 * glow)))
        }
    }

    private func hangingPlant(_ ctx: inout GraphicsContext, x: Double, t: Double, phase: Double) {
        let swing = sin(t * 1.2 + phase) * 0.06
        var c = ctx
        c.translateBy(x: x, y: 0)
        c.rotate(by: .radians(swing))
        var cords = Path()
        cords.move(to: CGPoint(x: 0, y: 0)); cords.addLine(to: CGPoint(x: -9, y: 52))
        cords.move(to: CGPoint(x: 0, y: 0)); cords.addLine(to: CGPoint(x: 9, y: 52))
        c.stroke(cords, with: .color(wood.opacity(0.6)), lineWidth: 1)
        c.fill(Path(roundedRect: CGRect(x: -11, y: 50, width: 22, height: 14), cornerRadius: 4), with: .color(Color(hex: 0xB86A45)))
        for k in 0..<4 {
            let dx = Double(k) * 6 - 9
            var vine = Path()
            vine.move(to: CGPoint(x: dx, y: 58))
            vine.addQuadCurve(to: CGPoint(x: dx + sin(t + Double(k)) * 3, y: 84 + Double(k % 2) * 12),
                              control: CGPoint(x: dx - 6, y: 70))
            c.stroke(vine, with: .color(Theme.sawah), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            c.fill(Path(ellipseIn: CGRect(x: dx - 3, y: 74 + Double(k % 2) * 10, width: 7, height: 5)), with: .color(Theme.sawah.lighter(0.15)))
        }
    }

    private func monstera(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        for k in 0..<5 {
            let a = -Double.pi / 2 + (Double(k) - 2) * 0.42 + sin(t * 0.9 + Double(k)) * 0.04
            let tip = CGPoint(x: p.x + cos(a) * 46, y: p.y - 8 + sin(a) * 46)
            var stem = Path()
            stem.move(to: CGPoint(x: p.x, y: p.y - 6)); stem.addLine(to: tip)
            ctx.stroke(stem, with: .color(Theme.sawah.darker(0.1)), lineWidth: 2)
            var c = ctx
            c.translateBy(x: tip.x, y: tip.y)
            c.rotate(by: .radians(a + .pi / 2))
            c.fill(Path(ellipseIn: CGRect(x: -11, y: -9, width: 22, height: 18)), with: .color(Theme.sawah))
            var slits = Path()
            slits.move(to: CGPoint(x: -9, y: -2)); slits.addLine(to: CGPoint(x: -3, y: 0))
            slits.move(to: CGPoint(x: 9, y: -2)); slits.addLine(to: CGPoint(x: 3, y: 0))
            c.stroke(slits, with: .color(wall), lineWidth: 1.5)
        }
        ctx.fill(Path(roundedRect: CGRect(x: p.x - 14, y: p.y - 8, width: 28, height: 26), cornerRadius: 5), with: .color(Theme.card))
        ctx.fill(Path(CGRect(x: p.x - 14, y: p.y + 2, width: 28, height: 4)), with: .color(Theme.sambal.opacity(0.6)))
    }

    private func table(_ ctx: inout GraphicsContext, t: Double) {
        ctx.fill(Path(CGRect(x: 194, y: 196, width: 12, height: 44)), with: .color(wood.darker(0.15)))
        ctx.fill(Path(ellipseIn: CGRect(x: 170, y: 234, width: 60, height: 10)), with: .color(wood.darker(0.2)))
        ctx.fill(Path(ellipseIn: CGRect(x: 86, y: 178, width: 228, height: 30)), with: .color(wood.darker(0.15)))
        ctx.fill(Path(ellipseIn: CGRect(x: 86, y: 174, width: 228, height: 28)), with: .color(wood))
        // Sketchbook with a growing doodle
        let book = CGRect(x: 178, y: 178, width: 50, height: 16)
        ctx.fill(Path(roundedRect: book, cornerRadius: 2), with: .color(Theme.card))
        ctx.fill(Path(CGRect(x: book.midX - 0.5, y: book.minY, width: 1, height: book.height)), with: .color(.black.opacity(0.15)))
        var doodle = Path()
        doodle.move(to: CGPoint(x: book.minX + 4, y: book.midY + 3))
        for k in 1..<8 {
            doodle.addLine(to: CGPoint(x: book.minX + 4 + Double(k) * 2.6, y: book.midY + sin(Double(k) + t) * 3))
        }
        ctx.stroke(doodle, with: .color(Theme.ink.opacity(0.6)), lineWidth: 0.8)
        cup(&ctx, at: CGPoint(x: 268, y: 182), t: t, phase: 0)
        cup(&ctx, at: CGPoint(x: 130, y: 188), t: t, phase: 0.5)
    }

    private func cup(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double, phase: Double) {
        Illo.puffs(&ctx, from: CGPoint(x: p.x, y: p.y - 10), t: t + phase * 2, rate: 0.35, rise: 32, color: .white, count: 3)
        ctx.fill(Path(ellipseIn: CGRect(x: p.x - 13, y: p.y + 2, width: 26, height: 7)), with: .color(Theme.card.darker(0.05)))
        ctx.fill(Path(roundedRect: CGRect(x: p.x - 8, y: p.y - 10, width: 16, height: 14), cornerRadius: 4), with: .color(Theme.card))
        ctx.fill(Path(ellipseIn: CGRect(x: p.x - 7, y: p.y - 12, width: 14, height: 4)), with: .color(Theme.kopi))
        ctx.stroke(Path(ellipseIn: CGRect(x: p.x + 6, y: p.y - 7, width: 6, height: 7)), with: .color(Theme.card), lineWidth: 2)
    }

    private func volleyball(_ ctx: inout GraphicsContext, t: Double) {
        let c = CGPoint(x: 302, y: 226)
        let rock = sin(t * 0.8) * 0.15
        var b = ctx
        b.translateBy(x: c.x + rock * 6, y: c.y)
        b.rotate(by: .radians(rock))
        let ball = Path(ellipseIn: CGRect(x: -14, y: -14, width: 28, height: 28))
        b.fill(ball, with: .color(.white))
        var bc = b
        bc.clip(to: ball)
        var seam = Path()
        seam.addArc(center: CGPoint(x: -14, y: 0), radius: 18, startAngle: .degrees(-50), endAngle: .degrees(50), clockwise: false)
        bc.stroke(seam, with: .color(Theme.indigo), lineWidth: 5)
        var seam2 = Path()
        seam2.addArc(center: CGPoint(x: 14, y: -8), radius: 16, startAngle: .degrees(120), endAngle: .degrees(220), clockwise: false)
        bc.stroke(seam2, with: .color(Theme.kunyit), lineWidth: 5)
        b.stroke(ball, with: .color(.black.opacity(0.15)), lineWidth: 1)
    }
}
