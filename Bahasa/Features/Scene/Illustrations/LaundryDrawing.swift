import SwiftUI

/// A tiny laundry kiloan: a striped awning and painted sign, shelves of folded stacks, a front-loader
/// tumbling clothes, soap bubbles drifting up, a hanging scale with a bulging bag, and Mbok Kadek
/// behind the counter holding out the nota.
struct LaundryDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let wall = Color(hex: 0xEDE6D8)
    private let wood = Color(hex: 0x8A5E3F)
    private let floor = Color(hex: 0xD9CBB0)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        ctx.fill(Path(CGRect(x: f.left, y: f.top, width: f.width, height: 214 - f.top)), with: .color(wall))
        ctx.fill(Path(CGRect(x: f.left, y: 206, width: f.width, height: max(60, f.bottomY - 196))), with: .color(floor))
        var tiles = Path()
        for x in stride(from: f.left, through: f.right, by: 26) {
            tiles.move(to: CGPoint(x: x, y: 206)); tiles.addLine(to: CGPoint(x: x - 14, y: f.bottomY + 10))
        }
        tiles.move(to: CGPoint(x: f.left, y: 234)); tiles.addLine(to: CGPoint(x: f.right, y: 234))
        ctx.stroke(tiles, with: .color(.black.opacity(0.06)), lineWidth: 1)

        awning(&ctx, f, t: t)
        sign(&ctx, t: t)
        shelves(&ctx)
        washer(&ctx, t: t)
        bubbles(&ctx, t: t)

        Figure(skin: Color(hex: 0xC08657), hair: .bun(flower: Theme.card), outfit: Theme.indigo, trim: Theme.kunyit)
            .draw(&ctx, head: CGPoint(x: 196, y: 118), t: t, speaking: speaking, expression: expression,
                  pace: busy ? 1.6 : 1,
                  gesture: .holding(CGPoint(x: 236, y: 170)) { ctx, p in nota(&ctx, at: p, t: t) })
        counter(&ctx, t: t)
        scale(&ctx, t: t)
    }

    private func awning(_ ctx: inout GraphicsContext, _ f: IlloFrame, t: Double) {
        let flap = sin(t * 1.8) * 1.5
        ctx.fill(Path(CGRect(x: f.left, y: f.top, width: f.width, height: 22 - f.top)), with: .color(Theme.indigo))
        var stripes = Path()
        for x in stride(from: f.left - 40, through: f.right, by: 36) {
            stripes.addRect(CGRect(x: x, y: f.top, width: 18, height: 22 - f.top))
        }
        ctx.fill(stripes, with: .color(Theme.card.opacity(0.9)))
        var scallops = Path()
        for x in stride(from: f.left, through: f.right, by: 18) {
            scallops.addEllipse(in: CGRect(x: x, y: 14 + flap * (x.truncatingRemainder(dividingBy: 36) == 0 ? 1 : -1), width: 18, height: 14))
        }
        ctx.fill(scallops, with: .color(Theme.indigo))
    }

    private func sign(_ ctx: inout GraphicsContext, t: Double) {
        let board = CGRect(x: 128, y: 38, width: 144, height: 30)
        ctx.fill(Path(roundedRect: board.offsetBy(dx: 0, dy: 3), cornerRadius: 8), with: .color(Theme.indigo.darker(0.2)))
        ctx.fill(Path(roundedRect: board, cornerRadius: 8), with: .color(Theme.card))
        ctx.draw(Text("LAUNDRY").font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundColor(Theme.indigo),
                 at: CGPoint(x: board.midX, y: board.midY - 4))
        ctx.draw(Text("kiloan").font(.system(size: 9, weight: .bold, design: .rounded)).foregroundColor(Theme.sambal),
                 at: CGPoint(x: board.midX, y: board.midY + 8))
        Kawung.draw(in: ctx, center: CGPoint(x: board.minX + 14, y: board.midY), size: 12 + sin(t * 2) * 1,
                    color: Theme.kunyit, filled: true)
        Kawung.draw(in: ctx, center: CGPoint(x: board.maxX - 14, y: board.midY), size: 12 + cos(t * 2) * 1,
                    color: Theme.kunyit, filled: true)
    }

    private func shelves(_ ctx: inout GraphicsContext) {
        let colors: [Color] = [Theme.sambal, Theme.laut, Theme.kunyit, Theme.jambu, Theme.sawah, Theme.card, Theme.indigo]
        for (row, y) in [96.0, 136, 176].enumerated() {
            ctx.fill(Path(CGRect(x: 18, y: y, width: 96, height: 4)), with: .color(wood))
            var x = 22.0
            var k = row * 2
            while x < 104 {
                let height = 6.0
                for layer in 0..<(3 + (k % 2)) {
                    let r = CGRect(x: x, y: y - height * Double(layer + 1), width: 22, height: height - 0.8)
                    ctx.fill(Path(roundedRect: r, cornerRadius: 2), with: .color(colors[(k + layer) % colors.count].opacity(0.85)))
                }
                x += 27
                k += 1
            }
        }
    }

    private func washer(_ ctx: inout GraphicsContext, t: Double) {
        let body = CGRect(x: 296, y: 116, width: 76, height: 92)
        let shake = busy ? sin(t * 40) * 0.6 : sin(t * 22) * 0.3
        var c = ctx
        c.translateBy(x: shake, y: 0)
        c.fill(Path(roundedRect: body, cornerRadius: 8), with: .color(Theme.card))
        c.stroke(Path(roundedRect: body, cornerRadius: 8), with: .color(Theme.line.darker(0.1)), lineWidth: 1.5)
        c.fill(Path(CGRect(x: body.minX + 8, y: body.minY + 8, width: 26, height: 6)), with: .color(Theme.line))
        c.fill(Path(ellipseIn: CGRect(x: body.maxX - 18, y: body.minY + 6, width: 9, height: 9)), with: .color(Theme.sawah))
        let center = CGPoint(x: body.midX, y: body.midY + 10)
        let door = Path(ellipseIn: CGRect(x: center.x - 25, y: center.y - 25, width: 50, height: 50))
        c.fill(door, with: .color(Color(hex: 0xBFD7DC)))
        var drum = c
        drum.clip(to: door)
        drum.translateBy(x: center.x, y: center.y)
        drum.rotate(by: .radians(t * (busy ? 5 : 3)))
        for (k, color) in [Theme.sambal, Theme.kunyit, Theme.jambu].enumerated() {
            var cloth = drum
            cloth.rotate(by: .radians(Double(k) * 2.1))
            cloth.fill(Path(roundedRect: CGRect(x: -6, y: 6, width: 18, height: 12), cornerRadius: 5), with: .color(color))
        }
        drum.fill(Path(CGRect(x: -30, y: 14, width: 60, height: 20)), with: .color(Theme.laut.opacity(0.3)))
        c.stroke(door, with: .color(Color(hex: 0x9AA4AD)), lineWidth: 4)
        c.fill(Path(ellipseIn: CGRect(x: center.x - 14, y: center.y - 18, width: 10, height: 6)), with: .color(.white.opacity(0.6)))
    }

    private func bubbles(_ ctx: inout GraphicsContext, t: Double) {
        let count = compact ? 4 : 8
        for i in 0..<count {
            let p = (t * 0.16 + Double(i) / Double(count)).truncatingRemainder(dividingBy: 1)
            let x = 334 + sin(p * 7 + Double(i) * 1.3) * 22 - p * 40
            let y = 120 - p * 110
            let r = 3 + Double(i % 3) * 1.6
            let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
            ctx.stroke(Path(ellipseIn: rect), with: .color(Theme.laut.opacity(0.5 * (1 - p))), lineWidth: 1)
            ctx.fill(Path(ellipseIn: CGRect(x: x - r * 0.4, y: y - r * 0.6, width: r * 0.5, height: r * 0.5)),
                     with: .color(.white.opacity(0.8 * (1 - p))))
        }
    }

    private func counter(_ ctx: inout GraphicsContext, t: Double) {
        let front = CGRect(x: 112, y: 182, width: 176, height: 54)
        ctx.fill(Path(front), with: .color(Theme.indigo.lighter(0.08)))
        for i in 0..<5 {
            Kawung.draw(in: ctx, center: CGPoint(x: front.minX + 22 + Double(i) * 33, y: front.midY + 2),
                        size: 16, color: .white.opacity(0.22), filled: false, lineWidth: 1)
        }
        ctx.fill(Path(roundedRect: CGRect(x: front.minX - 6, y: front.minY - 6, width: front.width + 12, height: 9), cornerRadius: 3),
                 with: .color(wood))
        // Plastic bag of laundry, knotted, waiting its turn.
        let bag = CGRect(x: 124, y: 150, width: 40, height: 30)
        ctx.fill(Path(roundedRect: bag, cornerRadius: 12), with: .color(Theme.jambu.opacity(0.75)))
        var knot = Path()
        knot.move(to: CGPoint(x: bag.midX - 6, y: bag.minY + 2))
        knot.addLine(to: CGPoint(x: bag.midX - 9, y: bag.minY - 8))
        knot.move(to: CGPoint(x: bag.midX + 6, y: bag.minY + 2))
        knot.addLine(to: CGPoint(x: bag.midX + 9, y: bag.minY - 8))
        ctx.stroke(knot, with: .color(Theme.jambu.opacity(0.75)), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        ctx.fill(Path(ellipseIn: CGRect(x: bag.minX + 8, y: bag.minY + 6, width: 10, height: 6)), with: .color(.white.opacity(0.35)))
    }

    /// A round dial scale on the counter, needle settling on the weight.
    private func scale(_ ctx: inout GraphicsContext, t: Double) {
        let base = CGRect(x: 250, y: 150, width: 38, height: 28)
        ctx.fill(Path(roundedRect: base, cornerRadius: 6), with: .color(Theme.sambal))
        ctx.fill(Path(roundedRect: CGRect(x: base.minX - 4, y: base.minY - 5, width: base.width + 8, height: 6), cornerRadius: 3),
                 with: .color(Color(hex: 0xB9B3A8)))
        let dial = CGPoint(x: base.midX, y: base.midY + 2)
        ctx.fill(Path(ellipseIn: CGRect(x: dial.x - 10, y: dial.y - 10, width: 20, height: 20)), with: .color(Theme.card))
        let settle = 0.6 + sin(t * 2.4) * 0.18 * (busy ? 1.5 : 1)
        var needle = Path()
        needle.move(to: dial)
        needle.addLine(to: CGPoint(x: dial.x + sin(settle) * 8, y: dial.y - cos(settle) * 8))
        ctx.stroke(needle, with: .color(Theme.ink), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
    }

    private func nota(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        let flutter = sin(t * 4) * 0.08
        var c = ctx
        c.translateBy(x: p.x + 2, y: p.y - 6)
        c.rotate(by: .radians(-0.15 + flutter))
        c.fill(Path(roundedRect: CGRect(x: 0, y: -8, width: 16, height: 20), cornerRadius: 2), with: .color(.white))
        var lines = Path()
        for k in 0..<3 {
            lines.move(to: CGPoint(x: 3, y: -4 + Double(k) * 5)); lines.addLine(to: CGPoint(x: 13 - Double(k) * 2, y: -4 + Double(k) * 5))
        }
        c.stroke(lines, with: .color(Theme.inkSoft.opacity(0.6)), lineWidth: 1)
    }
}
