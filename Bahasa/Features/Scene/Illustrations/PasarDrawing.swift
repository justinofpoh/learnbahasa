import SwiftUI

/// A sarong stall at the pasar: bunting overhead, a blue tarp roof on bamboo poles, rows of
/// fluttering sarongs with a swinging price tag on the blue one, folded stacks on the table,
/// a fruit basket, pigeons, and Bu Ketut behind it all.
struct PasarDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let bamboo = Color(hex: 0xC9A15A)
    private let wood = Color(hex: 0x8A5E3F)
    private let tarp = Color(hex: 0x2F6E8C)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        Illo.sky(&ctx, f, top: Color(hex: 0xF8DDB0), bottom: Color(hex: 0xF6EBD7))
        Illo.sun(&ctx, t: t, center: CGPoint(x: 52, y: 40))
        Illo.clouds(&ctx, f, t: t, count: compact ? 1 : 2)
        distantStalls(&ctx, f, t: t)
        Illo.bunting(&ctx, from: CGPoint(x: f.left, y: 16), to: CGPoint(x: f.right, y: 22), sag: 16, t: t,
                     colors: [Theme.sambal, Theme.kunyit, Theme.laut, Theme.jambu, Theme.sawah])
        Illo.ground(&ctx, f, color: Color(hex: 0xE8D6B5), pebbles: wood.opacity(0.2))

        poles(&ctx)
        roof(&ctx, t: t)
        sarongs(&ctx, t: t)
        Figure(hair: .bun(flower: Theme.kunyit), outfit: Theme.jambu, trim: Theme.kunyit)
            .draw(&ctx, head: CGPoint(x: 200, y: 128), t: t, speaking: speaking, expression: expression,
                  pace: busy ? 1.6 : 1)
        table(&ctx)
        priceTag(&ctx, t: t)
        fruitBasket(&ctx, at: CGPoint(x: 352, y: 220))
        if !compact {
            Illo.bird(&ctx, at: CGPoint(x: 44, y: 238), t: t)
            Illo.bird(&ctx, at: CGPoint(x: 74, y: 242), t: t, phase: 1.7)
        }
    }

    private func distantStalls(_ ctx: inout GraphicsContext, _ f: IlloFrame, t: Double) {
        let colors = [Theme.sambal, Theme.kunyit, Theme.laut, Theme.sawah]
        var i = 0
        for x in stride(from: f.left - 20, through: f.right, by: 58) {
            let color = colors[i % colors.count].opacity(0.32)
            var umbrella = Path()
            umbrella.addArc(center: CGPoint(x: x + 24, y: 182), radius: 26, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            umbrella.closeSubpath()
            ctx.fill(umbrella, with: .color(color))
            ctx.fill(Path(CGRect(x: x + 23, y: 182, width: 2, height: 46)), with: .color(wood.opacity(0.3)))
            ctx.fill(Path(CGRect(x: x + 4, y: 206, width: 40, height: 22)), with: .color(colors[(i + 1) % colors.count].opacity(0.18)))
            i += 1
        }
    }

    private func poles(_ ctx: inout GraphicsContext) {
        for x in [62.0, 332] {
            ctx.fill(Path(roundedRect: CGRect(x: x, y: 50, width: 7, height: 182), cornerRadius: 3), with: .color(bamboo))
            var nodes = Path()
            for y in stride(from: 70.0, through: 220, by: 30) {
                nodes.move(to: CGPoint(x: x, y: y)); nodes.addLine(to: CGPoint(x: x + 7, y: y))
            }
            ctx.stroke(nodes, with: .color(wood.opacity(0.5)), lineWidth: 1.2)
        }
        var rail = Path()
        rail.move(to: CGPoint(x: 62, y: 82)); rail.addLine(to: CGPoint(x: 339, y: 82))
        ctx.stroke(rail, with: .color(wood), style: StrokeStyle(lineWidth: 3, lineCap: .round))
    }

    private func roof(_ ctx: inout GraphicsContext, t: Double) {
        var p = Path()
        p.move(to: CGPoint(x: 44, y: 54))
        p.addQuadCurve(to: CGPoint(x: 356, y: 54), control: CGPoint(x: 200, y: 36))
        for x in stride(from: 356.0, through: 44, by: -12) {
            p.addLine(to: CGPoint(x: x, y: 70 + sin(x / 30 + t * 2.2) * 2 + sin((x - 44) / 312 * .pi) * 4))
        }
        p.closeSubpath()
        ctx.fill(p, with: .linearGradient(Gradient(colors: [tarp.lighter(0.1), tarp.darker(0.1)]),
                                          startPoint: CGPoint(x: 0, y: 40), endPoint: CGPoint(x: 0, y: 74)))
        var seams = Path()
        for x in stride(from: 80.0, through: 330, by: 50) {
            seams.move(to: CGPoint(x: x, y: 50)); seams.addLine(to: CGPoint(x: x, y: 72))
        }
        var c = ctx
        c.clip(to: p)
        c.stroke(seams, with: .color(.white.opacity(0.18)), lineWidth: 2)
        // Rope ties
        var ropes = Path()
        ropes.move(to: CGPoint(x: 48, y: 56)); ropes.addLine(to: CGPoint(x: 20, y: 120))
        ropes.move(to: CGPoint(x: 352, y: 56)); ropes.addLine(to: CGPoint(x: 380, y: 120))
        ctx.stroke(ropes, with: .color(wood.opacity(0.6)), lineWidth: 1)
    }

    private struct Sarong { let x: Double; let color: Color; let pattern: Int; let length: Double }

    private var sarongList: [Sarong] {
        [Sarong(x: 76, color: Theme.sambal, pattern: 0, length: 66),
         Sarong(x: 106, color: Theme.kunyit, pattern: 1, length: 60),
         Sarong(x: 136, color: Theme.sawah, pattern: 2, length: 64),
         Sarong(x: 238, color: Theme.jambu, pattern: 2, length: 62),
         Sarong(x: 268, color: Theme.laut, pattern: 0, length: 68),   // the blue one
         Sarong(x: 298, color: Theme.indigo, pattern: 1, length: 60)]
    }

    private func sarongs(_ ctx: inout GraphicsContext, t: Double) {
        for (i, s) in sarongList.enumerated() {
            let w = 26.0, top = 82.0
            let dx = sin(t * 1.7 + Double(i) * 0.9) * 3
            var cloth = Path()
            cloth.move(to: CGPoint(x: s.x, y: top))
            cloth.addLine(to: CGPoint(x: s.x + w, y: top))
            cloth.addQuadCurve(to: CGPoint(x: s.x + w + dx, y: top + s.length),
                               control: CGPoint(x: s.x + w + dx * 0.2, y: top + s.length / 2))
            cloth.addQuadCurve(to: CGPoint(x: s.x + dx, y: top + s.length),
                               control: CGPoint(x: s.x + w / 2 + dx, y: top + s.length + sin(t * 2 + Double(i)) * 2))
            cloth.addQuadCurve(to: CGPoint(x: s.x, y: top), control: CGPoint(x: s.x + dx * 0.2, y: top + s.length / 2))
            ctx.fill(cloth, with: .color(s.color))
            var c = ctx
            c.clip(to: cloth)
            switch s.pattern {
            case 0:
                for row in 0..<4 {
                    for col in 0..<2 {
                        Kawung.draw(in: c, center: CGPoint(x: s.x + 7 + Double(col) * 12 + dx * Double(row) / 4,
                                                           y: top + 10 + Double(row) * 15),
                                    size: 9, color: .white.opacity(0.55), filled: false, lineWidth: 0.9)
                    }
                }
            case 1:
                var stripes = Path()
                for y in stride(from: top + 8, through: top + s.length, by: 9) {
                    stripes.move(to: CGPoint(x: s.x - 4, y: y)); stripes.addLine(to: CGPoint(x: s.x + w + 8, y: y + 3))
                }
                c.stroke(stripes, with: .color(.white.opacity(0.45)), lineWidth: 2)
            default:
                for k in 0..<10 {
                    let px = s.x + 4 + Double(k % 3) * 9 + dx * 0.5
                    let py = top + 6 + Double(k / 3) * 16
                    c.fill(Path(ellipseIn: CGRect(x: px, y: py, width: 4, height: 4)), with: .color(.white.opacity(0.55)))
                }
            }
            // Fringe
            var fringe = Path()
            for k in 0..<6 {
                let fx = s.x + dx + 2 + Double(k) * 4.5
                fringe.move(to: CGPoint(x: fx, y: top + s.length))
                fringe.addLine(to: CGPoint(x: fx + dx * 0.3, y: top + s.length + 5))
            }
            ctx.stroke(fringe, with: .color(s.color.darker(0.15)), lineWidth: 1.2)
            // Clip on the rail
            ctx.fill(Path(CGRect(x: s.x + w / 2 - 2, y: 79, width: 4, height: 6)), with: .color(Theme.ink.opacity(0.6)))
        }
    }

    private func priceTag(_ ctx: inout GraphicsContext, t: Double) {
        let pivot = CGPoint(x: 281, y: 84)
        let angle = sin(t * 1.5) * 0.18
        var c = ctx
        c.translateBy(x: pivot.x, y: pivot.y)
        c.rotate(by: .radians(angle))
        var string = Path()
        string.move(to: .zero); string.addLine(to: CGPoint(x: 0, y: 30))
        c.stroke(string, with: .color(Theme.ink.opacity(0.5)), lineWidth: 0.8)
        let tag = Path(roundedRect: CGRect(x: -15, y: 30, width: 30, height: 15), cornerRadius: 3)
        c.fill(tag, with: .color(Theme.card))
        c.stroke(tag, with: .color(Theme.kunyit), lineWidth: 1)
        c.draw(Text("200rb").font(.system(size: 7.5, weight: .heavy, design: .rounded)).foregroundColor(Theme.sambal),
               at: CGPoint(x: 0, y: 37.5))
    }

    private func table(_ ctx: inout GraphicsContext) {
        // Draped batik cloth
        var cloth = Path()
        cloth.move(to: CGPoint(x: 92, y: 176))
        cloth.addLine(to: CGPoint(x: 308, y: 176))
        cloth.addLine(to: CGPoint(x: 312, y: 230))
        for x in stride(from: 312.0, through: 88, by: -16) {
            cloth.addQuadCurve(to: CGPoint(x: x - 16, y: 230), control: CGPoint(x: x - 8, y: 236))
        }
        cloth.closeSubpath()
        ctx.fill(cloth, with: .color(Theme.indigo))
        var c = ctx
        c.clip(to: cloth)
        for row in 0..<3 {
            for col in 0..<12 {
                Kawung.draw(in: c, center: CGPoint(x: 100 + Double(col) * 19 + Double(row % 2) * 9, y: 190 + Double(row) * 15),
                            size: 10, color: Theme.card.opacity(0.55), filled: false, lineWidth: 0.8)
            }
        }
        ctx.fill(Path(roundedRect: CGRect(x: 86, y: 170, width: 228, height: 8), cornerRadius: 2), with: .color(wood))
        // Folded stacks
        let left = [Theme.laut, Theme.kunyit, Theme.sambal, Theme.sawah, Theme.jambu]
        for (i, color) in left.enumerated() {
            let y = 165.0 - Double(i) * 6
            ctx.fill(Path(roundedRect: CGRect(x: 100 + Double(i % 2), y: y, width: 46, height: 6), cornerRadius: 2), with: .color(color))
        }
        let right = [Theme.jambu, Theme.indigo, Theme.kunyit]
        for (i, color) in right.enumerated() {
            let y = 165.0 - Double(i) * 6
            ctx.fill(Path(roundedRect: CGRect(x: 256 - Double(i % 2), y: y, width: 44, height: 6), cornerRadius: 2), with: .color(color))
        }
    }

    private func fruitBasket(_ ctx: inout GraphicsContext, at p: CGPoint) {
        let basket = Path(roundedRect: CGRect(x: p.x - 24, y: p.y - 6, width: 48, height: 18), cornerRadius: 7)
        // Fruit first, basket rim in front
        let fruit: [(Double, Double, Color)] = [(-14, -9, Color(hex: 0x5A2A4A)), (-3, -12, Color(hex: 0xC0392B)),
                                               (9, -10, Color(hex: 0x5A2A4A)), (17, -6, Color(hex: 0xC0392B)), (2, -4, Theme.kunyit)]
        for (dx, dy, color) in fruit {
            ctx.fill(Path(ellipseIn: CGRect(x: p.x + dx - 6, y: p.y + dy - 6, width: 12, height: 12)), with: .color(color))
        }
        ctx.fill(basket, with: .color(Color(hex: 0xB8864E)))
        var weave = Path()
        for x in stride(from: p.x - 20, through: p.x + 20, by: 6) {
            weave.move(to: CGPoint(x: x, y: p.y - 5)); weave.addLine(to: CGPoint(x: x + 3, y: p.y + 11))
        }
        ctx.stroke(weave, with: .color(Color(hex: 0x8A5E3F).opacity(0.5)), lineWidth: 1)
    }
}
