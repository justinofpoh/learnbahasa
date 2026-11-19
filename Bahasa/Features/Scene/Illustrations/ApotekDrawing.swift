import SwiftUI

/// A bright little apotek: a glowing green cross, a ceiling fan, a wall of colourful medicine boxes,
/// a glass counter, a potted plant, and Mbak Rina in her white coat holding out a small box.
struct ApotekDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let wall = Color(hex: 0xE4EFE8)
    private let wood = Color(hex: 0x8A5E3F)
    private let floor = Color(hex: 0xDCD3C2)
    private let green = Color(hex: 0x2E9B6A)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        ctx.fill(Path(CGRect(x: f.left, y: f.top, width: f.width, height: 214 - f.top)), with: .color(wall))
        ctx.fill(Path(CGRect(x: f.left, y: f.top, width: f.width, height: 14 - f.top)), with: .color(green.opacity(0.85)))
        ctx.fill(Path(CGRect(x: f.left, y: 206, width: f.width, height: max(60, f.bottomY - 196))), with: .color(floor))
        var tiles = Path()
        for x in stride(from: f.left, through: f.right, by: 30) {
            tiles.move(to: CGPoint(x: x, y: 206)); tiles.addLine(to: CGPoint(x: x, y: f.bottomY + 10))
        }
        ctx.stroke(tiles, with: .color(.black.opacity(0.05)), lineWidth: 1)

        shelves(&ctx, t: t)
        fan(&ctx, t: t)
        cross(&ctx, t: t)
        plant(&ctx, at: CGPoint(x: 352, y: 232), t: t)

        Figure(skin: Color(hex: 0xC9905F), hair: .hijab(Theme.laut), outfit: Theme.card, trim: Theme.jambu)
            .draw(&ctx, head: CGPoint(x: 200, y: 118), t: t, speaking: speaking, expression: expression,
                  pace: busy ? 1.6 : 1,
                  gesture: .holding(CGPoint(x: 240, y: 168)) { ctx, p in box(&ctx, at: p, t: t) })
        // A badge on the white coat.
        ctx.fill(Path(roundedRect: CGRect(x: 180, y: 152, width: 10, height: 6), cornerRadius: 1.5), with: .color(green))
        counter(&ctx, t: t)
    }

    private func shelves(_ ctx: inout GraphicsContext, t: Double) {
        let back = CGRect(x: 92, y: 40, width: 216, height: 140)
        ctx.fill(Path(roundedRect: back, cornerRadius: 6), with: .color(Theme.card))
        ctx.stroke(Path(roundedRect: back, cornerRadius: 6), with: .color(Theme.line), lineWidth: 1.5)
        let colors: [Color] = [Theme.sambal, Theme.laut, Theme.kunyit, Theme.jambu, green, Theme.indigo, Color(hex: 0xF0C8A0)]
        for (row, y) in [76.0, 110, 144].enumerated() {
            ctx.fill(Path(CGRect(x: back.minX + 4, y: y, width: back.width - 8, height: 3)), with: .color(wood.opacity(0.6)))
            var x = back.minX + 10
            var k = row * 3
            while x < back.maxX - 16 {
                let w = 10.0 + Double((k * 7) % 4) * 3
                let h = 16.0 + Double((k * 5) % 3) * 4
                let r = CGRect(x: x, y: y - h, width: w, height: h)
                ctx.fill(Path(roundedRect: r, cornerRadius: 1.5), with: .color(colors[k % colors.count].opacity(0.85)))
                ctx.fill(Path(CGRect(x: r.minX, y: r.minY + h * 0.35, width: w, height: 3)), with: .color(.white.opacity(0.6)))
                x += w + 3
                k += 1
            }
        }
    }

    private func fan(_ ctx: inout GraphicsContext, t: Double) {
        let hub = CGPoint(x: 330, y: 26)
        var rod = Path()
        rod.move(to: CGPoint(x: hub.x, y: 12)); rod.addLine(to: hub)
        ctx.stroke(rod, with: .color(Theme.inkSoft), lineWidth: 2)
        let spin = t * (busy ? 9 : 6)
        for k in 0..<3 {
            let a = spin + Double(k) * 2 * .pi / 3
            // Blades seen from the side: they stretch and shrink as they turn.
            let reach = cos(a) * 34
            ctx.fill(Path(ellipseIn: CGRect(x: hub.x + min(0, reach), y: hub.y - 2.5, width: abs(reach), height: 5)),
                     with: .color(Theme.kopi.opacity(0.75)))
        }
        ctx.fill(Path(ellipseIn: CGRect(x: hub.x - 6, y: hub.y - 4, width: 12, height: 9)), with: .color(Theme.inkSoft))
    }

    /// The pharmacy cross, glowing softly.
    private func cross(_ ctx: inout GraphicsContext, t: Double) {
        let c = CGPoint(x: 52, y: 66)
        let glow = 0.5 + 0.5 * sin(t * 2)
        ctx.fill(Path(ellipseIn: CGRect(x: c.x - 30, y: c.y - 30, width: 60, height: 60)), with: .color(green.opacity(0.12 + 0.1 * glow)))
        var plus = Path()
        plus.addRoundedRect(in: CGRect(x: c.x - 7, y: c.y - 20, width: 14, height: 40), cornerSize: CGSize(width: 3, height: 3))
        plus.addRoundedRect(in: CGRect(x: c.x - 20, y: c.y - 7, width: 40, height: 14), cornerSize: CGSize(width: 3, height: 3))
        ctx.fill(plus, with: .color(green))
        ctx.stroke(plus, with: .color(.white.opacity(0.4 + 0.4 * glow)), lineWidth: 1.5)
        ctx.draw(Text("APOTEK").font(.system(size: 11, weight: .heavy, design: .rounded)).foregroundColor(green),
                 at: CGPoint(x: c.x, y: c.y + 34))
    }

    private func plant(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        for k in 0..<6 {
            let a = -Double.pi / 2 + (Double(k) - 2.5) * 0.32 + sin(t * 1.1 + Double(k)) * 0.04
            let len = 44.0 + Double(k % 2) * 10
            var leaf = Path()
            leaf.move(to: CGPoint(x: p.x, y: p.y - 22))
            leaf.addQuadCurve(to: CGPoint(x: p.x + cos(a) * len, y: p.y - 22 + sin(a) * len),
                              control: CGPoint(x: p.x + cos(a) * len * 0.4 - 4, y: p.y - 30))
            ctx.stroke(leaf, with: .color(Theme.sawah), style: StrokeStyle(lineWidth: 6, lineCap: .round))
            ctx.stroke(leaf, with: .color(Theme.sawah.lighter(0.2)), style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
        }
        ctx.fill(Path(roundedRect: CGRect(x: p.x - 15, y: p.y - 26, width: 30, height: 28), cornerRadius: 6), with: .color(Theme.card))
        ctx.fill(Path(CGRect(x: p.x - 15, y: p.y - 16, width: 30, height: 4)), with: .color(Theme.jambu.opacity(0.6)))
    }

    private func counter(_ ctx: inout GraphicsContext, t: Double) {
        let glass = CGRect(x: 96, y: 182, width: 208, height: 54)
        ctx.fill(Path(glass), with: .color(Color(hex: 0xCFE3DD).opacity(0.9)))
        // Boxes inside the glass case.
        let colors: [Color] = [Theme.kunyit, Theme.jambu, Theme.laut, green, Theme.sambal]
        for k in 0..<9 {
            let r = CGRect(x: glass.minX + 10 + Double(k) * 22, y: glass.maxY - 20 - Double(k % 2) * 4, width: 16, height: 14 + Double(k % 2) * 4)
            ctx.fill(Path(roundedRect: r, cornerRadius: 1.5), with: .color(colors[k % colors.count].opacity(0.7)))
        }
        // A glint that slides across the glass now and then.
        let g = (t * 0.25).truncatingRemainder(dividingBy: 1)
        var glint = Path()
        glint.move(to: CGPoint(x: glass.minX + g * 280 - 30, y: glass.maxY))
        glint.addLine(to: CGPoint(x: glass.minX + g * 280, y: glass.minY))
        var gc = ctx
        gc.clip(to: Path(glass))
        gc.stroke(glint, with: .color(.white.opacity(0.55)), lineWidth: 8)
        ctx.stroke(Path(glass), with: .color(Color(hex: 0x9FB8B0)), lineWidth: 2)
        ctx.fill(Path(roundedRect: CGRect(x: glass.minX - 6, y: glass.minY - 6, width: glass.width + 12, height: 8), cornerRadius: 3),
                 with: .color(Theme.card))
        ctx.stroke(Path(roundedRect: CGRect(x: glass.minX - 6, y: glass.minY - 6, width: glass.width + 12, height: 8), cornerRadius: 3),
                   with: .color(Theme.line.darker(0.1)), lineWidth: 1)
        // QRIS stand on the counter.
        let qr = CGRect(x: 120, y: 156, width: 22, height: 22)
        ctx.fill(Path(roundedRect: qr, cornerRadius: 3), with: .color(.white))
        ctx.stroke(Path(roundedRect: qr, cornerRadius: 3), with: .color(Theme.sambal), lineWidth: 1.5)
        var dots = Path()
        for i in 0..<4 { for j in 0..<4 where (i * 3 + j * 5) % 3 != 0 {
            dots.addRect(CGRect(x: qr.minX + 4 + Double(i) * 3.6, y: qr.minY + 4 + Double(j) * 3.6, width: 3, height: 3))
        } }
        ctx.fill(dots, with: .color(Theme.ink))
    }

    private func box(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        var c = ctx
        c.translateBy(x: p.x + 4, y: p.y - 8)
        c.rotate(by: .radians(-0.1 + sin(t * 2.5) * 0.05))
        c.fill(Path(roundedRect: CGRect(x: 0, y: -6, width: 22, height: 13), cornerRadius: 2), with: .color(.white))
        c.fill(Path(CGRect(x: 0, y: -1, width: 22, height: 4)), with: .color(green))
        c.stroke(Path(roundedRect: CGRect(x: 0, y: -6, width: 22, height: 13), cornerRadius: 2), with: .color(Theme.line.darker(0.2)), lineWidth: 0.8)
    }
}
