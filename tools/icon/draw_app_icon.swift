// Kabinsiz app icon, redrawn from the icon the user supplied (2026-11-03, second version): one copper
// ribbon that rises as the heavy stem of a "K", arches over and thins to a hairline down the right
// side of a recessed mirror; a fine blade for the K's arm; a fold of fabric for its leg, rising from
// the stem's foot and sweeping out to the right. Paper-cut relief on warm ivory. Vector paths, so
// every size is crisp. Coordinates are those of the 1254 px reference, mapped onto the 1024 tile.
// Usage: swift tools/icon/draw_app_icon.swift <out-dir>
import AppKit
import CoreGraphics

let size: CGFloat = 1024
let outDir = CommandLine.arguments.dropFirst().first ?? "."

func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}

func gradient(_ stops: [(UInt32, CGFloat)]) -> CGGradient {
    CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB), colors: stops.map { rgb($0.0) } as CFArray, locations: stops.map(\.1))!
}

func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

/// Arch: straight sides from `bottom` up to `spring`, a half circle over the top.
func arch(_ x0: CGFloat, _ x1: CGFloat, spring: CGFloat, bottom: CGFloat) -> CGMutablePath {
    let p = CGMutablePath()
    let r = (x1 - x0) / 2
    p.move(to: pt(x0, bottom))
    p.addLine(to: pt(x0, spring))
    p.addArc(center: pt(x0 + r, spring), radius: r, startAngle: .pi, endAngle: 0, clockwise: false)
    p.addLine(to: pt(x1, bottom))
    p.closeSubpath()
    return p
}

