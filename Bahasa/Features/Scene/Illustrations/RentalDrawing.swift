import SwiftUI

/// A roadside scooter rental: a hand-written price board, a rack of colourful helmets, three
/// scooters in a row, a palm, and Pak Gede in his straw hat swinging a key.
struct RentalDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let tyre = Color(hex: 0x2B2622)
    private let wood = Color(hex: 0x8A5E3F)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        Illo.sky(&ctx, f, top: Color(hex: 0xF4D9A6), bottom: Color(hex: 0xF6EBD7))
        Illo.sun(&ctx, t: t, center: CGPoint(x: 60, y: 42))
        Illo.clouds(&ctx, f, t: t, count: compact ? 1 : 2)
        Illo.hills(&ctx, f, base: 170)
        Illo.palm(&ctx, t: t, base: CGPoint(x: 372, y: 222), height: 150, phase: 0.8)
        Illo.ground(&ctx, f, y: 210, color: Color(hex: 0xE2D3B4), pebbles: Theme.kopi.opacity(0.2))
        road(&ctx, f, t: t)
        board(&ctx, t: t)
        helmets(&ctx, t: t)

        Figure(skin: Color(hex: 0xA9764C), hair: .hat(Color(hex: 0xD9B26A)), outfit: Theme.sambal, trim: Theme.card, collar: .crew)
            .draw(&ctx, head: CGPoint(x: 214, y: 112), t: t, speaking: speaking, expression: expression,
                  pace: busy ? 1.6 : 1,
                  gesture: .holding(CGPoint(x: 254, y: 154)) { ctx, p in key(&ctx, at: p, t: t) })
        scooter(&ctx, at: CGPoint(x: 120, y: 214), color: Theme.laut, t: t)
        scooter(&ctx, at: CGPoint(x: 214, y: 220), color: Theme.card.darker(0.04), t: t)
        scooter(&ctx, at: CGPoint(x: 306, y: 214), color: Theme.jambu, t: t)
    }

    private func road(_ ctx: inout GraphicsContext, _ f: IlloFrame, t: Double) {
        ctx.fill(Path(CGRect(x: f.left, y: 238, width: f.width, height: max(30, f.bottomY - 230))), with: .color(Color(hex: 0x8E8A84)))
        var dashes = Path()
        let shift = (t * 30).truncatingRemainder(dividingBy: 40)
        for x in stride(from: f.left - 40 + shift, through: f.right, by: 40) {
            dashes.addRoundedRect(in: CGRect(x: x, y: 250, width: 20, height: 3), cornerSize: CGSize(width: 1.5, height: 1.5))
        }
        ctx.fill(dashes, with: .color(.white.opacity(0.7)))
    }

    private func board(_ ctx: inout GraphicsContext, t: Double) {
        let sway = sin(t * 1.4) * 0.03
        var c = ctx
        c.translateBy(x: 60, y: 96)
        c.rotate(by: .radians(sway))
        c.fill(Path(CGRect(x: -3, y: 30, width: 6, height: 90)), with: .color(wood))
        let r = CGRect(x: -44, y: -26, width: 88, height: 60)
        c.fill(Path(roundedRect: r, cornerRadius: 5), with: .color(Theme.card))
        c.stroke(Path(roundedRect: r, cornerRadius: 5), with: .color(Theme.laut), lineWidth: 2.5)
        c.draw(Text("SEWA MOTOR").font(.system(size: 10.5, weight: .black, design: .rounded)).foregroundColor(Theme.laut),
               at: CGPoint(x: 0, y: -14))
        c.draw(Text("70rb / hari").font(.system(size: 10, weight: .bold, design: .rounded)).foregroundColor(Theme.sambal),
               at: CGPoint(x: 0, y: 2))
        c.draw(Text("400rb / minggu").font(.system(size: 9, weight: .bold, design: .rounded)).foregroundColor(Theme.ink.opacity(0.75)),
               at: CGPoint(x: 0, y: 17))
    }

    private func helmets(_ ctx: inout GraphicsContext, t: Double) {
        let rack = CGRect(x: 268, y: 100, width: 70, height: 6)
        ctx.fill(Path(CGRect(x: rack.minX + 4, y: rack.maxY, width: 5, height: 100)), with: .color(wood))
        ctx.fill(Path(CGRect(x: rack.maxX - 9, y: rack.maxY, width: 5, height: 100)), with: .color(wood))
        ctx.fill(Path(roundedRect: rack, cornerRadius: 2), with: .color(wood.lighter(0.1)))
        for (k, color) in [Theme.kunyit, Theme.indigo, Theme.sambal].enumerated() {
            let swing = sin(t * 1.7 + Double(k) * 1.3) * 0.08
            var c = ctx
            c.translateBy(x: rack.minX + 14 + Double(k) * 21, y: rack.maxY)
            c.rotate(by: .radians(swing))
            var strap = Path()
            strap.move(to: .zero); strap.addLine(to: CGPoint(x: 0, y: 8))
            c.stroke(strap, with: .color(Theme.ink.opacity(0.6)), lineWidth: 1)
            var shell = Path()
            shell.addArc(center: CGPoint(x: 0, y: 22), radius: 10, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            shell.closeSubpath()
            c.fill(shell, with: .color(color))
            c.fill(Path(roundedRect: CGRect(x: -11, y: 21, width: 22, height: 3), cornerRadius: 1.5), with: .color(color.darker(0.2)))
            c.fill(Path(ellipseIn: CGRect(x: -5, y: 13, width: 6, height: 3)), with: .color(.white.opacity(0.4)))
        }
    }

    private func scooter(_ ctx: inout GraphicsContext, at p: CGPoint, color: Color, t: Double) {
        // Scaled-down scooter facing right; p is the point under the seat, on the ground.
        var c = ctx
        c.translateBy(x: p.x, y: p.y)
        c.scaleBy(x: 0.72, y: 0.72)
        for x in [-42.0, 46] {
            c.fill(Path(ellipseIn: CGRect(x: x - 16, y: -32, width: 32, height: 32)), with: .color(tyre))
            c.fill(Path(ellipseIn: CGRect(x: x - 7, y: -23, width: 14, height: 14)), with: .color(Color(hex: 0xB9B3A8)))
        }
        var body = Path()
        body.move(to: CGPoint(x: -60, y: -26))
        body.addQuadCurve(to: CGPoint(x: -6, y: -46), control: CGPoint(x: -50, y: -48))
        body.addLine(to: CGPoint(x: 22, y: -36))
        body.addQuadCurve(to: CGPoint(x: 38, y: -84), control: CGPoint(x: 34, y: -60))
        body.addLine(to: CGPoint(x: 50, y: -82))
        body.addQuadCurve(to: CGPoint(x: 62, y: -30), control: CGPoint(x: 66, y: -48))
        body.addLine(to: CGPoint(x: -20, y: -24))
        body.addQuadCurve(to: CGPoint(x: -60, y: -26), control: CGPoint(x: -44, y: -20))
        body.closeSubpath()
        c.fill(body, with: .color(color))
        c.stroke(body, with: .color(.black.opacity(0.08)), lineWidth: 1)
        c.fill(Path(roundedRect: CGRect(x: -50, y: -56, width: 50, height: 11), cornerRadius: 5.5), with: .color(Theme.ink))
        var bars = Path()
        bars.move(to: CGPoint(x: 42, y: -84)); bars.addLine(to: CGPoint(x: 34, y: -100))
        bars.move(to: CGPoint(x: 24, y: -100)); bars.addLine(to: CGPoint(x: 46, y: -100))
        c.stroke(bars, with: .color(Theme.ink), style: StrokeStyle(lineWidth: 3, lineCap: .round))
        let blink = 0.6 + 0.4 * sin(t * 2 + p.x)
        c.fill(Path(ellipseIn: CGRect(x: 50, y: -78, width: 10, height: 8)), with: .color(Color(hex: 0xFFE7A6).opacity(blink)))
        c.fill(Path(ellipseIn: CGRect(x: -40, y: -42, width: 20, height: 6)), with: .color(.white.opacity(0.3)))
    }

    private func key(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        let swing = sin(t * 3.2) * 0.4
        var c = ctx
        c.translateBy(x: p.x, y: p.y + 4)
        c.rotate(by: .radians(swing))
        c.stroke(Path(ellipseIn: CGRect(x: -4, y: 0, width: 8, height: 8)), with: .color(Theme.kunyit), lineWidth: 1.6)
        c.fill(Path(roundedRect: CGRect(x: -5, y: 8, width: 10, height: 8), cornerRadius: 3), with: .color(Theme.ink))
        c.fill(Path(roundedRect: CGRect(x: -1.5, y: 15, width: 3, height: 10), cornerRadius: 1), with: .color(Color(hex: 0xB9B3A8)))
        c.fill(Path(roundedRect: CGRect(x: 4, y: 0, width: 10, height: 6), cornerRadius: 2), with: .color(Theme.sambal))
    }
}
