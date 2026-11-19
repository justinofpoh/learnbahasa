import SwiftUI

/// A two-storey kos house: tiled roof, numbered doors, a balcony, a pulsing wifi sign, a spinning
/// AC fan, laundry on the line, a frangipani tree dropping flowers, and Bu Sari with the keys.
struct KosDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let wallLow = Color(hex: 0xF3E6CF)
    private let wallHigh = Color(hex: 0xEEDDBF)
    private let tile = Color(hex: 0xC4612F)
    private let door = Color(hex: 0x3E7C6B)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        Illo.sky(&ctx, f, top: Color(hex: 0xF2DDB2), bottom: Color(hex: 0xF6EBD7))
        Illo.sun(&ctx, t: t, center: CGPoint(x: 352, y: 36))
        Illo.clouds(&ctx, f, t: t, count: compact ? 1 : 2)
        Illo.hills(&ctx, f, base: 168)
        Illo.ground(&ctx, f, y: 230, color: Color(hex: 0xE4D5B8), pebbles: Theme.kopi.opacity(0.18))
        path(&ctx)
        building(&ctx, t: t)
        laundry(&ctx, t: t)
        frangipani(&ctx, t: t)
        plants(&ctx, t: t)
        // Scaled down from her feet so she stands at door height.
        var person = ctx
        person.translateBy(x: 213, y: 232)
        person.scaleBy(x: 0.74, y: 0.74)
        person.translateBy(x: -213, y: -232)
        Figure(skin: Color(hex: 0xC9905F), hair: .hijab(Theme.jambu), outfit: Theme.sawah, trim: Theme.kunyit,
               lower: .sarong(Theme.indigo))
            .draw(&person, head: CGPoint(x: 213, y: 117), t: t, speaking: speaking, expression: expression,
                  pace: busy ? 1.6 : 1,
                  gesture: .holding(CGPoint(x: 252, y: 162)) { ctx, p in keys(&ctx, at: p, t: t) })
    }

    private func path(_ ctx: inout GraphicsContext) {
        var p = Path()
        p.move(to: CGPoint(x: 186, y: 230)); p.addLine(to: CGPoint(x: 246, y: 230))
        p.addLine(to: CGPoint(x: 268, y: 262)); p.addLine(to: CGPoint(x: 164, y: 262))
        p.closeSubpath()
        ctx.fill(p, with: .color(Color(hex: 0xD3C2A2)))
    }

    private func building(_ ctx: inout GraphicsContext, t: Double) {
        // Walls
        ctx.fill(Path(CGRect(x: 96, y: 150, width: 236, height: 82)), with: .color(wallLow))
        ctx.fill(Path(CGRect(x: 102, y: 86, width: 224, height: 64)), with: .color(wallHigh))
        // Roof
        var roof = Path()
        roof.move(to: CGPoint(x: 84, y: 88)); roof.addLine(to: CGPoint(x: 126, y: 50))
        roof.addLine(to: CGPoint(x: 302, y: 50)); roof.addLine(to: CGPoint(x: 344, y: 88))
        roof.closeSubpath()
        ctx.fill(roof, with: .linearGradient(Gradient(colors: [tile.lighter(0.08), tile.darker(0.1)]),
                                             startPoint: CGPoint(x: 0, y: 50), endPoint: CGPoint(x: 0, y: 88)))
        var rows = Path()
        for y in stride(from: 58.0, through: 84, by: 8) {
            let inset = 42 * (1 - (y - 50) / 38)
            rows.move(to: CGPoint(x: 84 + inset, y: y)); rows.addLine(to: CGPoint(x: 344 - inset, y: y))
        }
        ctx.stroke(rows, with: .color(.black.opacity(0.12)), lineWidth: 1)
        ctx.fill(Path(roundedRect: CGRect(x: 122, y: 46, width: 184, height: 6), cornerRadius: 3), with: .color(tile.darker(0.25)))

        // Upper doors 4-6, balcony
        for (i, x) in [118.0, 196, 274].enumerated() {
            doorway(&ctx, x: x, y: 100, h: 46, number: "\(i + 4)", open: false)
        }
        ctx.fill(Path(CGRect(x: 96, y: 146, width: 236, height: 6)), with: .color(Color(hex: 0xD9C7A6)))
        var rail = Path()
        rail.move(to: CGPoint(x: 100, y: 128)); rail.addLine(to: CGPoint(x: 328, y: 128))
        for x in stride(from: 104.0, through: 326, by: 9) {
            rail.move(to: CGPoint(x: x, y: 128)); rail.addLine(to: CGPoint(x: x, y: 146))
        }
        ctx.stroke(rail, with: .color(Theme.kopi.opacity(0.75)), lineWidth: 1.6)

        // Ground doors 1-3; door 2 is open behind Bu Sari.
        for (i, x) in [118.0, 196, 274].enumerated() {
            doorway(&ctx, x: x, y: 176, h: 54, number: "\(i + 1)", open: i == 1)
        }

        // Wifi sign with pulsing arcs
        let w = CGPoint(x: 168, y: 112)
        ctx.fill(Path(roundedRect: CGRect(x: w.x - 7, y: w.y, width: 14, height: 7), cornerRadius: 2), with: .color(Theme.ink.opacity(0.8)))
        ctx.fill(Path(ellipseIn: CGRect(x: w.x + 3, y: w.y + 2, width: 2, height: 2)), with: .color(Color(hex: 0x2ECC71)))
        for k in 0..<3 {
            let pulse = (t * 1.2 - Double(k) * 0.25).truncatingRemainder(dividingBy: 1)
            let r = 6 + Double(k) * 5
            var arc = Path()
            arc.addArc(center: w, radius: r, startAngle: .degrees(220), endAngle: .degrees(320), clockwise: false)
            ctx.stroke(arc, with: .color(Theme.laut.opacity(0.25 + 0.6 * max(0, 1 - abs(pulse - 0.5) * 2))),
                       style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }

        // AC outdoor unit with spinning fan
        let ac = CGRect(x: 288, y: 156, width: 32, height: 20)
        ctx.fill(Path(roundedRect: ac, cornerRadius: 3), with: .color(Color(hex: 0xE3E3E0)))
        ctx.stroke(Path(roundedRect: ac, cornerRadius: 3), with: .color(.black.opacity(0.15)), lineWidth: 1)
        let fc = CGPoint(x: ac.minX + 11, y: ac.midY)
        ctx.fill(Path(ellipseIn: CGRect(x: fc.x - 8, y: fc.y - 8, width: 16, height: 16)), with: .color(Color(hex: 0x9A9A98)))
        var blades = Path()
        for k in 0..<3 {
            let a = t * 9 + Double(k) * 2.094
            blades.move(to: fc)
            blades.addLine(to: CGPoint(x: fc.x + cos(a) * 7, y: fc.y + sin(a) * 7))
        }
        ctx.stroke(blades, with: .color(.white), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        var grille = Path()
        for y in stride(from: ac.minY + 4, through: ac.maxY - 4, by: 4) {
            grille.move(to: CGPoint(x: ac.minX + 22, y: y)); grille.addLine(to: CGPoint(x: ac.maxX - 3, y: y))
        }
        ctx.stroke(grille, with: .color(.black.opacity(0.2)), lineWidth: 1)
    }

    private func doorway(_ ctx: inout GraphicsContext, x: Double, y: Double, h: Double, number: String, open: Bool) {
        let rect = CGRect(x: x, y: y, width: 34, height: h)
        if open {
            ctx.fill(Path(rect), with: .color(Color(hex: 0x4A3A2E)))
            var leaf = Path()
            leaf.move(to: CGPoint(x: x, y: y)); leaf.addLine(to: CGPoint(x: x - 10, y: y + 4))
            leaf.addLine(to: CGPoint(x: x - 10, y: y + h - 2)); leaf.addLine(to: CGPoint(x: x, y: y + h))
            leaf.closeSubpath()
            ctx.fill(leaf, with: .color(door))
        } else {
            ctx.fill(Path(rect), with: .color(door))
            ctx.stroke(Path(rect.insetBy(dx: 4, dy: 4)), with: .color(.white.opacity(0.18)), lineWidth: 1)
            ctx.fill(Path(ellipseIn: CGRect(x: x + 27, y: y + h / 2, width: 3, height: 3)), with: .color(Theme.kunyit))
        }
        ctx.fill(Path(roundedRect: CGRect(x: x + 11, y: y - 11, width: 12, height: 9), cornerRadius: 2), with: .color(Theme.card))
        ctx.draw(Text(number).font(.system(size: 7, weight: .bold, design: .rounded)).foregroundColor(Theme.ink),
                 at: CGPoint(x: x + 17, y: y - 6.5))
        // Window beside the door
        let win = CGRect(x: x + 40, y: y + 6, width: 20, height: min(22, h - 16))
        ctx.fill(Path(roundedRect: win, cornerRadius: 2), with: .color(Theme.laut.opacity(0.3)))
        ctx.fill(Path(CGRect(x: win.minX, y: win.minY, width: 7, height: win.height)), with: .color(Theme.jambu.opacity(0.35)))
    }

    private func laundry(_ ctx: inout GraphicsContext, t: Double) {
        let a = CGPoint(x: 332, y: 108), b = CGPoint(x: 392, y: 96)
        ctx.fill(Path(CGRect(x: 390, y: 94, width: 4, height: 138)), with: .color(Color(hex: 0x8A5E3F)))
        let c = CGPoint(x: 362, y: 114)
        var line = Path()
        line.move(to: a); line.addQuadCurve(to: b, control: c)
        ctx.stroke(line, with: .color(Theme.ink.opacity(0.4)), lineWidth: 1)
        let clothes: [(Double, Color, Double)] = [(0.2, Theme.kunyit, 18), (0.5, Theme.laut, 22), (0.8, Theme.sambal, 16)]
        for (i, item) in clothes.enumerated() {
            let p = Illo.quad(a, c, b, item.0)
            let sway = sin(t * 2 + Double(i)) * 2.5
            var shirt = Path()
            shirt.move(to: CGPoint(x: p.x - 8, y: p.y))
            shirt.addLine(to: CGPoint(x: p.x + 8, y: p.y))
            shirt.addLine(to: CGPoint(x: p.x + 7 + sway, y: p.y + item.2))
            shirt.addLine(to: CGPoint(x: p.x - 7 + sway, y: p.y + item.2))
            shirt.closeSubpath()
            ctx.fill(shirt, with: .color(item.1))
            ctx.fill(Path(CGRect(x: p.x - 1, y: p.y - 2, width: 2, height: 4)), with: .color(Theme.ink.opacity(0.6)))
        }
    }

    private func frangipani(_ ctx: inout GraphicsContext, t: Double) {
        let bark = Color(hex: 0x8C7B6B)
        let base = CGPoint(x: 52, y: 232)
        let tips = [CGPoint(x: 22, y: 96), CGPoint(x: 58, y: 78), CGPoint(x: 92, y: 104)]
        var trunk = Path()
        trunk.move(to: base); trunk.addQuadCurve(to: CGPoint(x: 54, y: 150), control: CGPoint(x: 46, y: 190))
        for tip in tips {
            trunk.move(to: CGPoint(x: 54, y: 150))
            trunk.addQuadCurve(to: tip, control: CGPoint(x: (54 + tip.x) / 2, y: 130))
        }
        ctx.stroke(trunk, with: .color(bark), style: StrokeStyle(lineWidth: 6, lineCap: .round))
        for (i, tip) in tips.enumerated() {
            let sway = sin(t * 1.1 + Double(i)) * 2
            for k in 0..<5 {
                let a = Double(k) / 5 * 2 * .pi + Double(i)
                var leaf = Path()
                leaf.addEllipse(in: CGRect(x: -5, y: -15, width: 10, height: 22))
                var c = ctx
                c.translateBy(x: tip.x + sway, y: tip.y)
                c.rotate(by: .radians(a))
                c.fill(leaf, with: .color(Theme.sawah.opacity(0.9)))
            }
            flower(&ctx, at: CGPoint(x: tip.x + sway - 3, y: tip.y - 4), size: 1)
            flower(&ctx, at: CGPoint(x: tip.x + sway + 5, y: tip.y + 3), size: 0.85)
        }
        // Falling blossoms
        if !compact {
            for k in 0..<3 {
                let p = (t * 0.12 + Double(k) / 3).truncatingRemainder(dividingBy: 1)
                let x = 30 + Double(k) * 30 + sin(p * 9 + Double(k)) * 10
                let y = 100 + p * 130
                flower(&ctx, at: CGPoint(x: x, y: y), size: 0.7, spin: p * 6)
            }
        }
    }

    private func flower(_ ctx: inout GraphicsContext, at p: CGPoint, size: Double, spin: Double = 0) {
        var c = ctx
        c.translateBy(x: p.x, y: p.y)
        c.rotate(by: .radians(spin))
        c.scaleBy(x: size, y: size)
        for k in 0..<5 {
            var petal = Path()
            petal.addEllipse(in: CGRect(x: -2.5, y: -8, width: 5, height: 8))
            var pc = c
            pc.rotate(by: .radians(Double(k) / 5 * 2 * .pi))
            pc.fill(petal, with: .color(.white))
        }
        c.fill(Path(ellipseIn: CGRect(x: -2.5, y: -2.5, width: 5, height: 5)), with: .color(Theme.kunyit))
    }

    private func plants(_ ctx: inout GraphicsContext, t: Double) {
        for (i, x) in [104.0, 166, 318].enumerated() {
            ctx.fill(Path(roundedRect: CGRect(x: x - 8, y: 218, width: 16, height: 13), cornerRadius: 3), with: .color(Color(hex: 0xB86A45)))
            for k in 0..<4 {
                let a = -Double.pi / 2 + (Double(k) - 1.5) * 0.45 + sin(t * 1.3 + Double(i + k)) * 0.05
                var leaf = Path()
                leaf.move(to: CGPoint(x: x, y: 218))
                leaf.addQuadCurve(to: CGPoint(x: x + cos(a) * 16, y: 218 + sin(a) * 16),
                                  control: CGPoint(x: x + cos(a) * 6 - 4, y: 212))
                ctx.stroke(leaf, with: .color(Theme.sawah), style: StrokeStyle(lineWidth: 4, lineCap: .round))
            }
        }
    }

    private func keys(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        let swing = sin(t * 3.2) * 0.35
        var c = ctx
        c.translateBy(x: p.x, y: p.y + 4)
        c.rotate(by: .radians(swing))
        c.stroke(Path(ellipseIn: CGRect(x: -4, y: 0, width: 8, height: 8)), with: .color(Theme.kunyit), lineWidth: 1.6)
        for (k, a) in [-0.35, 0.3].enumerated() {
            var kc = c
            kc.translateBy(x: 0, y: 8)
            kc.rotate(by: .radians(a))
            kc.fill(Path(roundedRect: CGRect(x: -1.5, y: 0, width: 3, height: 11), cornerRadius: 1), with: .color(k == 0 ? Theme.kunyit : Color(hex: 0xB9B3A8)))
            kc.fill(Path(CGRect(x: 1.5, y: 7, width: 3, height: 2)), with: .color(k == 0 ? Theme.kunyit : Color(hex: 0xB9B3A8)))
        }
    }
}