func fill(_ ctx: CGContext, _ path: CGPath, _ g: CGGradient, from a: CGPoint, to b: CGPoint, evenOdd: Bool = false) {
    ctx.saveGState()
    ctx.addPath(path)
    if evenOdd { ctx.clip(using: .evenOdd) } else { ctx.clip() }
    ctx.drawLinearGradient(g, start: a, end: b, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    ctx.restoreGState()
}

func draw(dark: Bool) -> CGImage {
    let ctx = CGContext(data: nil, width: Int(size), height: Int(size), bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    // y down, like a design canvas.
    ctx.translateBy(x: 0, y: size)
    ctx.scaleBy(x: 1, y: -1)

    // Ground: warm ivory paper lit from the top (light), or espresso (dark).
    let ground = dark ? gradient([(0x4A3428, 0), (0x2B1E18, 1)]) : gradient([(0xFFFAF2, 0), (0xF6EDE0, 0.6), (0xEBDDCB, 1)])
    ctx.drawRadialGradient(ground, startCenter: pt(512, 300), startRadius: 0, endCenter: pt(512, 512), endRadius: 820, options: [.drawsAfterEndLocation])

    // Reference px → tile px (the reference tile spans 70...1185).
    ctx.translateBy(x: -70 * 1024 / 1115, y: -70 * 1024 / 1115)
    ctx.scaleBy(x: 1024 / 1115, y: 1024 / 1115)
    // Nudge the mark to the optical centre of the tile.
    ctx.translateBy(x: -16, y: 18)

    let outer = arch(300, 918, spring: 504, bottom: 1010)
    // The mirror opening; its left side leaves the stem at the fold and runs to the stem's foot, so
    // the stem ends in a point under the fabric, as in the reference.
    let inner = CGMutablePath()
    inner.move(to: pt(300, 1010))
    inner.addLine(to: pt(437, 700))
    inner.addLine(to: pt(437, 449))
    inner.addArc(center: pt(671, 449), radius: 234, startAngle: .pi, endAngle: 0, clockwise: false)
    inner.addLine(to: pt(905, 1010))
    inner.closeSubpath()

    // Recessed mirror: a slightly deeper panel with an inner shadow along the top and left.
    ctx.saveGState()
    ctx.addPath(inner)
    ctx.clip()
    fill(ctx, inner, dark ? gradient([(0x463227, 0), (0x34251D, 1)]) : gradient([(0xF9F1E6, 0), (0xF1E5D5, 0.7), (0xEAD9C4, 1)]),
         from: pt(560, 215), to: pt(760, 1010))
    let lip = CGMutablePath()
    lip.addRect(CGRect(x: 0, y: 0, width: 1400, height: 1400))
    lip.addPath(inner)
    ctx.setShadow(offset: CGSize(width: 6, height: 10), blur: 22, color: rgb(dark ? 0x000000 : 0x7A5236, dark ? 0.6 : 0.30))
    ctx.addPath(lip)
    ctx.setFillColor(rgb(0x000000))
    ctx.fillPath(using: .evenOdd)
    ctx.restoreGState()

    // Soft drop shadow under every copper piece.
    func lifted(_ path: CGPath, blur: CGFloat = 26, y: CGFloat = 14, body: () -> Void) {
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: y), blur: blur, color: rgb(dark ? 0x000000 : 0x6B4A33, dark ? 0.55 : 0.30))
        ctx.addPath(path)
        ctx.setFillColor(rgb(0xB3714E))
        ctx.fillPath()
        ctx.restoreGState()
        body()
    }

    // The ribbon: outer arch minus the mirror, heavy on the left, a hairline on the right.
    let ribbon = CGMutablePath()
    ribbon.addPath(outer)
    ribbon.addPath(inner)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 14), blur: 26, color: rgb(dark ? 0x000000 : 0x6B4A33, dark ? 0.55 : 0.30))
    ctx.addPath(ribbon)
    ctx.setFillColor(rgb(0xB3714E))
    ctx.fillPath(using: .evenOdd)
    ctx.restoreGState()
    // Satin copper: light where the ribbon turns towards the light at the top, deep down the stem.
    fill(ctx, ribbon, gradient([(0xA4633C, 0), (0xC98A5C, 0.32), (0xDDA77A, 0.52), (0xB97848, 0.75), (0x9A5A33, 1)]),
         from: pt(300, 700), to: pt(918, 300), evenOdd: true)
    // The ribbon's turned edge: a thin lit line along the inside of the arch.
    ctx.saveGState()
    ctx.addPath(inner)
    ctx.setStrokeColor(rgb(0xF3D3B0, dark ? 0.5 : 0.75))
    ctx.setLineWidth(2.5)
    ctx.strokePath()
    ctx.restoreGState()

    // The arm: a fine blade from the upper right to the stem, bowed like cut silk.
    let blade = CGMutablePath()
    blade.move(to: pt(852, 367))
    blade.addQuadCurve(to: pt(468, 690), control: pt(640, 520))
    blade.addLine(to: pt(560, 688))
    blade.addQuadCurve(to: pt(852, 367), control: pt(730, 520))
    blade.closeSubpath()
    lifted(blade, blur: 18, y: 10) {
        fill(ctx, blade, gradient([(0xE2B385, 0), (0xC7895A, 0.55), (0xA9673F, 1)]), from: pt(840, 380), to: pt(500, 690))
    }

    // The leg: a fold of fabric. The inside of the fold first (in shadow), then the lit outer face.
    let back = CGMutablePath()
    back.move(to: pt(300, 1010))
    back.addCurve(to: pt(505, 680), control1: pt(360, 880), control2: pt(430, 700))
    back.addCurve(to: pt(600, 760), control1: pt(545, 668), control2: pt(575, 700))
    back.addCurve(to: pt(470, 880), control1: pt(560, 800), control2: pt(510, 840))
    back.addCurve(to: pt(300, 1010), control1: pt(400, 940), control2: pt(340, 990))
    back.closeSubpath()
    lifted(back, blur: 20, y: 10) {
        fill(ctx, back, gradient([(0x8E4F2E, 0), (0xB06E44, 0.6), (0xC7885A, 1)]), from: pt(330, 1000), to: pt(560, 700))
    }

    let face = CGMutablePath()
    face.move(to: pt(505, 680))
    face.addCurve(to: pt(990, 1005), control1: pt(600, 640), control2: pt(760, 960))
    face.addCurve(to: pt(760, 985), control1: pt(910, 1008), control2: pt(830, 1002))
    face.addCurve(to: pt(470, 880), control1: pt(640, 960), control2: pt(560, 860))
    face.addCurve(to: pt(600, 760), control1: pt(510, 840), control2: pt(560, 800))
    face.addCurve(to: pt(505, 680), control1: pt(575, 700), control2: pt(545, 668))
    face.closeSubpath()
    lifted(face, blur: 30, y: 16) {
        fill(ctx, face, gradient([(0xB6764B, 0), (0xD9A579, 0.3), (0xE9C39C, 0.5), (0xD29D72, 0.75), (0xB97A4E, 1)]),
             from: pt(480, 900), to: pt(900, 800))
    }
    return ctx.makeImage()!
}

func write(_ image: CGImage, _ name: String) {
    let rep = NSBitmapImageRep(cgImage: image)
    let data = rep.representation(using: .png, properties: [:])!
    try! data.write(to: URL(fileURLWithPath: outDir).appendingPathComponent(name))
    print("wrote", name)
}

write(draw(dark: false), "AppIcon-1024.png")
write(draw(dark: true), "AppIcon-1024-dark.png")
