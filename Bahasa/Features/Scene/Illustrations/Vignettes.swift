import SwiftUI

// Decorative drawings for the tabs, in the same hand as the place drawings.

enum TabArt {
    case learn, talk, patterns, phrases

    @ViewBuilder
    var view: some View {
        switch self {
        case .learn: IllustrationCanvas(drawing: NookDrawing(hour: Calendar.current.component(.hour, from: Date())), fps: 24)
        case .talk: IllustrationCanvas(drawing: ChatHillDrawing(), fps: 24)
        case .patterns: IllustrationCanvas(drawing: BlocksDrawing(), fps: 24)
        case .phrases: IllustrationCanvas(drawing: NotebookDrawing(), fps: 24)
        }
    }
}

/// Sky colours that follow the clock, for a calm after-work evening.
private struct SkyMood {
    let top: Color, bottom: Color, night: Bool, sunY: Double

    init(hour: Int) {
        switch hour {
        case 5..<11: (top, bottom, night, sunY) = (Color(hex: 0xF9E1B5), Color(hex: 0xF6EBD7), false, 70)
        case 11..<16: (top, bottom, night, sunY) = (Color(hex: 0xF4D9A6), Color(hex: 0xF6EBD7), false, 52)
        case 16..<19: (top, bottom, night, sunY) = (Color(hex: 0xF2B98A), Color(hex: 0xF7DDBE), false, 96)
        default: (top, bottom, night, sunY) = (Color(hex: 0x2F3E6B), Color(hex: 0x6A6F9A), true, 60)
        }
    }
}

// MARK: - Learn: a reading nook at the window

struct NookDrawing: PlaceDrawing {
    var hour: Int

    private let wall = Color(hex: 0xF0E2C6)
    private let wood = Color(hex: 0x8A5E3F)

    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        let sky = SkyMood(hour: hour)
        ctx.fill(Path(CGRect(x: f.left, y: f.top, width: f.width, height: 300 - f.top)), with: .color(wall))
        Kawung.draw(in: ctx, center: CGPoint(x: 40, y: 60), size: 40, color: Theme.kunyit.opacity(0.18), filled: true)
        Kawung.draw(in: ctx, center: CGPoint(x: 370, y: 150), size: 30, color: Theme.sambal.opacity(0.14), filled: true)

