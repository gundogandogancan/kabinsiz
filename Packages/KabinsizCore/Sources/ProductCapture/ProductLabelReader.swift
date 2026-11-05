import CoreGraphics
import CoreML
import Foundation
import ImageIO
import Vision

/// Reads a product photo (a label, a barcode, a tag) on this device with Vision: barcodes and text.
/// No network, no storage: the image is decoded, downsampled (which also drops EXIF and location),
/// read and released. The caller keeps only the codes.
public enum ProductLabelReader {
    /// Largest side after downsampling; enough for a label filling part of the frame.
    public static let maxPixelSize = 2048

    /// Retail and shop symbologies. 2D codes are read so a link inside one can be refused, not opened.
    static let symbologies: [VNBarcodeSymbology] = [.ean13, .ean8, .upce, .code128, .code39, .code93, .itf14, .qr, .dataMatrix, .pdf417]

    /// Decodes image data (HEIC/JPEG/PNG) into an upright, downsampled bitmap. Nil when it is not an image.
    public static func image(from data: Data) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceShouldCacheImmediately: true,
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }

    /// Runs barcode detection and text recognition off the main actor.
    public static func read(_ image: CGImage, orientation: CGImagePropertyOrientation = .up) async throws -> ProductLabelReading {
        // Off the cooperative pool: see `VisionLane`.
        try await VisionLane.run { try readNow(image, orientation: orientation) }
    }

    /// Barcodes and text are read separately so one failing detector does not lose the other. Vision may
    /// refuse the default compute device (no Neural Engine context: the simulator, a busy device); each
    /// request is then run once more on the CPU. Only when both fail is the photo reported as unread.
    static func readNow(_ image: CGImage, orientation: CGImagePropertyOrientation) throws -> ProductLabelReading {
        var failures: [Error] = []
        let codes: [ProductLabelReading.Barcode]?
        do { codes = try withCPUFallback { try detectBarcodes(image, orientation: orientation, cpuOnly: $0) } } catch {
            failures.append(error)
            codes = nil
        }
        let lines: [String]?
        do { lines = try withCPUFallback { try recognizeText(image, orientation: orientation, cpuOnly: $0) } } catch {
            failures.append(error)
            lines = nil
        }
        if codes == nil, lines == nil { throw failures.first ?? CocoaError(.featureUnsupported) }
        return ProductLabelReading(barcodes: codes ?? [], textLines: lines ?? [],
                                   unreadParts: (codes == nil ? [.barcodes] : []) + (lines == nil ? [.text] : []))
    }

    package static func withCPUFallback<T>(_ body: (Bool) throws -> T) throws -> T {
        do { return try body(false) } catch { return try body(true) }
    }

    /// The newest barcode model needs an accelerator context; where it errors or sees nothing (the iOS
    /// simulator; measured 2026-11-04: revision 4 fails with code 9, on CPU it returns no results) the
    /// classic detector (revision 2) gets one more look. Results from either are machine reads, not guesses.
    static func detectBarcodes(_ image: CGImage, orientation: CGImagePropertyOrientation, cpuOnly: Bool) throws -> [ProductLabelReading.Barcode] {
        var latestError: Error?
        do {
            let found = try barcodes(image, orientation: orientation, cpuOnly: cpuOnly, revision: nil)
            if !found.isEmpty { return found }
        } catch {
            latestError = error
        }
        guard VNDetectBarcodesRequest.supportedRevisions.contains(VNDetectBarcodesRequestRevision2) else {
            if let latestError { throw latestError }
            return []
        }
        return try barcodes(image, orientation: orientation, cpuOnly: cpuOnly, revision: VNDetectBarcodesRequestRevision2)
    }

    static func barcodes(_ image: CGImage, orientation: CGImagePropertyOrientation, cpuOnly: Bool, revision: Int?) throws -> [ProductLabelReading.Barcode] {
        let request = VNDetectBarcodesRequest()
        if let revision { request.revision = revision }
        let supported = Set((try? request.supportedSymbologies()) ?? symbologies)
        request.symbologies = symbologies.filter(supported.contains)
        if cpuOnly { forceCPU(request) }
        try VisionSerial.run { try VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:]).perform([request]) }
        return (request.results ?? [])
            .sorted { $0.confidence > $1.confidence }
            .compactMap { obs -> ProductLabelReading.Barcode? in
                guard let payload = obs.payloadStringValue, !payload.isEmpty else { return nil }
                return .init(payload: payload, symbology: symbologyName(obs.symbology))
            }
    }

    static func recognizeText(_ image: CGImage, orientation: CGImagePropertyOrientation, cpuOnly: Bool) throws -> [String] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        // Codes are not words: no autocorrection, and no language model "fixing" KB-JKT into a word.
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US", "tr-TR"]
        request.minimumTextHeight = 0.015
        if cpuOnly { forceCPU(request) }
        try VisionSerial.run { try VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:]).perform([request]) }
        // Top to bottom, then left to right, so the result does not depend on Vision's internal order.
        return (request.results ?? [])
            .sorted { a, b in
                abs(a.boundingBox.midY - b.boundingBox.midY) > 0.01 ? a.boundingBox.midY > b.boundingBox.midY : a.boundingBox.minX < b.boundingBox.minX
            }
            .compactMap { $0.topCandidates(1).first?.string }
    }

    package static func forceCPU(_ request: VNRequest) {
        guard let stages = try? request.supportedComputeStageDevices else { return }
        for (stage, devices) in stages {
            if let cpu = devices.first(where: { if case .cpu = $0 { true } else { false } }) {
                request.setComputeDevice(cpu, for: stage)
            }
        }
    }

    static func symbologyName(_ symbology: VNBarcodeSymbology) -> String {
        switch symbology {
        case .ean13: "EAN13"
        case .ean8: "EAN8"
        case .upce: "UPCE"
        case .code128: "Code128"
        case .code39: "Code39"
        case .code93: "Code93"
        case .itf14: "ITF14"
        case .qr: "QR"
        case .dataMatrix: "DataMatrix"
        case .pdf417: "PDF417"
        default: symbology.rawValue
        }
    }
}
