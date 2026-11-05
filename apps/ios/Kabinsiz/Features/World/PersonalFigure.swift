import BodyGeometry
import RealityKit
import SelfModel
import UIKit

/// V37 "ayna ikiz": the user's own look on the 3D figure. Without a look the figure stays the covered,
/// linen-toned neutral form (§108.3). With one: the body takes the skin colour, a matte hair shell sits on
/// the head, and, only when the user opted into the face texture *and* said "bu bana benziyor", the photo's
/// own face pixels are projected onto the front of the head. Nothing is drawn, smoothed or beautified.
@MainActor
enum PersonalFigure {
    static let neutralTint = UIColor(red: 0.80, green: 0.73, blue: 0.64, alpha: 1)

    static func bodyMaterial(_ look: PersonalLook?, neutral: UIColor = neutralTint) -> PhysicallyBasedMaterial {
        var m = PhysicallyBasedMaterial()
        if let look {
            m.baseColor = .init(tint: UIColor(rgb: look.skinRGB))
            m.roughness = 0.62
            // A little sheen reads as skin under the stage light without looking wet.
            m.sheen = .init(tint: UIColor(rgb: look.skinRGB).withAlphaComponent(1).shaded(by: 1.08))
        } else {
            m.baseColor = .init(tint: neutral)
            m.roughness = 0.85
        }
        return m
    }

    /// Hair and face entities for the head of `mesh`; empty without a look.
    static func headEntities(for mesh: BodyMesh, look: PersonalLook?) -> [Entity] {
        guard let look, let head = HeadFrame.of(mesh) else { return [] }
        var out: [Entity] = []
        if look.drawsFace, let png = look.faceTexturePNG, let texture = texture(png) {
            let patch = PersonalHead.facePatch(head)
            if let resource = try? MeshResource.generate(from: [descriptor(patch, name: "face")]) {
                var m = PhysicallyBasedMaterial()
                m.baseColor = .init(tint: .white, texture: .init(texture))
                m.roughness = 0.6
                let e = ModelEntity(mesh: resource, materials: [m])
                e.name = "personal-face"
                out.append(e)
            }
        }
        if let hairRGB = look.hairRGB, let hair = PersonalHead.hair(head, length: look.hairLength),
           let resource = try? MeshResource.generate(from: [descriptor(hair, name: "hair")]) {
            var m = PhysicallyBasedMaterial()
            m.baseColor = .init(tint: UIColor(rgb: hairRGB))
            m.roughness = 0.75
            m.sheen = .init(tint: UIColor(rgb: hairRGB).shaded(by: 1.3))
            m.faceCulling = .none
            let e = ModelEntity(mesh: resource, materials: [m])
            e.name = "personal-hair"
            out.append(e)
        }
        return out
    }

    private static func texture(_ png: Data) -> TextureResource? {
        guard let image = UIImage(data: png)?.cgImage else { return nil }
        return try? TextureResource(image: image, options: .init(semantic: .color))
    }

    private static func descriptor(_ piece: SurfacePiece, name: String) -> MeshDescriptor {
        var d = MeshDescriptor(name: name)
        d.positions = MeshBuffers.Positions(piece.positions)
        d.normals = MeshBuffers.Normals(piece.normals)
        // RealityKit samples with v up; our pieces carry image v (down).
        d.textureCoordinates = MeshBuffers.TextureCoordinates(piece.uvs.map { SIMD2($0.x, 1 - $0.y) })
        d.primitives = .triangles(piece.indices)
        return d
    }
}

extension UIColor {
    convenience init(rgb: SIMD3<Double>) {
        self.init(red: rgb.x, green: rgb.y, blue: rgb.z, alpha: 1)
    }
}