        // Window with the outside world
        let win = CGRect(x: 120, y: 26, width: 200, height: 132)
        var outside = ctx
        outside.clip(to: Path(roundedRect: win, cornerRadius: 8))
        outside.fill(Path(win), with: .linearGradient(Gradient(colors: [sky.top, sky.bottom]),
                                                      startPoint: CGPoint(x: 0, y: win.minY), endPoint: CGPoint(x: 0, y: win.maxY)))
        if sky.night {
            for k in 0..<9 {
                let x = win.minX + 14 + Double((k * 47) % 180)
                let y = win.minY + 12 + Double((k * 29) % 60)
                let tw = 0.4 + 0.6 * abs(sin(t * 1.3 + Double(k)))
                outside.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 3, height: 3)), with: .color(.white.opacity(tw)))
            }
            let moon = CGPoint(x: 280, y: 58)
            outside.fill(Path(ellipseIn: CGRect(x: moon.x - 14, y: moon.y - 14, width: 28, height: 28)), with: .color(Color(hex: 0xFFF2C9)))
            outside.fill(Path(ellipseIn: CGRect(x: moon.x - 6, y: moon.y - 18, width: 26, height: 26)), with: .color(sky.top))
        } else {
            Illo.sun(&outside, t: t, center: CGPoint(x: 278, y: sky.sunY))
        }
        Illo.hills(&outside, IlloFrame(left: win.minX, width: win.width, top: win.minY, bottomY: win.maxY), base: 112,
                   color: sky.night ? Color(hex: 0x23304F) : Theme.sawah)
        Illo.palm(&outside, t: t, base: CGPoint(x: 150, y: 170), height: 92, phase: 0.5)
        ctx.stroke(Path(roundedRect: win, cornerRadius: 8), with: .color(wood), lineWidth: 7)
        var bars = Path()
        bars.move(to: CGPoint(x: win.midX, y: win.minY)); bars.addLine(to: CGPoint(x: win.midX, y: win.maxY))
        ctx.stroke(bars, with: .color(wood), lineWidth: 4)
        ctx.fill(Path(roundedRect: CGRect(x: win.minX - 12, y: win.maxY, width: win.width + 24, height: 8), cornerRadius: 3), with: .color(wood.darker(0.1)))

        // Desk
        ctx.fill(Path(CGRect(x: f.left, y: 196, width: f.width, height: 80)), with: .color(Color(hex: 0xB98A5E)))
        ctx.fill(Path(CGRect(x: f.left, y: 192, width: f.width, height: 8)), with: .color(wood))

        lamp(&ctx, t: t, night: sky.night || hour >= 16)
        book(&ctx, t: t)
        mug(&ctx, at: CGPoint(x: 300, y: 188), t: t)
        sleepyCat(&ctx, t: t)
        plant(&ctx, at: CGPoint(x: 352, y: 192), t: t)
    }

    private func lamp(_ ctx: inout GraphicsContext, t: Double, night: Bool) {
        let base = CGPoint(x: 84, y: 192)
        if night {
            let glow = 0.35 + 0.05 * sin(t * 2)
            ctx.fill(Path(ellipseIn: CGRect(x: base.x - 70, y: 70, width: 150, height: 140)),
                     with: .radialGradient(Gradient(colors: [Theme.kunyit.opacity(glow), .clear]),
                                           center: CGPoint(x: base.x + 6, y: 120), startRadius: 0, endRadius: 75))
        }
        var arm = Path()
        arm.move(to: base); arm.addLine(to: CGPoint(x: base.x - 6, y: 140)); arm.addLine(to: CGPoint(x: base.x + 16, y: 110))
        ctx.stroke(arm, with: .color(Theme.indigo), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
        ctx.fill(Path(ellipseIn: CGRect(x: base.x - 16, y: base.y - 5, width: 32, height: 9)), with: .color(Theme.indigo))
        var shade = Path()
        shade.move(to: CGPoint(x: base.x + 6, y: 104)); shade.addLine(to: CGPoint(x: base.x + 30, y: 104))
        shade.addLine(to: CGPoint(x: base.x + 38, y: 124)); shade.addLine(to: CGPoint(x: base.x - 2, y: 124))
        shade.closeSubpath()
        ctx.fill(shade, with: .color(Theme.sambal))
        ctx.fill(Path(ellipseIn: CGRect(x: base.x + 12, y: 121, width: 12, height: 7)), with: .color(Color(hex: 0xFFE7A6)))
    }

    private func book(_ ctx: inout GraphicsContext, t: Double) {
        let c = CGPoint(x: 200, y: 186)
        var left = Path()
        left.move(to: CGPoint(x: c.x, y: c.y - 2))
        left.addQuadCurve(to: CGPoint(x: c.x - 54, y: c.y - 6), control: CGPoint(x: c.x - 26, y: c.y - 14))
        left.addLine(to: CGPoint(x: c.x - 54, y: c.y + 6))
        left.addQuadCurve(to: CGPoint(x: c.x, y: c.y + 8), control: CGPoint(x: c.x - 26, y: c.y))
        left.closeSubpath()
        var right = Path()
        right.move(to: CGPoint(x: c.x, y: c.y - 2))
        right.addQuadCurve(to: CGPoint(x: c.x + 54, y: c.y - 6), control: CGPoint(x: c.x + 26, y: c.y - 14))
        right.addLine(to: CGPoint(x: c.x + 54, y: c.y + 6))
        right.addQuadCurve(to: CGPoint(x: c.x, y: c.y + 8), control: CGPoint(x: c.x + 26, y: c.y))
        right.closeSubpath()
        ctx.fill(Path(roundedRect: CGRect(x: c.x - 58, y: c.y - 2, width: 116, height: 14), cornerRadius: 3), with: .color(Theme.laut))
        ctx.fill(left, with: .color(Theme.card))
        ctx.fill(right, with: .color(Theme.card))
        var lines = Path()
        for k in 0..<3 {
            let y = c.y - 4 + Double(k) * 3.5
            lines.move(to: CGPoint(x: c.x - 46, y: y)); lines.addLine(to: CGPoint(x: c.x - 8, y: y + 1))
            lines.move(to: CGPoint(x: c.x + 8, y: y + 1)); lines.addLine(to: CGPoint(x: c.x + 40, y: y))
        }
        ctx.stroke(lines, with: .color(Theme.inkSoft.opacity(0.35)), lineWidth: 1)
        // A page lifting and settling
        let lift = (sin(t * 0.7) + 1) / 2
        var page = Path()
        page.move(to: CGPoint(x: c.x, y: c.y - 2))
        page.addQuadCurve(to: CGPoint(x: c.x + 46 - lift * 40, y: c.y - 8 - lift * 22),
                          control: CGPoint(x: c.x + 20, y: c.y - 14 - lift * 14))
        page.addLine(to: CGPoint(x: c.x + 2, y: c.y + 2))
        page.closeSubpath()
        ctx.fill(page, with: .color(Color(hex: 0xFBF5EA)))
        ctx.stroke(page, with: .color(Theme.line), lineWidth: 0.8)
    }

    private func mug(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        Illo.puffs(&ctx, from: CGPoint(x: p.x, y: p.y - 16), t: t, rate: 0.3, rise: 34, color: .white, count: 3)
        ctx.fill(Path(roundedRect: CGRect(x: p.x - 11, y: p.y - 18, width: 22, height: 20), cornerRadius: 5), with: .color(Theme.jambu))
        ctx.stroke(Path(ellipseIn: CGRect(x: p.x + 8, y: p.y - 13, width: 9, height: 10)), with: .color(Theme.jambu), lineWidth: 3)
        Kawung.draw(in: ctx, center: CGPoint(x: p.x, y: p.y - 8), size: 9, color: .white.opacity(0.7), filled: false, lineWidth: 0.9)
    }

    private func sleepyCat(_ ctx: inout GraphicsContext, t: Double) {
        // On a little stack of books
        let colors = [Theme.sawah, Theme.kunyit, Theme.indigo]
        for (i, color) in colors.enumerated() {
            ctx.fill(Path(roundedRect: CGRect(x: 120 + Double(i % 2) * 3, y: 184 - Double(i) * 8, width: 44, height: 8), cornerRadius: 2), with: .color(color))
        }
        let c = CGPoint(x: 142, y: 158)
        let orange = Color(hex: 0xE39B4A)
        let breathe = 1 + 0.05 * sin(t * 1.8)
        var tail = Path()
        tail.move(to: CGPoint(x: c.x + 14, y: c.y + 4))
        tail.addQuadCurve(to: CGPoint(x: c.x + 6 + sin(t) * 3, y: c.y + 10), control: CGPoint(x: c.x + 24, y: c.y + 12))
        ctx.stroke(tail, with: .color(orange), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        ctx.fill(Path(ellipseIn: CGRect(x: c.x - 18, y: c.y - 7 * breathe, width: 36, height: 16 * breathe)), with: .color(orange))
        let head = CGPoint(x: c.x - 14, y: c.y)
        ctx.fill(Path(ellipseIn: CGRect(x: head.x - 8, y: head.y - 7, width: 16, height: 13)), with: .color(orange))
        var ears = Path()
        ears.move(to: CGPoint(x: head.x - 7, y: head.y - 3)); ears.addLine(to: CGPoint(x: head.x - 6, y: head.y - 11)); ears.addLine(to: CGPoint(x: head.x - 1, y: head.y - 6))
        ears.move(to: CGPoint(x: head.x + 1, y: head.y - 6)); ears.addLine(to: CGPoint(x: head.x + 6, y: head.y - 11)); ears.addLine(to: CGPoint(x: head.x + 7, y: head.y - 3))
        ctx.fill(ears, with: .color(orange))
        var eyes = Path()
        eyes.addArc(center: CGPoint(x: head.x - 3, y: head.y), radius: 2, startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false)
        eyes.move(to: CGPoint(x: head.x + 5, y: head.y))
        eyes.addArc(center: CGPoint(x: head.x + 3, y: head.y), radius: 2, startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false)
        ctx.stroke(eyes, with: .color(Theme.ink.opacity(0.7)), lineWidth: 1)
        let z = (t * 0.35).truncatingRemainder(dividingBy: 1)
        ctx.draw(Text("z").font(.system(size: 8 + z * 5, weight: .heavy, design: .rounded)).foregroundColor(Theme.inkSoft.opacity(1 - z)),
                 at: CGPoint(x: head.x - 6 - z * 6, y: head.y - 14 - z * 16))
    }

    private func plant(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        for k in 0..<5 {
            let a = -Double.pi / 2 + (Double(k) - 2) * 0.38 + sin(t * 1.1 + Double(k)) * 0.05
            var leaf = Path()
            leaf.move(to: CGPoint(x: p.x, y: p.y - 18))
            leaf.addQuadCurve(to: CGPoint(x: p.x + cos(a) * 34, y: p.y - 18 + sin(a) * 34),
                              control: CGPoint(x: p.x + cos(a) * 14 - 6, y: p.y - 30))
            ctx.stroke(leaf, with: .color(Theme.sawah), style: StrokeStyle(lineWidth: 6, lineCap: .round))
        }
        ctx.fill(Path(roundedRect: CGRect(x: p.x - 14, y: p.y - 20, width: 28, height: 22), cornerRadius: 5), with: .color(Color(hex: 0xC4612F)))
    }
}

// MARK: - Talk: a hill above the sea, with words drifting up

struct ChatHillDrawing: PlaceDrawing {
    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        Illo.sky(&ctx, f, top: Color(hex: 0xF5C99A), bottom: Color(hex: 0xF7E3C6))
        Illo.sun(&ctx, t: t, center: CGPoint(x: 300, y: 120))
        Illo.clouds(&ctx, f, t: t, count: 2)
        // Sea
        ctx.fill(Path(CGRect(x: f.left, y: 150, width: f.width, height: 120)), with: .color(Theme.laut.opacity(0.8)))
        var shimmer = Path()
        for k in 0..<10 {
            let x = f.left + 20 + Double(k) * 44 + sin(t + Double(k)) * 6
            shimmer.move(to: CGPoint(x: x, y: 160 + Double(k % 4) * 8))
            shimmer.addLine(to: CGPoint(x: x + 16, y: 160 + Double(k % 4) * 8))
        }
        ctx.stroke(shimmer, with: .color(.white.opacity(0.55)), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
        // Hill
        var hill = Path()
        hill.move(to: CGPoint(x: f.left, y: 300))
        hill.addLine(to: CGPoint(x: f.left, y: 196))
        hill.addQuadCurve(to: CGPoint(x: f.right, y: 214), control: CGPoint(x: 160, y: 150))
        hill.addLine(to: CGPoint(x: f.right, y: 300))
        hill.closeSubpath()
        ctx.fill(hill, with: .color(Theme.sawah))
        Illo.palm(&ctx, t: t, base: CGPoint(x: 70, y: 196), height: 140)
        Illo.palm(&ctx, t: t, base: CGPoint(x: 112, y: 186), height: 110, phase: 1.4)
        // Bench with two cups
        ctx.fill(Path(roundedRect: CGRect(x: 196, y: 176, width: 70, height: 7), cornerRadius: 3), with: .color(Color(hex: 0x8A5E3F)))
        for x in [204.0, 252] {
            ctx.fill(Path(CGRect(x: x, y: 183, width: 5, height: 14)), with: .color(Color(hex: 0x6F4E37)))
        }
        for x in [214.0, 246] {
            ctx.fill(Path(roundedRect: CGRect(x: x - 5, y: 166, width: 10, height: 10), cornerRadius: 2), with: .color(Theme.card))
            Illo.puffs(&ctx, from: CGPoint(x: x, y: 162), t: t + x, rate: 0.35, rise: 18, color: .white, count: 2)
        }

        // Speech bubbles drifting up and fading
        let words = ["Halo!", "Apa kabar?", "Makasih!", "Mau ke mana?", "Sampai jumpa!"]
        let colors = [Theme.sambal, Theme.laut, Theme.kunyit, Theme.jambu, Theme.indigo]
        for (i, word) in words.enumerated() {
            let p = (t * 0.07 + Double(i) / Double(words.count)).truncatingRemainder(dividingBy: 1)
            let x = 150 + Double((i * 83) % 200) + sin(p * 6 + Double(i)) * 8
            let y = 170 - p * 150
            let alpha = p < 0.15 ? p / 0.15 : (p > 0.8 ? (1 - p) / 0.2 : 1)
            bubble(&ctx, text: word, at: CGPoint(x: x, y: y), color: colors[i], alpha: alpha, left: i % 2 == 0)
        }
    }

    private func bubble(_ ctx: inout GraphicsContext, text: String, at p: CGPoint, color: Color, alpha: Double, left: Bool) {
        let w = Double(text.count) * 6.4 + 18
        let rect = CGRect(x: p.x - w / 2, y: p.y - 11, width: w, height: 22)
        var shape = Path(roundedRect: rect, cornerRadius: 11)
        let tx = left ? rect.minX + 12 : rect.maxX - 12
        shape.move(to: CGPoint(x: tx - 4, y: rect.maxY - 1))
        shape.addLine(to: CGPoint(x: tx + (left ? -6 : 6), y: rect.maxY + 7))
        shape.addLine(to: CGPoint(x: tx + 4, y: rect.maxY - 1))
        ctx.fill(shape, with: .color(Theme.card.opacity(0.95 * alpha)))
        ctx.draw(Text(text).font(.system(size: 10.5, weight: .bold, design: .rounded)).foregroundColor(color.opacity(alpha)),
                 at: CGPoint(x: rect.midX, y: rect.midY))
    }
}

// MARK: - Patterns: word blocks on a shelf

struct BlocksDrawing: PlaceDrawing {
    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        ctx.fill(Path(CGRect(x: f.left, y: f.top, width: f.width, height: 300 - f.top)), with: .color(Color(hex: 0xE9E4F0)))
        for k in 0..<8 {
            Kawung.draw(in: ctx, center: CGPoint(x: Double(k) * 60 - 10, y: 50 + Double(k % 2) * 60),
                        size: 34, color: Theme.indigo.opacity(0.07), filled: true)
        }
        // Shelf
        ctx.fill(Path(CGRect(x: f.left, y: 202, width: f.width, height: 80)), with: .color(Color(hex: 0xC8B8A0)))
        ctx.fill(Path(roundedRect: CGRect(x: 40, y: 192, width: 320, height: 12), cornerRadius: 4), with: .color(Color(hex: 0x8A5E3F)))

        // The sentence, block by block: Saya · makan · nasi
        let row: [(String, String, Color)] = [("Saya", "S", Theme.indigo), ("makan", "V", Theme.sambal), ("nasi", "O", Theme.sawah)]
        var x = 84.0
        for (i, item) in row.enumerated() {
            let w = Double(item.0.count) * 11 + 30
            let hop = max(0, sin(t * 1.6 - Double(i) * 0.9)) * 6
            block(&ctx, rect: CGRect(x: x, y: 150 - hop, width: w, height: 42), word: item.0, tag: item.1, color: item.2)
            x += w + 10
        }
        // A time block balancing on top, wobbling
        let wobble = sin(t * 1.2) * 0.08
        var top = ctx
        top.translateBy(x: 150, y: 150)
        top.rotate(by: .radians(wobble))
        block(&top, rect: CGRect(x: -32, y: -42, width: 64, height: 38), word: "sudah", tag: "T", color: Theme.kunyit)
        // A little star for a job well done
        let pulse = 1 + 0.15 * sin(t * 3)
        Kawung.draw(in: ctx, center: CGPoint(x: 330, y: 120), size: 18 * pulse, color: Theme.kunyit, filled: true)
        Kawung.draw(in: ctx, center: CGPoint(x: 62, y: 96), size: 12 * (2 - pulse), color: Theme.jambu.opacity(0.8), filled: true)
    }

    private func block(_ ctx: inout GraphicsContext, rect: CGRect, word: String, tag: String, color: Color) {
        ctx.fill(Path(roundedRect: rect.offsetBy(dx: 0, dy: 4), cornerRadius: 10), with: .color(color.darker(0.25)))
        ctx.fill(Path(roundedRect: rect, cornerRadius: 10), with: .color(color))
        ctx.fill(Path(roundedRect: rect.insetBy(dx: 4, dy: 4).offsetBy(dx: 0, dy: -1), cornerRadius: 7), with: .color(.white.opacity(0.12)))
        ctx.draw(Text(word).font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundColor(.white),
                 at: CGPoint(x: rect.midX, y: rect.midY - 3))
        ctx.draw(Text(tag).font(.system(size: 8, weight: .bold, design: .rounded)).foregroundColor(.white.opacity(0.75)),
                 at: CGPoint(x: rect.midX, y: rect.maxY - 8))
    }
}

