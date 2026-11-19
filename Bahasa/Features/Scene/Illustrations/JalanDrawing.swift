import SwiftUI

/// The roadside pickup: a row of shophouses, power lines with birds, a traffic light cycling,
/// traffic passing, and Pak Agus on an idling scooter holding out the spare helmet.
struct JalanDrawing: PlaceDrawing {
    var speaking: Bool
    var expression: CharacterExpression
    var busy: Bool
    var compact: Bool

    private let asphalt = Color(hex: 0x5B5E66)
    private let scooter = Theme.sambal
    private let helmet = Theme.indigo

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        Illo.sky(&ctx, f, top: Color(hex: 0xF4D3A0), bottom: Color(hex: 0xF6EBD7))
        Illo.sun(&ctx, t: t, center: CGPoint(x: 330, y: 40))
        Illo.clouds(&ctx, f, t: t, count: compact ? 1 : 3)
        shophouses(&ctx, f)
        Illo.palm(&ctx, t: t, base: CGPoint(x: 386, y: 200), height: 130, phase: 1)
        wires(&ctx, f, t: t)
        street(&ctx, f, t: t)
        trafficLight(&ctx, t: t)
        bike(&ctx, t: t)
        mapPin(&ctx, t: t)
    }

    private func shophouses(_ ctx: inout GraphicsContext, _ f: IlloFrame) {
        let walls = [Color(hex: 0xE9C99A), Color(hex: 0xEAD7B7), Color(hex: 0xD9B48A), Color(hex: 0xD5DDC8)]
        let signs = ["TOKO", "LAUNDRY", "PULSA", "KOPI", "BENGKEL"]
        let signColors = [Theme.sambal, Theme.laut, Theme.sawah, Theme.kopi, Theme.indigo]
        var i = 0
        for x in stride(from: f.left - 30, through: f.right, by: 72) {
            let h = 92.0 + Double((i * 37) % 30)
            let top = 196 - h
            ctx.fill(Path(CGRect(x: x, y: top, width: 72, height: h)), with: .color(walls[i % walls.count]))
            ctx.fill(Path(CGRect(x: x - 2, y: top - 5, width: 76, height: 6)), with: .color(Color(hex: 0xA8603F)))
            // Upper windows
            for w in 0..<2 {
                let wx = x + 12 + Double(w) * 28
                ctx.fill(Path(roundedRect: CGRect(x: wx, y: top + 12, width: 18, height: 22), cornerRadius: 2), with: .color(Theme.laut.opacity(0.35)))
                ctx.fill(Path(CGRect(x: wx + 8.5, y: top + 12, width: 1, height: 22)), with: .color(.white.opacity(0.6)))
            }
            // Sign board
            let sign = signs[(i + 1) % signs.count]
            let sc = signColors[(i + 1) % signColors.count]
            ctx.fill(Path(roundedRect: CGRect(x: x + 8, y: top + 42, width: 56, height: 14), cornerRadius: 2), with: .color(sc))
            ctx.draw(Text(sign).font(.system(size: 7.5, weight: .heavy, design: .rounded)).foregroundColor(.white),
                     at: CGPoint(x: x + 36, y: top + 49))
            // Rolling shutter
            let shutterTop = top + 62
            ctx.fill(Path(CGRect(x: x + 8, y: shutterTop, width: 56, height: 196 - shutterTop)), with: .color(Color(hex: 0xB9B3A8)))
            var slats = Path()
            for y in stride(from: shutterTop + 4, through: 194, by: 4) {
                slats.move(to: CGPoint(x: x + 8, y: y)); slats.addLine(to: CGPoint(x: x + 64, y: y))
            }
            ctx.stroke(slats, with: .color(.black.opacity(0.1)), lineWidth: 1)
            i += 1
        }
    }

    private func wires(_ ctx: inout GraphicsContext, _ f: IlloFrame, t: Double) {
        let pole = Color(hex: 0x7A6E62)
        ctx.fill(Path(CGRect(x: 92, y: 66, width: 5, height: 136)), with: .color(pole))
        ctx.fill(Path(CGRect(x: 80, y: 72, width: 30, height: 3)), with: .color(pole))
        var wire = Path()
        for dy in [0.0, 6] {
            let a = CGPoint(x: f.left, y: 80 + dy), b = CGPoint(x: 94, y: 74 + dy), c = CGPoint(x: f.right, y: 70 + dy)
            wire.move(to: a); wire.addQuadCurve(to: b, control: CGPoint(x: (a.x + b.x) / 2, y: 92 + dy))
            wire.move(to: b); wire.addQuadCurve(to: c, control: CGPoint(x: (b.x + c.x) / 2, y: 96 + dy))
        }
        ctx.stroke(wire, with: .color(Theme.ink.opacity(0.45)), lineWidth: 1)
        if !compact {
            for (i, x) in [168.0, 184].enumerated() {
                let along = (x - 94) / (f.right - 94)
                let y = Illo.quad(CGPoint(x: 94, y: 74), CGPoint(x: (94 + f.right) / 2, y: 96), CGPoint(x: f.right, y: 70), along).y
                Illo.bird(&ctx, at: CGPoint(x: x, y: y - 4), t: t, color: Color(hex: 0x4A4D55), phase: Double(i) * 2)
            }
        }
    }

    private func street(_ ctx: inout GraphicsContext, _ f: IlloFrame, t: Double) {
        ctx.fill(Path(CGRect(x: f.left, y: 196, width: f.width, height: 12)), with: .color(Color(hex: 0xD8CBB4)))
        ctx.fill(Path(CGRect(x: f.left, y: 206, width: f.width, height: 3)), with: .color(Color(hex: 0xB9AC96)))
        ctx.fill(Path(CGRect(x: f.left, y: 209, width: f.width, height: max(60, f.bottomY - 200))), with: .color(asphalt))
        var dashes = Path()
        for x in stride(from: f.left, through: f.right, by: 36) {
            dashes.addRect(CGRect(x: x, y: 252, width: 18, height: 2.5))
        }
        ctx.fill(dashes, with: .color(.white.opacity(0.6)))
        // A car passing on the far lane, and a scooter the other way.
        let span = f.width + 200
        let carX = f.left - 100 + (t * 46).truncatingRemainder(dividingBy: span)
        car(&ctx, at: CGPoint(x: carX, y: 218), color: Theme.laut.lighter(0.15))
        let bikeX = f.right + 60 - (t * 62 + 300).truncatingRemainder(dividingBy: span)
        var mini = Path()
        mini.addRoundedRect(in: CGRect(x: bikeX, y: 214, width: 20, height: 7), cornerSize: CGSize(width: 3, height: 3))
        mini.addEllipse(in: CGRect(x: bikeX - 2, y: 219, width: 7, height: 7))
        mini.addEllipse(in: CGRect(x: bikeX + 15, y: 219, width: 7, height: 7))
        ctx.fill(mini, with: .color(Theme.kunyit.opacity(0.8)))
        ctx.fill(Path(ellipseIn: CGRect(x: bikeX + 5, y: 203, width: 9, height: 12)), with: .color(Theme.ink.opacity(0.55)))
    }

    private func car(_ ctx: inout GraphicsContext, at p: CGPoint, color: Color) {
        var body = Path()
        body.addRoundedRect(in: CGRect(x: p.x, y: p.y - 6, width: 54, height: 12), cornerSize: CGSize(width: 4, height: 4))
        body.addRoundedRect(in: CGRect(x: p.x + 12, y: p.y - 16, width: 28, height: 12), cornerSize: CGSize(width: 5, height: 5))
        ctx.fill(body, with: .color(color.opacity(0.85)))
        ctx.fill(Path(roundedRect: CGRect(x: p.x + 16, y: p.y - 13, width: 20, height: 7), cornerRadius: 2), with: .color(.white.opacity(0.5)))
        for wx in [p.x + 10, p.x + 44] {
            ctx.fill(Path(ellipseIn: CGRect(x: wx - 5, y: p.y + 2, width: 10, height: 10)), with: .color(Theme.ink.opacity(0.8)))
        }
    }

    private func trafficLight(_ ctx: inout GraphicsContext, t: Double) {
        let x = 30.0
        ctx.fill(Path(CGRect(x: x - 2, y: 120, width: 4, height: 88)), with: .color(Color(hex: 0x4A4D55)))
        ctx.fill(Path(roundedRect: CGRect(x: x - 8, y: 96, width: 16, height: 40), cornerRadius: 4), with: .color(Theme.ink))
        let phase = t.truncatingRemainder(dividingBy: 8)
        let lit = phase < 3.5 ? 0 : (phase < 7 ? 2 : 1)
        let colors = [Color(hex: 0xE74C3C), Theme.kunyit, Color(hex: 0x2ECC71)]
        for i in 0..<3 {
            let on = i == lit
            let r = CGRect(x: x - 4.5, y: 100 + Double(i) * 12, width: 9, height: 9)
            if on {
                ctx.fill(Path(ellipseIn: r.insetBy(dx: -4, dy: -4)), with: .color(colors[i].opacity(0.3)))
            }
            ctx.fill(Path(ellipseIn: r), with: .color(on ? colors[i] : colors[i].opacity(0.2)))
        }
    }

    private func bike(_ ctx: inout GraphicsContext, t: Double) {
        let rear = CGPoint(x: 160, y: 238), front = CGPoint(x: 272, y: 238)
        // Exhaust
        Illo.puffs(&ctx, from: CGPoint(x: 128, y: 232), t: t, rate: 0.9, rise: 16, drift: -36,
                   color: Color(hex: 0xBDB6AC), count: 3)
        for w in [rear, front] {
            ctx.fill(Path(ellipseIn: CGRect(x: w.x - 18, y: w.y - 18, width: 36, height: 36)), with: .color(Theme.ink))
            ctx.fill(Path(ellipseIn: CGRect(x: w.x - 8, y: w.y - 8, width: 16, height: 16)), with: .color(Color(hex: 0xB9B3A8)))
        }
        // Idle shake
        let jitter = sin(t * 38) * 0.45
        var c = ctx
        c.translateBy(x: 0, y: jitter)

        // Rider's leg goes behind the body panel.
        var leg = Path()
        leg.move(to: CGPoint(x: 196, y: 190))
        leg.addQuadCurve(to: CGPoint(x: 226, y: 214), control: CGPoint(x: 222, y: 192))
        c.stroke(leg, with: .color(Theme.indigo.darker(0.1)), style: StrokeStyle(lineWidth: 13, lineCap: .round))
        c.fill(Path(roundedRect: CGRect(x: 222, y: 210, width: 16, height: 7), cornerRadius: 3), with: .color(Theme.ink))

        // Rear body + seat
        c.fill(Path(ellipseIn: CGRect(x: 128, y: 188, width: 84, height: 40)), with: .color(scooter))
        c.fill(Path(roundedRect: CGRect(x: 146, y: 182, width: 66, height: 11), cornerRadius: 5), with: .color(Theme.ink))
        c.fill(Path(roundedRect: CGRect(x: 124, y: 200, width: 14, height: 7), cornerRadius: 3), with: .color(Color(hex: 0xE74C3C)))
        // Floorboard
        c.fill(Path(roundedRect: CGRect(x: 196, y: 214, width: 56, height: 9), cornerRadius: 4), with: .color(scooter.darker(0.15)))
        // Front shield + fork
        var shield = Path()
        shield.move(to: CGPoint(x: 236, y: 222))
        shield.addLine(to: CGPoint(x: 252, y: 222))
        shield.addQuadCurve(to: CGPoint(x: 266, y: 168), control: CGPoint(x: 266, y: 196))
        shield.addLine(to: CGPoint(x: 254, y: 164))
        shield.addQuadCurve(to: CGPoint(x: 236, y: 222), control: CGPoint(x: 240, y: 190))
        shield.closeSubpath()
        c.fill(shield, with: .color(scooter))
        var fork = Path()
        fork.move(to: CGPoint(x: 260, y: 196)); fork.addLine(to: front)
        c.stroke(fork, with: .color(Color(hex: 0x8C8C94)), lineWidth: 4)
        c.fill(Path(ellipseIn: CGRect(x: front.x - 22, y: front.y - 24, width: 44, height: 16)), with: .color(scooter.darker(0.1)))
        // Handlebar, headlight, mirror, phone
        var bar = Path()
        bar.move(to: CGPoint(x: 250, y: 164)); bar.addLine(to: CGPoint(x: 270, y: 160))
        c.stroke(bar, with: .color(Theme.ink), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        c.fill(Path(ellipseIn: CGRect(x: 262, y: 170, width: 12, height: 12)), with: .color(Color(hex: 0xFFE7A6)))
        var mirror = Path()
        mirror.move(to: CGPoint(x: 266, y: 160)); mirror.addLine(to: CGPoint(x: 272, y: 146))
        c.stroke(mirror, with: .color(Theme.ink), lineWidth: 1.5)
        c.fill(Path(ellipseIn: CGRect(x: 268, y: 140, width: 9, height: 7)), with: .color(Theme.ink))
        let phone = Path(roundedRect: CGRect(x: 246, y: 146, width: 11, height: 17), cornerRadius: 2)
        c.fill(phone, with: .color(Theme.ink))
        c.fill(Path(roundedRect: CGRect(x: 247.5, y: 148, width: 8, height: 13), cornerRadius: 1), with: .color(Theme.laut.lighter(0.3)))

        // Pak Agus, holding out the spare helmet unless he's talking.
        let spare = helmet.lighter(0.15)
        Figure(skin: Color(hex: 0xB07A4F), hair: .helmet(helmet), outfit: Theme.laut, trim: Theme.kunyit, collar: .jacket)
            .draw(&c, head: CGPoint(x: 186, y: 122), t: t, speaking: speaking, expression: expression,
                  pace: busy ? 1.6 : 1,
                  gesture: .holding(CGPoint(x: 232, y: 150)) { ctx, p in
                      var dome = Path()
                      dome.addArc(center: CGPoint(x: p.x + 8, y: p.y + 2), radius: 13, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                      dome.closeSubpath()
                      ctx.fill(dome, with: .color(spare))
                      ctx.fill(Path(roundedRect: CGRect(x: p.x - 6, y: p.y, width: 28, height: 4), cornerRadius: 2), with: .color(spare.darker(0.2)))
                  })
    }

    private func mapPin(_ ctx: inout GraphicsContext, t: Double) {
        let p = CGPoint(x: 252, y: 128 + sin(t * 2.4) * 3)
        var pin = Path()
        pin.addArc(center: p, radius: 7, startAngle: .degrees(150), endAngle: .degrees(30), clockwise: false)
        pin.addLine(to: CGPoint(x: p.x, y: p.y + 13))
        pin.closeSubpath()
        ctx.fill(pin, with: .color(Theme.sambal))
        ctx.fill(Path(ellipseIn: CGRect(x: p.x - 2.5, y: p.y - 2.5, width: 5, height: 5)), with: .color(.white))
        let ring = (t * 0.8).truncatingRemainder(dividingBy: 1)
        ctx.stroke(Path(ellipseIn: CGRect(x: p.x - 6 - ring * 6, y: p.y + 13 - 2 - ring * 2, width: 12 + ring * 12, height: 4 + ring * 4)),
                   with: .color(Theme.sambal.opacity(0.6 * (1 - ring))), lineWidth: 1)
    }
}
