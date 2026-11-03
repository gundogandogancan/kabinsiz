import PhotosUI
import ProductCapture
import ShoppingCopilot
import SwiftUI
import SystemContracts
import UIKit
import VisionKit

/// SCAN-T011: three ways to bring a product without typing: live barcode (VisionKit, where supported),
/// a photo taken now, or a photo from the library. Every photo is read on this iPhone (Vision) and
/// released; only the codes read are kept for this screen. Nothing is stored or sent.
@MainActor @Observable
final class ProductPhotoIntake {
    enum State: Equatable {
        case idle
        case reading
        case done(ProductPhotoResult, example: Bool)
        /// The file is not an image (or could not be loaded).
        case unreadable
        /// The image is fine but on-device reading failed; nothing was guessed.
        case readerFailed
    }

    private(set) var state: State = .idle
    #if DEBUG
    /// The reader's error, shown only in DEBUG builds to diagnose a failed read (never the photo).
    private(set) var debugError: String?
    #endif

    var liveScannerAvailable: Bool { DataScannerViewController.isSupported && DataScannerViewController.isAvailable }
    var cameraAvailable: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }

    func read(data: Data, resolver: ProductResolver) async {
        state = .reading
        guard let image = ProductLabelReader.image(from: data) else { state = .unreadable; return }
        await read(image: image, resolver: resolver, example: false)
    }

    func read(image: CGImage, resolver: ProductResolver, example: Bool) async {
        state = .reading
        do {
            let reading = try await ProductLabelReader.read(image)
            state = .done(ProductCodeMatcher.match(reading, resolver: resolver), example: example)
        } catch {
            #if DEBUG
            debugError = String(describing: error)
            #endif
            state = .readerFailed
        }
    }

    func reset() { state = .idle }

    /// The picked item could not be loaded (e.g. an iCloud photo while offline): say so, do not go quiet.
    func markUnreadable() { state = .unreadable }

    #if DEBUG
    /// `-productPhotoFixture code128|text|ean|qr|plain`: a synthetic label rendered on the device and read
    /// by the same pipeline (the simulator has no camera). Shown with the "Örnek etiket" badge.
    func runFixtureIfRequested(resolver: ProductResolver) async {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-productPhotoFixture"), i + 1 < args.count else { return }
        let image: CGImage? = switch args[i + 1] {
        case "code128": SyntheticLabel.render(.code128("KB-JKT-01-NVY"), lines: ["KB-JKT-01-NVY", "ÖRNEK ETİKET · SENTETİK"])
        case "text": SyntheticLabel.render(.none, lines: ["KB-TEE-01-WHT", "Beden M"], rotation: 4)
        case "ean": SyntheticLabel.render(.ean13("869000000001"), lines: [])
        case "qr": SyntheticLabel.render(.qr("https://kabinsiz-login.example/verify"), lines: [])
        default: SyntheticLabel.plainGarment()
        }
        guard let image else { return }
        await read(image: image, resolver: resolver, example: true)
    }
    #endif
}

/// The "Ürünü getir" card: live barcode, take a photo, choose a photo.
struct ProductIntakeButtons: View {
    let intake: ProductPhotoIntake
    let onLiveScan: () -> Void
    let onCamera: () -> Void
    @Binding var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ürünü getir").font(.headline)
            Text("Barkodu tara ya da etiketin, barkodun fotoğrafını çek. Fotoğraf bu iPhone'da okunur; saklanmaz, gönderilmez.")
                .font(.subheadline).foregroundStyle(Token.textSecondary)
            HStack(spacing: 10) {
                tile("Barkodu tara", symbol: "barcode.viewfinder", id: "scanLiveBarcode", enabled: intake.liveScannerAvailable, action: onLiveScan)
                tile("Fotoğraf çek", symbol: "camera", id: "scanTakePhoto", enabled: intake.cameraAvailable, action: onCamera)
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    IntakeTileLabel(title: "Fotoğraf seç", symbol: "photo.on.rectangle", enabled: true)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("scanPickPhoto")
            }
            if !intake.liveScannerAvailable || !intake.cameraAvailable {
                Text(intake.cameraAvailable ? "Bu cihazda canlı barkod taraması yok; fotoğraf çekebilirsin."
                                            : "Bu cihazda kamera yok; galeriden bir etiket fotoğrafı seçebilirsin.")
                    .font(.footnote).foregroundStyle(Token.textSecondary)
                    .accessibilityIdentifier("scanCameraNote")
            }
        }
    }

    private func tile(_ title: String, symbol: String, id: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) { IntakeTileLabel(title: title, symbol: symbol, enabled: enabled) }
            .buttonStyle(.plain)
            .disabled(!enabled)
            .accessibilityIdentifier(id)
    }

}

private struct IntakeTileLabel: View {
    let title: String
    let symbol: String
    let enabled: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: symbol).font(.title3)
            Text(title).font(.footnote.weight(.semibold)).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 72)
        .foregroundStyle(enabled ? Atelier.brand : Token.textSecondary)
        .background(Token.surfaceBase, in: RoundedRectangle(cornerRadius: Token.Radius.small))
        .opacity(enabled ? 1 : 0.55)
        .contentShape(Rectangle())
    }
}