// MARK: - Phrases: a notebook with sticky notes

struct NotebookDrawing: PlaceDrawing {
    func draw(_ ctx: inout GraphicsContext, frame f: IlloFrame, t: Double) {
        // Woven mat
        ctx.fill(Path(CGRect(x: f.left, y: f.top, width: f.width, height: 300 - f.top)), with: .color(Color(hex: 0xE8D6B5)))
        var weave = Path()
        for x in stride(from: f.left, through: f.right, by: 14) {
            weave.move(to: CGPoint(x: x, y: f.top)); weave.addLine(to: CGPoint(x: x + 40, y: 280))
        }
        ctx.stroke(weave, with: .color(Color(hex: 0xC9A15A).opacity(0.25)), lineWidth: 5)

        // Notebook
        var book = ctx
        book.translateBy(x: 200, y: 140)
        book.rotate(by: .degrees(-4))
        book.fill(Path(roundedRect: CGRect(x: -122, y: -76, width: 244, height: 156), cornerRadius: 10), with: .color(Theme.sambal))
        book.fill(Path(roundedRect: CGRect(x: -116, y: -80, width: 114, height: 150), cornerRadius: 6), with: .color(Theme.card))
        book.fill(Path(roundedRect: CGRect(x: 2, y: -80, width: 114, height: 150), cornerRadius: 6), with: .color(Theme.card))
        var rules = Path()
        for k in 0..<7 {
            let y = -56.0 + Double(k) * 17
            rules.move(to: CGPoint(x: -106, y: y)); rules.addLine(to: CGPoint(x: -12, y: y))
            rules.move(to: CGPoint(x: 12, y: y)); rules.addLine(to: CGPoint(x: 106, y: y))
        }
        book.stroke(rules, with: .color(Theme.laut.opacity(0.18)), lineWidth: 1)
        book.draw(Text("Selamat pagi").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(Theme.indigo),
                  at: CGPoint(x: -60, y: -48))
        book.draw(Text("Terima kasih").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(Theme.sawah),
                  at: CGPoint(x: -60, y: -14))
        // The line being written, appearing letter by letter
        let full = "Sampai jumpa"
        let n = Int((t * 3).truncatingRemainder(dividingBy: Double(full.count + 6)))
        book.draw(Text(String(full.prefix(min(n, full.count)))).font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(Theme.jambu),
                  at: CGPoint(x: -60, y: 20))
        book.fill(Path(CGRect(x: -1.5, y: -80, width: 3, height: 150)), with: .color(.black.opacity(0.08)))

        // Sticky notes fluttering
        note(&ctx, text: "Makasih!", at: CGPoint(x: 268, y: 96), color: Color(hex: 0xFFE08A), angle: 6 + sin(t * 1.4) * 2)
        note(&ctx, text: "Pelan-pelan", at: CGPoint(x: 262, y: 168), color: Color(hex: 0xBFE3D0), angle: -5 + sin(t * 1.2 + 1) * 2)

        // Pencil rolling a little
        let roll = sin(t * 0.8) * 6
        var pencil = ctx
        pencil.translateBy(x: 120 + roll, y: 224)
        pencil.rotate(by: .degrees(-12))
        pencil.fill(Path(roundedRect: CGRect(x: -50, y: -4, width: 86, height: 8), cornerRadius: 2), with: .color(Theme.kunyit))
        var tip = Path()
        tip.move(to: CGPoint(x: 36, y: -4)); tip.addLine(to: CGPoint(x: 48, y: 0)); tip.addLine(to: CGPoint(x: 36, y: 4))
        tip.closeSubpath()
        pencil.fill(tip, with: .color(Color(hex: 0xE8C9A0)))
        pencil.fill(Path(roundedRect: CGRect(x: -56, y: -4, width: 8, height: 8), cornerRadius: 2), with: .color(Theme.jambu))

        // Frangipani
        flower(&ctx, at: CGPoint(x: 62, y: 70), t: t)
        flower(&ctx, at: CGPoint(x: 350, y: 228), t: t + 2)
    }

