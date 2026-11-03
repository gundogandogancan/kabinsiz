import CoreGraphics
import CoreImage
import CoreText
import Foundation

/// Draws a fictional shop label (barcode + printed code) for tests and the DEBUG UI-test fixture.
/// It is synthetic test data and says so on the label; it is never shown as a real product photo.
public enum SyntheticLabel {
    public enum Symbol: Sendable {
        case code128(String)
        /// EAN-13 from 12 digits (the check digit is computed) or 13 digits.
        case ean13(String)
        case qr(String)
        case none
    }

    /// A white label: optional barcode on top, then each text line. `rotation` is in degrees, to test a
    /// photo taken slightly off-axis.
    public static func render(_ symbol: Symbol, lines: [String], width: Int = 1200, height: Int = 800,
                              rotation: Double = 0) -> CGImage? {
        guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        // A beige "table" behind the label, so the label has an edge like in a photo.
        ctx.setFillColor(CGColor(srgbRed: 0.80, green: 0.75, blue: 0.68, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        ctx.translateBy(x: CGFloat(width) / 2, y: CGFloat(height) / 2)
        ctx.rotate(by: rotation * .pi / 180)
        ctx.translateBy(x: -CGFloat(width) / 2, y: -CGFloat(height) / 2)
        let label = CGRect(x: 60, y: 50, width: width - 120, height: height - 100)
        ctx.setFillColor(CGColor(gray: 1, alpha: 1))
        ctx.fill(label)

        var top = label.maxY - 40
        if let bars = barcode(symbol) {
            let w = min(label.width - 120, CGFloat(bars.width) * 4)
            let h = symbolIsSquare(symbol) ? w.clamped(max: 300) : 220
            let rect = CGRect(x: label.midX - (symbolIsSquare(symbol) ? h : w) / 2, y: top - h,
                              width: symbolIsSquare(symbol) ? h : w, height: h)
            ctx.interpolationQuality = .none
            ctx.draw(bars, in: rect)
            top = rect.minY - 30
        }
        for (i, line) in lines.enumerated() {
            let size: CGFloat = i == 0 ? 64 : 34
            draw(line, size: size, in: ctx, centeredAt: label.midX, baseline: top - size)
            top -= size * 1.45
        }
        return ctx.makeImage()
    }

    /// A photo with no label at all (a plain garment-coloured shape): nothing can be read from it.
    public static func plainGarment() -> CGImage? {
        guard let ctx = CGContext(data: nil, width: 900, height: 900, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        ctx.setFillColor(CGColor(srgbRed: 0.93, green: 0.92, blue: 0.90, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: 900, height: 900))
        ctx.setFillColor(CGColor(srgbRed: 0.16, green: 0.22, blue: 0.36, alpha: 1))
        let body = CGMutablePath()
        body.addLines(between: [CGPoint(x: 250, y: 120), CGPoint(x: 650, y: 120), CGPoint(x: 650, y: 600),
                                CGPoint(x: 800, y: 520), CGPoint(x: 860, y: 640), CGPoint(x: 620, y: 780),
                                CGPoint(x: 280, y: 780), CGPoint(x: 40, y: 640), CGPoint(x: 100, y: 520), CGPoint(x: 250, y: 600)])
        body.closeSubpath()
        ctx.addPath(body)
        ctx.fillPath()
        return ctx.makeImage()
    }

    /// PNG bytes, for the code paths that start from photo data.
    public static func png(_ image: CGImage) -> Data? {
        let data = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(data, "public.png" as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(dest, image, nil)
        return CGImageDestinationFinalize(dest) ? data as Data : nil
    }

    // MARK: Symbols

    static func symbolIsSquare(_ symbol: Symbol) -> Bool {
        if case .qr = symbol { return true }
        return false
    }

    static func barcode(_ symbol: Symbol) -> CGImage? {
        switch symbol {
        case let .code128(text): ciCode("CICode128BarcodeGenerator", message: text, extra: ["inputQuietSpace": 10])
        case let .qr(text): ciCode("CIQRCodeGenerator", message: text, extra: ["inputCorrectionLevel": "M"])
        case let .ean13(digits): ean13(digits)
        case .none: nil
        }
    }

    static func ciCode(_ name: String, message: String, extra: [String: Any]) -> CGImage? {
        guard let filter = CIFilter(name: name), let data = message.data(using: .ascii) else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        for (key, value) in extra { filter.setValue(value, forKey: key) }
        guard let output = filter.outputImage else { return nil }
        return CIContext(options: [.useSoftwareRenderer: true]).createCGImage(output, from: output.extent)
    }

    /// EAN-13 drawn from the GS1 tables (CoreImage has no EAN generator). One module = one pixel.
    static func ean13(_ raw: String) -> CGImage? {
        var digits = raw.compactMap(\.wholeNumberValue)
        guard raw.count == digits.count, digits.count == 12 || digits.count == 13 else { return nil }
        if digits.count == 12 {
            var sum = 0
            for (i, d) in digits.reversed().enumerated() { sum += d * (i.isMultiple(of: 2) ? 3 : 1) }
            digits.append((10 - sum % 10) % 10)
        }
        let l = ["0001101", "0011001", "0010011", "0111101", "0100011", "0110001", "0101111", "0111011", "0110111", "0001011"]
        let g = ["0100111", "0110011", "0011011", "0100001", "0011101", "0111001", "0000101", "0010001", "0001001", "0010111"]
        let r = ["1110010", "1100110", "1101100", "1000010", "1011100", "1001110", "1010000", "1000100", "1001000", "1110100"]
        let parity = ["LLLLLL", "LLGLGG", "LLGGLG", "LLGGGL", "LGLLGG", "LGGLLG", "LGGGLL", "LGLGLG", "LGLGGL", "LGGLGL"]
        var bits = String(repeating: "0", count: 11) + "101"
        for (i, kind) in parity[digits[0]].enumerated() { bits += kind == "L" ? l[digits[i + 1]] : g[digits[i + 1]] }
        bits += "01010"
        for d in digits[7...12] { bits += r[d] }
        bits += "101" + String(repeating: "0", count: 11)
        let width = bits.count, height = 60
        guard let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return nil }
        ctx.setFillColor(gray: 1, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        ctx.setFillColor(gray: 0, alpha: 1)
        for (x, bit) in bits.enumerated() where bit == "1" { ctx.fill(CGRect(x: x, y: 0, width: 1, height: height)) }
        return ctx.makeImage()
    }

    static func draw(_ text: String, size: CGFloat, in ctx: CGContext, centeredAt x: CGFloat, baseline y: CGFloat) {
        let font = CTFontCreateWithName("Helvetica-Bold" as CFString, size, nil)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): CGColor(gray: 0.05, alpha: 1),
        ]
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
        let width = CTLineGetTypographicBounds(line, nil, nil, nil)
        ctx.textPosition = CGPoint(x: x - width / 2, y: y)
        CTLineDraw(line, ctx)
    }
}

private extension CGFloat {
    func clamped(max upper: CGFloat) -> CGFloat { Swift.min(self, upper) }
}
