import SwiftUI

/// A café counter: a chalkboard menu, pendant lamps swaying, an espresso machine puffing steam,
/// a row of cups, a jar of palm sugar, a little cactus, and Mas Dimas holding out an iced coffee.
struct KafeDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let wall = Color(hex: 0xF1E3CC)
    private let wood = Color(hex: 0x8A5E3F)
    private let floor = Color(hex: 0xC9A47A)
    private let chalk = Color(hex: 0x2F3A34)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        ctx.fill(Path(CGRect(x: f.left, y: f.top, width: f.width, height: 214 - f.top)), with: .color(wall))
        // Brick strip behind the machine
        var bricks = Path()
        for (row, y) in stride(from: 96.0, through: 176, by: 10).enumerated() {
            for x in stride(from: 286.0 + Double(row % 2) * 10, through: f.right, by: 20) {
                bricks.addRoundedRect(in: CGRect(x: x, y: y, width: 18, height: 8), cornerSize: CGSize(width: 1.5, height: 1.5))
            }
        }
        ctx.fill(bricks, with: .color(Theme.sambal.opacity(0.18)))
        ctx.fill(Path(CGRect(x: f.left, y: 206, width: f.width, height: max(60, f.bottomY - 196))), with: .color(floor))

        lamps(&ctx, t: t)
        menu(&ctx, t: t)
        shelf(&ctx)

        let cup = CGPoint(x: 240, y: 166 + sin(t * 2) * 1.5)
        Figure(skin: Color(hex: 0xC08A5E), hair: .short, outfit: Color(hex: 0x3B3A36), trim: Theme.kunyit, collar: .crew)
            .draw(&ctx, head: CGPoint(x: 198, y: 116), t: t, speaking: speaking, expression: expression,
                  pace: busy ? 1.6 : 1,
                  gesture: .holding(cup) { ctx, p in icedCoffee(&ctx, at: p, t: t) })
        // Apron straps over the shirt
        var straps = Path()
        straps.move(to: CGPoint(x: 186, y: 139)); straps.addLine(to: CGPoint(x: 184, y: 178))
        straps.move(to: CGPoint(x: 210, y: 139)); straps.addLine(to: CGPoint(x: 212, y: 178))
        ctx.stroke(straps, with: .color(Theme.kopi.lighter(0.15)), lineWidth: 3)
        counter(&ctx, t: t)
        machine(&ctx, t: t)
    }

    private func lamps(_ ctx: inout GraphicsContext, t: Double) {
        for (i, x) in [110.0, 290].enumerated() {
            let swing = sin(t * 1.1 + Double(i) * 1.4) * 0.06
            var c = ctx
            c.translateBy(x: x, y: -10)
            c.rotate(by: .radians(swing))
            var cord = Path()
            cord.move(to: .zero); cord.addLine(to: CGPoint(x: 0, y: 40))
            c.stroke(cord, with: .color(Theme.ink.opacity(0.6)), lineWidth: 1)
            var shade = Path()
            shade.move(to: CGPoint(x: -14, y: 54)); shade.addLine(to: CGPoint(x: -5, y: 40))
            shade.addLine(to: CGPoint(x: 5, y: 40)); shade.addLine(to: CGPoint(x: 14, y: 54))
            shade.closeSubpath()
            c.fill(Path(ellipseIn: CGRect(x: -22, y: 44, width: 44, height: 26)), with: .color(Color(hex: 0xFFE7A6).opacity(0.25)))
            c.fill(shade, with: .color(Theme.sawah))
            c.fill(Path(ellipseIn: CGRect(x: -4, y: 51, width: 8, height: 6)), with: .color(Color(hex: 0xFFE7A6)))
        }
    }

    private func menu(_ ctx: inout GraphicsContext, t: Double) {
        let board = CGRect(x: 18, y: 54, width: 96, height: 76)
        ctx.fill(Path(roundedRect: board, cornerRadius: 4), with: .color(chalk))
        ctx.stroke(Path(roundedRect: board, cornerRadius: 4), with: .color(wood), lineWidth: 4)
        ctx.draw(Text("KOPI").font(.system(size: 12, weight: .heavy, design: .rounded)).foregroundColor(.white.opacity(0.9)),
                 at: CGPoint(x: board.midX, y: board.minY + 12))
        var lines = Path()
        for k in 0..<4 {
            let y = board.minY + 26 + Double(k) * 11
            lines.move(to: CGPoint(x: board.minX + 10, y: y)); lines.addLine(to: CGPoint(x: board.minX + 50 + Double(k % 2) * 8, y: y))
            lines.move(to: CGPoint(x: board.maxX - 22, y: y)); lines.addLine(to: CGPoint(x: board.maxX - 10, y: y))
        }
        ctx.stroke(lines, with: .color(.white.opacity(0.55)), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
        // A chalk heart that pulses
        let beat = 1 + 0.12 * max(0, sin(t * 3))
        var heart = ctx
        heart.translateBy(x: board.maxX - 16, y: board.minY + 12)
        heart.scaleBy(x: beat, y: beat)
        heart.draw(Text("♥").font(.system(size: 9)).foregroundColor(Theme.jambu.lighter(0.3)), at: .zero)
    }

    private func shelf(_ ctx: inout GraphicsContext) {
        ctx.fill(Path(CGRect(x: 130, y: 70, width: 140, height: 4)), with: .color(wood))
        for k in 0..<6 {
            let x = 138 + Double(k) * 22
            let r = CGRect(x: x, y: 52, width: 14, height: 18)
            ctx.fill(Path(roundedRect: r, cornerRadius: 3), with: .color(k % 2 == 0 ? Theme.card : Color(hex: 0xE9D3B0)))
            ctx.fill(Path(CGRect(x: r.minX, y: r.minY + 6, width: r.width, height: 3)), with: .color([Theme.laut, Theme.sambal, Theme.kunyit][k % 3].opacity(0.7)))
        }
    }

    private func counter(_ ctx: inout GraphicsContext, t: Double) {
        let front = CGRect(x: 96, y: 182, width: 230, height: 54)
        ctx.fill(Path(front), with: .color(wood))
        var slats = Path()
        for x in stride(from: front.minX + 14, through: front.maxX, by: 14) {
            slats.move(to: CGPoint(x: x, y: front.minY)); slats.addLine(to: CGPoint(x: x, y: front.maxY))
        }
        ctx.stroke(slats, with: .color(.black.opacity(0.12)), lineWidth: 1)
        ctx.fill(Path(roundedRect: CGRect(x: front.minX - 6, y: front.minY - 6, width: front.width + 12, height: 8), cornerRadius: 3),
                 with: .color(wood.lighter(0.12)))
        // Palm sugar jar and a cactus on the counter
        let jar = CGRect(x: 122, y: 160, width: 20, height: 22)
        ctx.fill(Path(roundedRect: jar, cornerRadius: 5), with: .color(.white.opacity(0.6)))
        ctx.fill(Path(roundedRect: CGRect(x: jar.minX + 2, y: jar.minY + 8, width: jar.width - 4, height: jar.height - 10), cornerRadius: 3),
                 with: .color(Theme.kopi.lighter(0.25)))
        ctx.fill(Path(roundedRect: CGRect(x: jar.minX - 1, y: jar.minY - 3, width: jar.width + 2, height: 5), cornerRadius: 2), with: .color(wood))
        ctx.fill(Path(roundedRect: CGRect(x: 152, y: 170, width: 16, height: 12), cornerRadius: 3), with: .color(Theme.sambal.opacity(0.75)))
        ctx.fill(Path(roundedRect: CGRect(x: 155, y: 152, width: 10, height: 20), cornerRadius: 5), with: .color(Theme.sawah))
        ctx.fill(Path(roundedRect: CGRect(x: 149, y: 158, width: 7, height: 10), cornerRadius: 3.5), with: .color(Theme.sawah))
    }

    private func machine(_ ctx: inout GraphicsContext, t: Double) {
        let body = CGRect(x: 286, y: 128, width: 74, height: 54)
        Illo.puffs(&ctx, from: CGPoint(x: body.minX + 18, y: body.minY - 2), t: t, rate: busy ? 0.7 : 0.4, rise: 50, color: .white, count: compact ? 2 : 4)
        ctx.fill(Path(roundedRect: body, cornerRadius: 8), with: .color(Color(hex: 0xB9BEC4)))
        ctx.fill(Path(roundedRect: CGRect(x: body.minX + 6, y: body.minY + 6, width: body.width - 12, height: 14), cornerRadius: 3),
                 with: .color(Color(hex: 0xD9DDE1)))
        // Pressure dial
        let dial = CGPoint(x: body.midX, y: body.minY + 13)
        ctx.fill(Path(ellipseIn: CGRect(x: dial.x - 5, y: dial.y - 5, width: 10, height: 10)), with: .color(.white))
        var needle = Path()
        let a = 0.5 + sin(t * 5) * 0.2
        needle.move(to: dial); needle.addLine(to: CGPoint(x: dial.x + sin(a) * 4, y: dial.y - cos(a) * 4))
        ctx.stroke(needle, with: .color(Theme.sambal), lineWidth: 1)
        // Group heads and a cup filling
        for dx in [18.0, 54] {
            ctx.fill(Path(roundedRect: CGRect(x: body.minX + dx - 7, y: body.minY + 26, width: 14, height: 7), cornerRadius: 2), with: .color(Theme.ink.opacity(0.7)))
        }
        let drip = (t * 1.6).truncatingRemainder(dividingBy: 1)
        ctx.fill(Path(ellipseIn: CGRect(x: body.minX + 53, y: body.minY + 34 + drip * 8, width: 2.5, height: 3.5)), with: .color(Theme.kopi))
        ctx.fill(Path(roundedRect: CGRect(x: body.minX + 47, y: body.minY + 44, width: 14, height: 10), cornerRadius: 2), with: .color(.white))
    }

    private func icedCoffee(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        let glass = CGRect(x: p.x + 2, y: p.y - 22, width: 16, height: 24)
        ctx.fill(Path(roundedRect: glass, cornerRadius: 3), with: .color(.white.opacity(0.7)))
        ctx.fill(Path(roundedRect: CGRect(x: glass.minX + 1.5, y: glass.minY + 6, width: glass.width - 3, height: glass.height - 7.5), cornerRadius: 2),
                 with: .linearGradient(Gradient(colors: [Color(hex: 0xD9B48A), Theme.kopi]),
                                       startPoint: CGPoint(x: 0, y: glass.minY + 6), endPoint: CGPoint(x: 0, y: glass.maxY)))
        for k in 0..<2 {
            let bob = sin(t * 2 + Double(k)) * 1
            ctx.fill(Path(roundedRect: CGRect(x: glass.minX + 3 + Double(k) * 6, y: glass.minY + 8 + bob, width: 5, height: 5), cornerRadius: 1),
                     with: .color(.white.opacity(0.7)))
        }
        var straw = Path()
        straw.move(to: CGPoint(x: glass.midX + 2, y: glass.minY + 10)); straw.addLine(to: CGPoint(x: glass.midX + 6, y: glass.minY - 8))
        ctx.stroke(straw, with: .color(Theme.sambal), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }
}