    private func note(_ ctx: inout GraphicsContext, text: String, at p: CGPoint, color: Color, angle: Double) {
        var c = ctx
        c.translateBy(x: p.x, y: p.y)
        c.rotate(by: .degrees(angle))
        c.fill(Path(roundedRect: CGRect(x: -42, y: -24, width: 84, height: 48), cornerRadius: 3).offsetBy(dx: 2, dy: 3), with: .color(.black.opacity(0.08)))
        c.fill(Path(roundedRect: CGRect(x: -42, y: -24, width: 84, height: 48), cornerRadius: 3), with: .color(color))
        c.fill(Path(CGRect(x: -16, y: -28, width: 32, height: 8)), with: .color(.white.opacity(0.6)))
        c.draw(Text(text).font(.system(size: 12, weight: .heavy, design: .rounded)).foregroundColor(Theme.ink.opacity(0.8)), at: .zero)
    }

    private func flower(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double) {
        var c = ctx
        c.translateBy(x: p.x, y: p.y)
        c.rotate(by: .radians(t * 0.2))
        for k in 0..<5 {
            var petal = c
            petal.rotate(by: .radians(Double(k) / 5 * 2 * .pi))
            petal.fill(Path(ellipseIn: CGRect(x: -6, y: -20, width: 12, height: 20)), with: .color(.white))
        }
        c.fill(Path(ellipseIn: CGRect(x: -5, y: -5, width: 10, height: 10)), with: .color(Theme.kunyit))
    }
}

