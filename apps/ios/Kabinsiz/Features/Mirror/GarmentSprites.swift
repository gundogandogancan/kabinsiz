import AvatarDressing
import BodyGeometry
import LiveMirror
import SwiftUI
import UIKit

/// The garment drawings made in Blender (tools/garments, OWNED_ORIGINAL), loaded once from the app
/// bundle. Fabric layers are neutral and tinted to the product colour on screen; trims are not.
@MainActor
final class GarmentSprites {
    static let shared = GarmentSprites()

    let manifest: GarmentSpriteManifest?
    private var images: [String: UIImage] = [:]

    private init() {
        if let url = Bundle.main.url(forResource: "garments", withExtension: "json"), let data = try? Data(contentsOf: url) {
            manifest = try? GarmentSpriteManifest.decode(data)
        } else {
            manifest = nil
        }
    }

    func spec(for form: GarmentForm) -> GarmentFormSpec? { manifest?.forms[form.rawValue] }

    func image(_ file: String?) -> UIImage? {
        guard let file else { return nil }
        if let cached = images[file] { return cached }
        let name = (file as NSString).deletingPathExtension
        guard let url = Bundle.main.url(forResource: name, withExtension: "png"), let image = UIImage(contentsOfFile: url.path) else { return nil }
        images[file] = image
        return image
    }
}

/// A product picture made from the garment drawing: neutral fabric tinted to the colour, trims on top.
/// Shown with the same honest wording as the 3D model: a representative drawing of the category.
struct GarmentThumb: View {
    let item: DressItem
    var padding: CGFloat = 8

    var body: some View {
        let sprites = GarmentSprites.shared
        if let thumb = sprites.spec(for: item.form)?.thumb, let fabric = sprites.image(thumb.files["fabric"]) {
            ZStack {
                Image(uiImage: fabric).resizable().scaledToFit()
                    .colorMultiply(Color(rgb: item.colorHex).liftedForTint)
                if let fixed = sprites.image(thumb.files["fixed"]) {
                    Image(uiImage: fixed).resizable().scaledToFit()
                }
            }
            .shadow(color: .black.opacity(0.12), radius: 6, y: 4)
            .padding(padding)
            .accessibilityHidden(true)
        } else {
            Image(systemName: item.slot.symbol)
                .font(.title2)
                .foregroundStyle(Color(rgb: item.colorHex))
                .accessibilityHidden(true)
        }
    }
}

extension Color {
    /// Multiply tint on an off-white fabric darkens it by the fabric's own value (~0.85); lifting very
    /// dark colours keeps their weave visible instead of turning them into a flat silhouette.
    var liftedForTint: Color {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lift: CGFloat = 0.06
        return Color(red: min(1, r * 1.12 + lift), green: min(1, g * 1.12 + lift), blue: min(1, b * 1.12 + lift))
    }
}