/// What the photo gave, said plainly. A found product is handed to the decision card by the caller.
struct ProductPhotoResultView: View {
    let state: ProductPhotoIntake.State
    var debugDetail: String? = nil
    let pick: (CatalogProduct) -> Void

    var body: some View {
        switch state {
        case .idle:
            EmptyView()
        case .reading:
            Card {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Etiket okunuyor (bu iPhone'da)…").font(.subheadline)
                }
            }
            .accessibilityIdentifier("photoReading")
        case .unreadable:
            Card {
                StatusBadge(text: "Fotoğraf açılamadı", tone: .caution)
                Text("Bu dosya okunabilir bir fotoğraf değil. Başka bir fotoğraf dene.").font(.subheadline)
            }
            .accessibilityIdentifier("photoUnreadable")
        case .readerFailed:
            Card {
                StatusBadge(text: "Etiket okunamadı", tone: .caution)
                Text("Bu iPhone'da etiket okuma şu an çalışmadı. Tekrar dene ya da kodu aşağıya yaz; tahmin etmiyoruz.").font(.subheadline)
                if let debugDetail { Text(debugDetail).font(.caption2.monospaced()).foregroundStyle(Token.textSecondary).accessibilityIdentifier("photoDebugError") }
            }
            .accessibilityIdentifier("photoReaderFailed")
        case let .done(result, example):
            VStack(alignment: .leading, spacing: 8) {
                if example { SyntheticBadge().accessibilityIdentifier("photoExample") }
                content(result)
                if !result.unreadParts.isEmpty {
                    Text(result.unreadParts.contains(.text) ? "Bu iPhone'da yazı okuma çalışmadı; yalnız barkoda bakıldı."
                                                            : "Bu iPhone'da barkod okuma çalışmadı; yalnız etiket yazısına bakıldı.")
                        .font(.footnote).foregroundStyle(Token.textSecondary)
                        .accessibilityIdentifier("photoPartialRead")
                }
                if result.refusedPayloads > 0 {
                    Text("Fotoğraftaki kodda bir bağlantı ya da ürün kodu olmayan bir içerik vardı; açmadık, kullanmadık.")
                        .font(.footnote).foregroundStyle(Token.textSecondary)
                        .accessibilityIdentifier("photoRefusedLink")
                }
            }
        }
    }

    @ViewBuilder private func content(_ result: ProductPhotoResult) -> some View {
        switch result.match {
        case let .found(product, via):
            Text("\(sourceText(via)) okundu: \(product.code)")
                .font(.footnote).foregroundStyle(Token.textSecondary)
                .accessibilityIdentifier("photoReadSource")
        case let .choose(options):
            Card {
                Text("Hangisi?").font(.headline)
                Text("Fotoğrafta birden fazla ürün ya da renk var. Doğru olanı seç; tahmin etmiyoruz.")
                    .font(.subheadline).foregroundStyle(Token.textSecondary)
                ForEach(options) { p in
                    Button { pick(p) } label: {
                        HStack { Text(verbatim: "\(UntrustedText(p.name)) · \(UntrustedText(p.colorName))"); Spacer(); Text(p.code).font(.caption.monospaced()) }
                            .frame(minHeight: 44)
                    }
                    .accessibilityIdentifier("photoChoice-\(p.code)")
                }
            }
            .accessibilityIdentifier("photoChooseCard")
        case let .notInCatalog(codes):
            Card {
                StatusBadge(text: "Kod okundu, katalogda yok", tone: .caution)
                ForEach(codes, id: \.value) { code in
                    Text("\(code.value) · \(kindText(code))").font(.callout.monospaced())
                }
                Text("Kayıtlı katalogda bu kod yok; mağaza kataloğu bağlı değil. Benzer bir ürünü bunun yerine göstermiyoruz.")
                    .font(.subheadline)
            }
            .accessibilityIdentifier("photoNotInCatalog")
        case .nothingRead:
            Card {
                StatusBadge(text: "Barkod ya da ürün kodu okunamadı", tone: .caution)
                Text("Etiketi ya da barkodu yakından, düz ve aydınlık çek. Ürünü yalnız görünüşünden tanıma bu sürümde yok; mağaza kataloğu bağlı değil.")
                    .font(.subheadline)
            }
            .accessibilityIdentifier("photoNothingRead")
        }
    }

    private func sourceText(_ source: CodeSource) -> String {
        switch source {
        case let .barcode(symbology): "Fotoğraftaki barkoddan (\(symbology))"
        case .labelText: "Etiketteki yazıdan"
        }
    }

    private func kindText(_ code: ReadCode) -> String {
        let kind = code.kind == .gtin ? "GTIN/EAN barkod numarası" : "ürün kodu"
        switch code.source {
        case .barcode: return "\(kind), barkoddan"
        case .labelText: return "\(kind), etiket yazısından"
        }
    }
}

/// The system camera for one still. The photo goes to the reader and is released; nothing is saved
/// to the library.
struct CameraCaptureSheet: UIViewControllerRepresentable {
    let onImage: (Data) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraCaptureSheet
        init(_ parent: CameraCaptureSheet) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // JPEG keeps the orientation flag; the reader decodes it upright.
            if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.9) { parent.onImage(data) }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}