// MARK: - Unit badges

/// A small hand-drawn badge for each Learn unit, so every unit has its own little picture.
struct UnitBadge: View {
    let number: Int
    let tint: Color
    var size: CGFloat = 44

    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 100
            ctx.scaleBy(x: s, y: s)
            let tile = Path(roundedRect: CGRect(x: 0, y: 0, width: 100, height: 100), cornerRadius: 28)
            ctx.fill(tile, with: .linearGradient(Gradient(colors: [tint.opacity(0.16), tint.opacity(0.3)]),
                                                 startPoint: .zero, endPoint: CGPoint(x: 0, y: 100)))
            var c = ctx
            c.clip(to: tile)
            switch number {
            case 1: sun(&c)
            case 2: blocks(&c)
            case 3: clock(&c)
            case 4: noBubble(&c)
            case 5: askBubble(&c)
            case 6: rings(&c)
            case 8: bowl(&c)
            case 9: signpost(&c)
            case 10: frangipani(&c)
            case 11: linked(&c)
            default: cups(&c)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    // 1 · Halo! — a smiling sun saying hello
    private func sun(_ c: inout GraphicsContext) {
        var rays = Path()
        for i in 0..<10 {
            let a = Double(i) / 10 * 2 * .pi
            rays.move(to: CGPoint(x: 50 + cos(a) * 30, y: 54 + sin(a) * 30))
            rays.addLine(to: CGPoint(x: 50 + cos(a) * 40, y: 54 + sin(a) * 40))
        }
        c.stroke(rays, with: .color(Theme.kunyit), style: StrokeStyle(lineWidth: 5, lineCap: .round))
        c.fill(Path(ellipseIn: CGRect(x: 26, y: 30, width: 48, height: 48)), with: .color(Theme.kunyit))
        face(&c, at: CGPoint(x: 50, y: 54))
    }

    // 2 · Pola Dasar — three word blocks in a row
    private func blocks(_ c: inout GraphicsContext) {
        let colors = [Theme.indigo, Theme.sambal, Theme.sawah]
        for (i, color) in colors.enumerated() {
            let r = CGRect(x: 12 + Double(i) * 27, y: 40 - Double(i % 2) * 6, width: 24, height: 26)
            c.fill(Path(roundedRect: r.offsetBy(dx: 0, dy: 3), cornerRadius: 6), with: .color(color.darker(0.25)))
            c.fill(Path(roundedRect: r, cornerRadius: 6), with: .color(color))
        }
        c.fill(Path(roundedRect: CGRect(x: 10, y: 70, width: 80, height: 6), cornerRadius: 3), with: .color(Color(hex: 0x8A5E3F)))
    }

    // 3 · Waktu — a round clock
    private func clock(_ c: inout GraphicsContext) {
        c.fill(Path(ellipseIn: CGRect(x: 22, y: 22, width: 56, height: 56)), with: .color(Theme.card))
        c.stroke(Path(ellipseIn: CGRect(x: 22, y: 22, width: 56, height: 56)), with: .color(Theme.kunyit), lineWidth: 6)
        var hands = Path()
        hands.move(to: CGPoint(x: 50, y: 50)); hands.addLine(to: CGPoint(x: 50, y: 33))
        hands.move(to: CGPoint(x: 50, y: 50)); hands.addLine(to: CGPoint(x: 62, y: 56))
        c.stroke(hands, with: .color(Theme.ink), style: StrokeStyle(lineWidth: 5, lineCap: .round))
        c.fill(Path(ellipseIn: CGRect(x: 46, y: 46, width: 8, height: 8)), with: .color(Theme.sambal))
    }

    // 4 · Tidak & Bukan — a bubble shaking its head
    private func noBubble(_ c: inout GraphicsContext) {
        bubble(&c, color: Theme.card)
        var x = Path()
        x.move(to: CGPoint(x: 40, y: 34)); x.addLine(to: CGPoint(x: 60, y: 54))
        x.move(to: CGPoint(x: 60, y: 34)); x.addLine(to: CGPoint(x: 40, y: 54))
        c.stroke(x, with: .color(Theme.jambu), style: StrokeStyle(lineWidth: 7, lineCap: .round))
    }

    // 5 · Bertanya — a bubble with a question
    private func askBubble(_ c: inout GraphicsContext) {
        bubble(&c, color: Theme.card)
        c.draw(Text("?").font(.system(size: 34, weight: .heavy, design: .rounded)).foregroundColor(Theme.sawah),
               at: CGPoint(x: 50, y: 45))
    }

    // 6 · Yang & Imbuhan — two linked rings
    private func rings(_ c: inout GraphicsContext) {
        c.stroke(Path(ellipseIn: CGRect(x: 18, y: 32, width: 38, height: 38)), with: .color(Theme.laut), lineWidth: 8)
        c.stroke(Path(ellipseIn: CGRect(x: 44, y: 32, width: 38, height: 38)), with: .color(Theme.kunyit), lineWidth: 8)
    }

    // 7 · Ngobrol — two cups, chatting
    private func cups(_ c: inout GraphicsContext) {
        for (i, x) in [30.0, 64].enumerated() {
            var steam = Path()
            steam.move(to: CGPoint(x: x, y: 36))
            steam.addQuadCurve(to: CGPoint(x: x, y: 20), control: CGPoint(x: x + (i == 0 ? 8 : -8), y: 28))
            c.stroke(steam, with: .color(.white), style: StrokeStyle(lineWidth: 4, lineCap: .round))
            c.fill(Path(roundedRect: CGRect(x: x - 13, y: 42, width: 26, height: 26), cornerRadius: 7), with: .color(i == 0 ? Theme.sambal : Theme.kopi))
            c.stroke(Path(ellipseIn: CGRect(x: x + (i == 0 ? 9 : -19), y: 47, width: 10, height: 12)), with: .color(i == 0 ? Theme.sambal : Theme.kopi), lineWidth: 4)
        }
        c.fill(Path(roundedRect: CGRect(x: 10, y: 70, width: 80, height: 5), cornerRadius: 2.5), with: .color(Color(hex: 0x8A5E3F)))
    }

    // 8 · Makan — a bowl of rice with a chilli on top
    private func bowl(_ c: inout GraphicsContext) {
        for (i, x) in [36.0, 50, 64].enumerated() {
            var steam = Path()
            steam.move(to: CGPoint(x: x, y: 34))
            steam.addQuadCurve(to: CGPoint(x: x, y: 18), control: CGPoint(x: x + (i == 1 ? -7 : 7), y: 26))
            c.stroke(steam, with: .color(.white), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
        }
        c.fill(Path(ellipseIn: CGRect(x: 24, y: 34, width: 52, height: 22)), with: .color(Theme.card))
        var chilli = Path()
        chilli.move(to: CGPoint(x: 44, y: 42))
        chilli.addQuadCurve(to: CGPoint(x: 62, y: 38), control: CGPoint(x: 54, y: 46))
        c.stroke(chilli, with: .color(Theme.sambal), style: StrokeStyle(lineWidth: 6, lineCap: .round))
        var bowl = Path()
        bowl.move(to: CGPoint(x: 18, y: 46))
        bowl.addLine(to: CGPoint(x: 82, y: 46))
        bowl.addQuadCurve(to: CGPoint(x: 18, y: 46), control: CGPoint(x: 50, y: 96))
        c.fill(bowl, with: .color(Theme.sambal))
        c.fill(Path(roundedRect: CGRect(x: 14, y: 43, width: 72, height: 7), cornerRadius: 3.5), with: .color(Theme.sambal.darker(0.18)))
        for i in 0..<3 {
            c.fill(Path(ellipseIn: CGRect(x: 34 + Double(i) * 12, y: 58, width: 7, height: 7)), with: .color(Theme.card.opacity(0.8)))
        }
    }

    // 9 · Jalan-jalan — a signpost pointing two ways
    private func signpost(_ c: inout GraphicsContext) {
        c.fill(Path(roundedRect: CGRect(x: 46, y: 22, width: 8, height: 62), cornerRadius: 3), with: .color(Color(hex: 0x8A5E3F)))
        var right = Path()
        right.addRoundedRect(in: CGRect(x: 30, y: 26, width: 44, height: 18), cornerSize: CGSize(width: 4, height: 4))
        right.move(to: CGPoint(x: 72, y: 26)); right.addLine(to: CGPoint(x: 84, y: 35)); right.addLine(to: CGPoint(x: 72, y: 44))
        c.fill(right, with: .color(Theme.indigo))
        var left = Path()
        left.addRoundedRect(in: CGRect(x: 28, y: 50, width: 42, height: 18), cornerSize: CGSize(width: 4, height: 4))
        left.move(to: CGPoint(x: 30, y: 50)); left.addLine(to: CGPoint(x: 18, y: 59)); left.addLine(to: CGPoint(x: 30, y: 68))
        c.fill(left, with: .color(Theme.kunyit))
        c.fill(Path(roundedRect: CGRect(x: 10, y: 82, width: 80, height: 6), cornerRadius: 3), with: .color(Theme.sawah))
    }

    // 10 · Budaya — a frangipani flower
    private func frangipani(_ c: inout GraphicsContext) {
        for i in 0..<5 {
            var petal = c
            petal.translateBy(x: 50, y: 52)
            petal.rotate(by: .degrees(Double(i) * 72))
            let shape = Path(ellipseIn: CGRect(x: -9, y: -34, width: 18, height: 30))
            petal.fill(shape, with: .color(Theme.card))
            petal.stroke(shape, with: .color(Theme.kunyit.opacity(0.35)), lineWidth: 1.5)
        }
        c.fill(Path(ellipseIn: CGRect(x: 40, y: 42, width: 20, height: 20)), with: .color(Theme.kunyit))
    }

    // 11 · Sambung — three word blocks joined by a thread
    private func linked(_ c: inout GraphicsContext) {
        var thread = Path()
        thread.move(to: CGPoint(x: 22, y: 50))
        thread.addCurve(to: CGPoint(x: 78, y: 50), control1: CGPoint(x: 40, y: 30), control2: CGPoint(x: 60, y: 70))
        c.stroke(thread, with: .color(Theme.laut), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [6, 5]))
        for (i, color) in [Theme.indigo, Theme.kunyit, Theme.sambal].enumerated() {
            let center = CGPoint(x: 22 + Double(i) * 28, y: 50)
            let r = CGRect(x: center.x - 11, y: center.y - 11, width: 22, height: 22)
            c.fill(Path(roundedRect: r.offsetBy(dx: 0, dy: 3), cornerRadius: 6), with: .color(color.darker(0.25)))
            c.fill(Path(roundedRect: r, cornerRadius: 6), with: .color(color))
        }
    }

    private func bubble(_ c: inout GraphicsContext, color: Color) {
        var b = Path(roundedRect: CGRect(x: 18, y: 18, width: 64, height: 54), cornerRadius: 22)
        b.move(to: CGPoint(x: 32, y: 68)); b.addLine(to: CGPoint(x: 26, y: 84)); b.addLine(to: CGPoint(x: 46, y: 70))
        c.fill(b, with: .color(color))
    }

    private func face(_ c: inout GraphicsContext, at p: CGPoint) {
        for dx in [-8.0, 8.0] {
            c.fill(Path(ellipseIn: CGRect(x: p.x + dx - 3, y: p.y - 6, width: 6, height: 7)), with: .color(Theme.ink))
        }
        var smile = Path()
        smile.addArc(center: CGPoint(x: p.x, y: p.y + 2), radius: 9, startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false)
        c.stroke(smile, with: .color(Theme.ink), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
    }
}
