import SwiftUI

// Shared pieces for the animated place drawings: framing, sky, scenery and people.
// Every place is drawn in a 400×260 design space; `Illo.fit` scales it into any frame.

/// The visible region of the design space after fitting, in design units.
struct IlloFrame {
    let left: Double
    let width: Double
    let top: Double
    let bottomY: Double

    var right: Double { left + width }
}

/// A place drawing. Implementations draw into an already-fitted context.
protocol PlaceDrawing {
    func draw(_ ctx: inout GraphicsContext, frame: IlloFrame, t: Double)
}

/// Hosts a `PlaceDrawing` in a Canvas driven by a TimelineView. Animation pauses when the view
/// is off screen, under Reduce Motion, or when `still` is set.
struct IllustrationCanvas<Drawing: PlaceDrawing>: View {
    let drawing: Drawing
    var groundPad: CGFloat = 0
    var fps: Double = 30
    var still: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var onScreen = false

    private var paused: Bool { still || reduceMotion || !onScreen || scenePhase != .active }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / fps, paused: paused)) { timeline in
            // A fixed, pleasant moment when paused, so still frames still look composed.
            let t = paused ? 2.2 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let frame = Illo.fit(&ctx, size: size, groundPad: groundPad)
                drawing.draw(&ctx, frame: frame, t: t)
            }
        }
        .onAppear { onScreen = true }
        .onDisappear { onScreen = false }
    }
}

enum Illo {
    // MARK: Framing

    /// Fit the main subject (y≈34…246) into the frame; extra width or height extends the scenery
    /// so nothing is ever awkwardly cropped.
    static func fit(_ ctx: inout GraphicsContext, size: CGSize, groundPad: CGFloat) -> IlloFrame {
        let s = min(size.width / 400, max(1, size.height - groundPad) / 212)
        let visW = size.width / s, visH = size.height / s
        let dx = (visW - 400) / 2
        let bottomY: Double = (visH - groundPad / s >= 262 ? 262 : 246) + groundPad / s
        let topY = bottomY - visH
        ctx.scaleBy(x: s, y: s)
        ctx.translateBy(x: dx, y: -topY)
        return IlloFrame(left: -dx - 10, width: visW + 20, top: topY - 10, bottomY: bottomY)
    }

    // MARK: Scenery

    static func sky(_ ctx: inout GraphicsContext, _ f: IlloFrame, top: Color, bottom: Color) {
        ctx.fill(Path(CGRect(x: f.left, y: f.top, width: f.width, height: 280 - f.top)),
                 with: .linearGradient(Gradient(colors: [top, bottom]),
                                       startPoint: CGPoint(x: 0, y: min(f.top, 0)), endPoint: CGPoint(x: 0, y: 220)))
    }

    static func sun(_ ctx: inout GraphicsContext, t: Double, center c: CGPoint, color: Color = Theme.kunyit) {
        var rays = Path()
        let spin = t * 0.15
        for i in 0..<12 {
            let a = spin + Double(i) / 12 * 2 * .pi
            let r1 = 30.0
            let r2 = 37.0 + 3 * sin(t * 1.4 + Double(i))
            rays.move(to: CGPoint(x: c.x + cos(a) * r1, y: c.y + sin(a) * r1))
            rays.addLine(to: CGPoint(x: c.x + cos(a) * r2, y: c.y + sin(a) * r2))
        }
        ctx.stroke(rays, with: .color(color.opacity(0.55)), style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
        ctx.fill(Path(ellipseIn: CGRect(x: c.x - 34, y: c.y - 34, width: 68, height: 68)), with: .color(color.opacity(0.18)))
        ctx.fill(Path(ellipseIn: CGRect(x: c.x - 24, y: c.y - 24, width: 48, height: 48)), with: .color(color))
    }

    static func clouds(_ ctx: inout GraphicsContext, _ f: IlloFrame, t: Double, count: Int = 2, color: Color = .white) {
        let specs: [(y: Double, speed: Double, offset: Double, scale: Double)] =
            [(34, 5, 40, 1.0), (70, 3.2, 260, 0.75), (22, 2.4, 160, 0.6)]
        for spec in specs.prefix(count) {
            let span = f.width + 120
            let x = f.left + (spec.offset + t * spec.speed).truncatingRemainder(dividingBy: span) - 70
            let k = spec.scale
            var cloud = Path()
            cloud.addEllipse(in: CGRect(x: x, y: spec.y, width: 44 * k, height: 18 * k))
            cloud.addEllipse(in: CGRect(x: x + 14 * k, y: spec.y - 10 * k, width: 30 * k, height: 24 * k))
            cloud.addEllipse(in: CGRect(x: x + 28 * k, y: spec.y - 3 * k, width: 34 * k, height: 20 * k))
            ctx.fill(cloud, with: .color(color.opacity(0.85)))
        }
    }

    /// Two layered green hills with rice-terrace lines.
    static func hills(_ ctx: inout GraphicsContext, _ f: IlloFrame, base: Double = 176, color: Color = Theme.sawah) {
        for (i, layer) in [(y: base, amp: 12.0, alpha: 0.28), (y: base + 20, amp: 9.0, alpha: 0.45)].enumerated() {
            var p = Path()
            p.move(to: CGPoint(x: f.left, y: 240))
            for x in stride(from: f.left, through: f.right, by: 10) {
                p.addLine(to: CGPoint(x: x, y: layer.y + sin(x / 60 + Double(i) * 1.7) * layer.amp + sin(x / 23) * 2))
            }
            p.addLine(to: CGPoint(x: f.right, y: 240))
            p.closeSubpath()
            ctx.fill(p, with: .color(color.opacity(layer.alpha)))
        }
        var lines = Path()
        for row in 0..<3 {
            let y0 = base + 28 + Double(row) * 7
            lines.move(to: CGPoint(x: f.left, y: y0 + sin(f.left / 60 + 1.7) * 6))
            for x in stride(from: f.left, through: f.right, by: 10) {
                lines.addLine(to: CGPoint(x: x, y: y0 + sin(x / 60 + 1.7) * 6))
            }
        }
        ctx.stroke(lines, with: .color(color.opacity(0.25)), lineWidth: 1)
    }

    static func ground(_ ctx: inout GraphicsContext, _ f: IlloFrame, y: Double = 228, color: Color, pebbles: Color? = nil) {
        ctx.fill(Path(CGRect(x: f.left, y: y, width: f.width, height: max(40, f.bottomY - y + 10))), with: .color(color))
        guard let pebbles else { return }
        var p = Path()
        for (x, py) in [(30.0, 240.0), (78, 250), (150, 244), (250, 252), (330, 242), (385, 254), (205, 238)] {
            p.addEllipse(in: CGRect(x: x, y: py, width: 4, height: 2.4))
        }
        ctx.fill(p, with: .color(pebbles))
    }

    static func palm(_ ctx: inout GraphicsContext, t: Double, base: CGPoint, height: Double = 150, phase: Double = 0) {
        let trunkColor = Color(hex: 0x6F4E37)
        let sway = sin(t * 0.9 + phase) * 4
        let topPt = CGPoint(x: base.x - 18 + sway, y: base.y - height)
        let ctrl = CGPoint(x: base.x + 12, y: base.y - height * 0.53)
        var trunk = Path()
        trunk.move(to: base)
        trunk.addQuadCurve(to: topPt, control: ctrl)
        ctx.stroke(trunk, with: .color(trunkColor), style: StrokeStyle(lineWidth: 7, lineCap: .round))
        for i in 1..<8 {
            let p = quad(base, ctrl, topPt, Double(i) / 8)
            var ring = Path()
            ring.move(to: CGPoint(x: p.x - 3.5, y: p.y))
            ring.addLine(to: CGPoint(x: p.x + 3.5, y: p.y))
            ctx.stroke(ring, with: .color(Color(hex: 0x8A5E3F).opacity(0.7)), lineWidth: 1)
        }
        for i in 0..<7 {
            let a = -Double.pi + Double(i) / 6 * Double.pi + sin(t * 1.3 + Double(i) + phase) * 0.06
            let len = 52.0 + Double(i % 2) * 10
            let end = CGPoint(x: topPt.x + cos(a) * len, y: topPt.y + sin(a) * len * 0.55 + 18)
            let c = CGPoint(x: topPt.x + cos(a) * len * 0.5, y: topPt.y + sin(a) * len * 0.5 - 14)
            var leaf = Path()
            leaf.move(to: topPt)
            leaf.addQuadCurve(to: end, control: c)
            ctx.stroke(leaf, with: .color(Theme.sawah), style: StrokeStyle(lineWidth: 7, lineCap: .round))
            ctx.stroke(leaf, with: .color(Theme.sawah.lighter(0.25)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
        }
    }

    /// Point on a quadratic Bézier.
    static func quad(_ a: CGPoint, _ c: CGPoint, _ b: CGPoint, _ f: Double) -> CGPoint {
        CGPoint(x: (1 - f) * (1 - f) * a.x + 2 * (1 - f) * f * c.x + f * f * b.x,
                y: (1 - f) * (1 - f) * a.y + 2 * (1 - f) * f * c.y + f * f * b.y)
    }

    /// A string of pennants between two points, fluttering.
    static func bunting(_ ctx: inout GraphicsContext, from a: CGPoint, to b: CGPoint, sag: Double, t: Double, colors: [Color]) {
        let c = CGPoint(x: (a.x + b.x) / 2, y: max(a.y, b.y) + sag)
        var line = Path()
        line.move(to: a)
        line.addQuadCurve(to: b, control: c)
        ctx.stroke(line, with: .color(Color(hex: 0x6F4E37).opacity(0.6)), lineWidth: 1)
        let n = 11
        for i in 1..<n {
            let f = Double(i) / Double(n)
            let p = quad(a, c, b, f)
            let flap = sin(t * 2.2 + Double(i) * 0.8) * 2
            var tri = Path()
            tri.move(to: CGPoint(x: p.x - 5, y: p.y))
            tri.addLine(to: CGPoint(x: p.x + 5, y: p.y))
            tri.addLine(to: CGPoint(x: p.x + flap, y: p.y + 11))
            tri.closeSubpath()
            ctx.fill(tri, with: .color(colors[i % colors.count]))
        }
    }

    /// Steam or smoke puffs rising from a point, looping.
    static func puffs(_ ctx: inout GraphicsContext, from base: CGPoint, t: Double, rate: Double = 0.45,
                      rise: Double = 58, drift: Double = 0, color: Color = .white, count: Int = 4) {
        for i in 0..<count {
            let p = (t * rate + Double(i) / Double(count)).truncatingRemainder(dividingBy: 1)
            let y = base.y - p * rise
            let x = base.x + sin(p * 6 + Double(i)) * 5 + drift * p
            let r = 3 + p * 6
            ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                     with: .color(color.opacity((1 - p) * 0.7)))
        }
    }

    /// A small bird that bobs and occasionally hops.
    static func bird(_ ctx: inout GraphicsContext, at p: CGPoint, t: Double, color: Color = Color(hex: 0x5B5E66), phase: Double = 0) {
        let peck = max(0, sin(t * 2.6 + phase)) > 0.92 ? 3.0 : 0
        let hop = max(0, sin(t * 0.7 + phase)) > 0.97 ? -4.0 : 0
        let y = p.y + hop
        ctx.fill(Path(ellipseIn: CGRect(x: p.x - 6, y: y - 4, width: 12, height: 8)), with: .color(color))
        ctx.fill(Path(ellipseIn: CGRect(x: p.x + 3, y: y - 8 + peck, width: 6, height: 6)), with: .color(color))
        var beak = Path()
        beak.move(to: CGPoint(x: p.x + 9, y: y - 5 + peck))
        beak.addLine(to: CGPoint(x: p.x + 12, y: y - 4 + peck))
        beak.addLine(to: CGPoint(x: p.x + 9, y: y - 3.5 + peck))
        ctx.fill(beak, with: .color(Theme.kunyit))
        var tail = Path()
        tail.move(to: CGPoint(x: p.x - 5, y: y - 1))
        tail.addLine(to: CGPoint(x: p.x - 10, y: y - 4))
        tail.addLine(to: CGPoint(x: p.x - 9, y: y + 1))
        ctx.fill(tail, with: .color(color))
    }
}

// MARK: - People

/// How to draw one character. Everyone shares the same friendly editorial build.
struct Figure {
    enum Hair {
        case bun(flower: Color)
        case short
        case hijab(Color)
        case helmet(Color)
        /// A Balinese udeng: a cloth headband tied with a peak at the front.
        case udeng(Color)
        /// Shoulder-length hair in `hairColor`.
        case long
        /// A wide straw sun hat over short hair.
        case hat(Color)
    }

    enum Lower {
        case hidden                     // behind a counter or table
        case sarong(Color)              // standing, full length
    }

    var skin: Color = Color(hex: 0xC48A5C)
    var hair: Hair
    var outfit: Color
    var trim: Color = Theme.kunyit
    var collar: Collar = .vNeck
    var lower: Lower = .hidden
    var hairColor: Color = Theme.ink

    enum Collar { case vNeck, crew, jacket }

    /// Draws the figure with the head centred at `head`. The body hangs below it.
    func draw(_ ctx: inout GraphicsContext, head: CGPoint, t: Double, speaking: Bool,
              expression: CharacterExpression, pace: Double = 1, gesture: Gesture = .wave, arms: Bool = true) {
        let bob = sin(t * 1.6 * pace) * 1.2 + (expression == .happy ? -abs(sin(t * 6)) * 2 : 0)
        var c = ctx
        c.translateBy(x: 0, y: bob)
        let cx = head.x
        let bodyTop = head.y + 22

        // Lower body first, so the torso overlaps it.
        if case .sarong(let color) = lower {
            var skirt = Path()
            skirt.move(to: CGPoint(x: cx - 22, y: bodyTop + 34))
            skirt.addLine(to: CGPoint(x: cx + 22, y: bodyTop + 34))
            skirt.addLine(to: CGPoint(x: cx + 18, y: bodyTop + 88))
            skirt.addLine(to: CGPoint(x: cx - 18, y: bodyTop + 88))
            skirt.closeSubpath()
            c.fill(skirt, with: .color(color))
            for i in 0..<3 {
                Kawung.draw(in: c, center: CGPoint(x: cx - 10 + Double(i) * 10, y: bodyTop + 60 + Double(i % 2) * 12),
                            size: 8, color: .white.opacity(0.45), filled: false, lineWidth: 0.8)
            }
            for dx in [-9.0, 9.0] {
                c.fill(Path(ellipseIn: CGRect(x: cx + dx - 6, y: bodyTop + 86, width: 12, height: 5)), with: .color(Color(hex: 0x3A2A20)))
            }
        }

        // Torso
        let body = Path(roundedRect: CGRect(x: cx - 26, y: bodyTop, width: 52, height: 40), cornerRadius: 16)
        c.fill(body, with: .color(outfit))
        switch collar {
        case .vNeck:
            var lace = Path()
            lace.move(to: CGPoint(x: cx - 10, y: bodyTop + 2))
            lace.addLine(to: CGPoint(x: cx, y: bodyTop + 16))
            lace.addLine(to: CGPoint(x: cx + 10, y: bodyTop + 2))
            c.stroke(lace, with: .color(.white.opacity(0.75)), lineWidth: 2)
            c.fill(Path(CGRect(x: cx - 26, y: bodyTop + 18, width: 52, height: 5)), with: .color(trim))
        case .crew:
            var neckline = Path()
            neckline.addArc(center: CGPoint(x: cx, y: bodyTop), radius: 7, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
            c.stroke(neckline, with: .color(.white.opacity(0.6)), lineWidth: 2)
            c.fill(Path(roundedRect: CGRect(x: cx + 6, y: bodyTop + 12, width: 10, height: 8), cornerRadius: 2), with: .color(trim.opacity(0.8)))
        case .jacket:
            var zip = Path()
            zip.move(to: CGPoint(x: cx, y: bodyTop + 2))
            zip.addLine(to: CGPoint(x: cx, y: bodyTop + 40))
            c.stroke(zip, with: .color(.black.opacity(0.25)), lineWidth: 1.5)
            c.fill(Path(CGRect(x: cx - 26, y: bodyTop + 24, width: 52, height: 4)), with: .color(trim))
            c.fill(Path(roundedRect: CGRect(x: cx - 9, y: bodyTop - 2, width: 18, height: 7), cornerRadius: 3), with: .color(outfit.darker(0.15)))
        }

        // Neck + head
        c.fill(Path(CGRect(x: cx - 5, y: head.y + 14, width: 10, height: 10)), with: .color(skin.darker(0.08)))
        hairBack(&c, head: head)
        c.fill(Path(ellipseIn: CGRect(x: head.x - 17, y: head.y - 18, width: 34, height: 36)), with: .color(skin))
        hairFront(&c, head: head, t: t)
        face(&c, head: head, t: t, speaking: speaking, expression: expression)

        // Reaction marks
        switch expression {
        case .confused:
            let pop = 1 + 0.08 * sin(t * 5)
            c.draw(Text("?").font(.system(size: 20 * pop, weight: .heavy, design: .rounded)).foregroundColor(Theme.jambu),
                   at: CGPoint(x: cx + 26, y: head.y - 26 + sin(t * 3) * 2))
        case .happy:
            for i in 0..<3 {
                let a = t * 2 + Double(i) * 2.1
                Kawung.draw(in: c, center: CGPoint(x: cx + cos(a) * 30, y: head.y - 18 + sin(a) * 10),
                            size: 7 + 2 * sin(t * 4 + Double(i)), color: Theme.kunyit, filled: true)
            }
        case .neutral:
            break
        }

        // Arm: waves while talking, otherwise does the gesture.
        let armColor = outfit.darker(0.05)
        if !arms {
            // Portraits: no arms, so nothing crosses the face.
        } else if speaking || expression == .confused {
            let wave = sin(t * 7) * 0.35
            var arm = c
            arm.translateBy(x: cx + 22, y: bodyTop + 8)
            arm.rotate(by: .radians(-0.9 + (speaking ? wave : 0.25)))
            arm.fill(Path(roundedRect: CGRect(x: -4, y: -24, width: 8, height: 24), cornerRadius: 4), with: .color(armColor))
            arm.fill(Path(ellipseIn: CGRect(x: -5, y: -31, width: 10, height: 10)), with: .color(skin))
        } else {
            switch gesture {
            case .wave, .rest:
                break
            case .holding(let point, let item):
                // Forearm reaching to a point, with the item drawn by the caller.
                var arm = Path()
                arm.move(to: CGPoint(x: cx + 20, y: bodyTop + 12))
                arm.addQuadCurve(to: point, control: CGPoint(x: cx + 30, y: bodyTop + 30))
                c.stroke(arm, with: .color(armColor), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                c.fill(Path(ellipseIn: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10)), with: .color(skin))
                item(&c, point)
            }
        }
    }

    enum Gesture {
        case wave
        case rest
        case holding(CGPoint, (inout GraphicsContext, CGPoint) -> Void)
    }

    private func hairBack(_ c: inout GraphicsContext, head: CGPoint) {
        switch hair {
        case .bun(let flower):
            c.fill(Path(ellipseIn: CGRect(x: head.x - 11, y: head.y - 28, width: 22, height: 18)), with: .color(hairColor))
            c.fill(Path(ellipseIn: CGRect(x: head.x - 6, y: head.y - 25, width: 4, height: 4)), with: .color(flower))
        case .hijab(let color):
            var drape = Path()
            drape.addEllipse(in: CGRect(x: head.x - 22, y: head.y - 23, width: 44, height: 46))
            drape.addRoundedRect(in: CGRect(x: head.x - 24, y: head.y + 6, width: 48, height: 26), cornerSize: CGSize(width: 14, height: 14))
            c.fill(drape, with: .color(color))
        case .long:
            var back = Path()
            back.addRoundedRect(in: CGRect(x: head.x - 21, y: head.y - 14, width: 42, height: 40), cornerSize: CGSize(width: 16, height: 16))
            c.fill(back, with: .color(hairColor))
        case .short, .helmet, .udeng, .hat:
            break
        }
    }

    private func hairFront(_ c: inout GraphicsContext, head: CGPoint, t: Double) {
        switch hair {
        case .bun:
            var top = Path()
            top.addArc(center: CGPoint(x: head.x, y: head.y - 2), radius: 17.5, startAngle: .degrees(196), endAngle: .degrees(344), clockwise: false)
            top.addQuadCurve(to: CGPoint(x: head.x - 16.8, y: head.y - 6.8), control: CGPoint(x: head.x, y: head.y - 10))
            c.fill(top, with: .color(hairColor))
        case .short:
            var top = Path()
            top.addArc(center: CGPoint(x: head.x, y: head.y - 3), radius: 18, startAngle: .degrees(190), endAngle: .degrees(350), clockwise: false)
            top.addLine(to: CGPoint(x: head.x + 12, y: head.y - 9))
            top.addQuadCurve(to: CGPoint(x: head.x - 6, y: head.y - 11), control: CGPoint(x: head.x + 4, y: head.y - 6))
            top.addQuadCurve(to: CGPoint(x: head.x - 17.7, y: head.y - 6), control: CGPoint(x: head.x - 12, y: head.y - 9))
            c.fill(top, with: .color(hairColor))
        case .long:
            var fringe = Path()
            fringe.addArc(center: CGPoint(x: head.x, y: head.y - 2), radius: 18.5, startAngle: .degrees(186), endAngle: .degrees(354), clockwise: false)
            fringe.addQuadCurve(to: CGPoint(x: head.x + 2, y: head.y - 9), control: CGPoint(x: head.x + 12, y: head.y - 10))
            fringe.addQuadCurve(to: CGPoint(x: head.x - 18.4, y: head.y - 3.9), control: CGPoint(x: head.x - 10, y: head.y - 4))
            c.fill(fringe, with: .color(hairColor))
        case .hat(let color):
            var crown = Path()
            crown.addArc(center: CGPoint(x: head.x, y: head.y - 8), radius: 15, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            crown.closeSubpath()
            c.fill(crown, with: .color(color))
            c.fill(Path(CGRect(x: head.x - 15, y: head.y - 12, width: 30, height: 3.5)), with: .color(color.darker(0.25)))
            c.fill(Path(ellipseIn: CGRect(x: head.x - 30, y: head.y - 11, width: 60, height: 10)), with: .color(color.darker(0.06)))
        case .hijab(let color):
            var band = Path()
            band.addArc(center: CGPoint(x: head.x, y: head.y), radius: 19, startAngle: .degrees(185), endAngle: .degrees(355), clockwise: false)
            band.addQuadCurve(to: CGPoint(x: head.x - 18.9, y: head.y - 1.6), control: CGPoint(x: head.x, y: head.y - 13))
            c.fill(band, with: .color(color))
            c.stroke(band, with: .color(color.darker(0.12)), lineWidth: 0.8)
        case .udeng(let color):
            var cap = Path()
            cap.addArc(center: CGPoint(x: head.x, y: head.y - 3), radius: 18.5, startAngle: .degrees(185), endAngle: .degrees(355), clockwise: false)
            cap.addQuadCurve(to: CGPoint(x: head.x - 18.4, y: head.y - 4.6), control: CGPoint(x: head.x, y: head.y - 9))
            c.fill(cap, with: .color(color))
            var band = Path()
            band.move(to: CGPoint(x: head.x - 17.5, y: head.y - 7))
            band.addQuadCurve(to: CGPoint(x: head.x + 17.5, y: head.y - 7), control: CGPoint(x: head.x, y: head.y - 12))
            c.stroke(band, with: .color(Theme.kunyit), lineWidth: 1.6)
            var peak = Path()
            peak.move(to: CGPoint(x: head.x - 4, y: head.y - 14))
            peak.addQuadCurve(to: CGPoint(x: head.x + 2, y: head.y - 30), control: CGPoint(x: head.x - 5, y: head.y - 24))
            peak.addQuadCurve(to: CGPoint(x: head.x + 7, y: head.y - 14), control: CGPoint(x: head.x + 6, y: head.y - 22))
            peak.closeSubpath()
            c.fill(peak, with: .color(color.darker(0.08)))
            c.stroke(peak, with: .color(Theme.kunyit.opacity(0.7)), lineWidth: 0.8)
        case .helmet(let color):
            var shell = Path()
            shell.addArc(center: CGPoint(x: head.x, y: head.y - 2), radius: 21, startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
            shell.closeSubpath()
            c.fill(shell, with: .color(color))
            c.fill(Path(roundedRect: CGRect(x: head.x - 22, y: head.y - 4, width: 44, height: 5), cornerRadius: 2.5), with: .color(color.darker(0.2)))
            c.fill(Path(roundedRect: CGRect(x: head.x - 9, y: head.y - 19, width: 18, height: 6), cornerRadius: 3), with: .color(.white.opacity(0.35)))
        }
    }

    private func face(_ c: inout GraphicsContext, head: CGPoint, t: Double, speaking: Bool, expression: CharacterExpression) {
        let blink = t.truncatingRemainder(dividingBy: 4.3) < 0.13 ? 0.15 : 1.0
        let eyeY = head.y + 1
        for dx in [-6.5, 6.5] {
            if expression == .happy {
                var e = Path()
                e.addArc(center: CGPoint(x: head.x + dx, y: eyeY + 1.5), radius: 2.6, startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
                c.stroke(e, with: .color(Theme.ink), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            } else {
                c.fill(Path(ellipseIn: CGRect(x: head.x + dx - 2, y: eyeY - 2.4 * blink, width: 4, height: 4.8 * blink)), with: .color(Theme.ink))
            }
        }
        var brows = Path()
        let tilt = expression == .confused ? 2.5 : 0
        brows.move(to: CGPoint(x: head.x - 10, y: eyeY - 6 + tilt)); brows.addLine(to: CGPoint(x: head.x - 3.5, y: eyeY - 7 - tilt))
        brows.move(to: CGPoint(x: head.x + 3.5, y: eyeY - 7)); brows.addLine(to: CGPoint(x: head.x + 10, y: eyeY - 6))
        c.stroke(brows, with: .color(Theme.ink.opacity(0.75)), style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
        for dx in [-10.0, 10.0] {
            c.fill(Path(ellipseIn: CGRect(x: head.x + dx - 3.5, y: eyeY + 4, width: 7, height: 4)), with: .color(Theme.jambu.opacity(0.28)))
        }
        let m = CGPoint(x: head.x, y: head.y + 10)
        let lip = Color(hex: 0x7A2E1E)
        if speaking {
            let open = 1.2 + abs(sin(t * 13)) * 3.2
            c.fill(Path(ellipseIn: CGRect(x: m.x - 3.5, y: m.y - open / 2, width: 7, height: open)), with: .color(lip))
        } else if expression == .confused {
            var p = Path()
            p.move(to: CGPoint(x: m.x - 4, y: m.y + 1))
            p.addQuadCurve(to: CGPoint(x: m.x + 4, y: m.y - 1), control: CGPoint(x: m.x, y: m.y - 2))
            c.stroke(p, with: .color(lip), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
        } else {
            let w = expression == .happy ? 6.0 : 4.0
            var p = Path()
            p.move(to: CGPoint(x: m.x - w, y: m.y - 1))
            p.addQuadCurve(to: CGPoint(x: m.x + w, y: m.y - 1), control: CGPoint(x: m.x, y: m.y + (expression == .happy ? 5 : 3)))
            c.stroke(p, with: .color(lip), style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
        }
    }
}
