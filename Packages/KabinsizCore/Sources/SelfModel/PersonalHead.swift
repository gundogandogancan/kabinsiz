import BodyGeometry
import Foundation
import simd

/// The figure's head as an ellipsoid, read from the body mesh (BodyMesh coordinates: metres, y up, z to
/// the viewer). The personal face and hair are laid on it; the head itself is not reshaped.
public struct HeadFrame: Equatable, Sendable {
    public let centre: SIMD3<Float>
    /// Half width (x), half height (y), half depth (z).
    public let radii: SIMD3<Float>

    public var crownY: Float { centre.y + radii.y }
    public var chinY: Float { centre.y - radii.y }

    /// The torso piece above the neck station (13% of the height from the crown, `Silhouette.Station.neck`).
    public static func of(_ mesh: BodyMesh) -> HeadFrame? {
        guard let torso = mesh.pieces.first(where: { $0.part == .torso }) else { return nil }
        let top = torso.positions.map(\.y).max() ?? 0
        let height = mesh.pieces.flatMap(\.positions).map(\.y).max() ?? top
        let neckY = top - Float(Silhouette.Station.neck.heightFraction) * height
        let head = torso.positions.filter { $0.y > neckY }
        guard head.count > 8 else { return nil }
        let lo = head.reduce(SIMD3<Float>(repeating: .greatestFiniteMagnitude)) { simd_min($0, $1) }
        let hi = head.reduce(SIMD3<Float>(repeating: -.greatestFiniteMagnitude)) { simd_max($0, $1) }
        // The neck cut makes the lower bound the neck, not the chin: the chin sits ~12% of the head up from it.
        let chin = lo.y + (hi.y - lo.y) * 0.12
        let centre = SIMD3((lo.x + hi.x) / 2, (chin + hi.y) / 2, (lo.z + hi.z) / 2)
        return HeadFrame(centre: centre, radii: SIMD3((hi.x - lo.x) / 2, (hi.y - chin) / 2, (hi.z - lo.z) / 2))
    }

    /// Height of the ellipsoid's front surface at (x, y), or nil outside it.
    func frontZ(x: Float, y: Float) -> Float? {
        let dx = (x - centre.x) / radii.x, dy = (y - centre.y) / radii.y
        let r = 1 - dx * dx - dy * dy
        return r > 0 ? centre.z + radii.z * r.squareRoot() : nil
    }

    func normal(at p: SIMD3<Float>) -> SIMD3<Float> {
        simd_normalize((p - centre) / (radii * radii))
    }
}

/// A textured surface piece for the renderer: positions, normals, texture coordinates (0…1, v down) and
/// counter-clockwise triangles seen from outside.
public struct SurfacePiece: Equatable, Sendable {
    public let positions: [SIMD3<Float>]
    public let normals: [SIMD3<Float>]
    public let uvs: [SIMD2<Float>]
    public let indices: [UInt32]
}

public enum PersonalHead {
    /// The face texture projected straight from the front onto the head, like the photo was taken: the
    /// texture square is placed over the head as `FaceTexture.make` cropped it (head box × 1.08, centred).
    /// Only the front of the head is covered; the texture fades to skin at its oval edge.
    public static func facePatch(_ head: HeadFrame, lift: Float = 0.0015, grid: Int = 32) -> SurfacePiece {
        let side = max(2 * head.radii.x, 2 * head.radii.y) * 1.08
        var positions: [SIMD3<Float>] = [], normals: [SIMD3<Float>] = [], uvs: [SIMD2<Float>] = []
        var index: [Int: UInt32] = [:]
        func vertex(_ i: Int, _ j: Int) -> UInt32? {
            let key = j * (grid + 1) + i
            if let v = index[key] { return v }
            let u = Float(i) / Float(grid), v = Float(j) / Float(grid)
            let x = head.centre.x + (u - 0.5) * side
            let y = head.centre.y - (v - 0.5) * side
            // Keep to the front: points that face the viewer (normal z > 0.25), so the sides are not smeared.
            guard let z = head.frontZ(x: x, y: y) else { return nil }
            let p = SIMD3(x, y, z)
            let n = head.normal(at: p)
            guard n.z > 0.25 else { return nil }
            index[key] = UInt32(positions.count)
            positions.append(p + n * lift)
            normals.append(n)
            uvs.append(SIMD2(u, v))
            return index[key]
        }
        var indices: [UInt32] = []
        for j in 0 ..< grid {
            for i in 0 ..< grid {
                guard let a = vertex(i, j), let b = vertex(i + 1, j), let c = vertex(i + 1, j + 1), let d = vertex(i, j + 1) else { continue }
                // Seen from +z with v growing downwards: a (top-left), d (bottom-left), c, b.
                indices += [a, d, c, a, c, b]
            }
        }
        return SurfacePiece(positions: positions, normals: normals, uvs: uvs, indices: indices)
    }

    /// A hair shell slightly larger than the head. Short hair covers the crown down to the brow at the
    /// front and the nape at the back; medium reaches the jaw at the sides; long adds a back panel to the
    /// shoulders. No strands: one matte surface in the user's hair colour.
    public static func hair(_ head: HeadFrame, length: HairLength, rings: Int = 24, segments: Int = 40) -> SurfacePiece? {
        guard length != .notVisible else { return nil }
        let shell = head.radii * SIMD3(1.07, 1.05, 1.07)
        // Lowest elevation the hair reaches (radians, 0 = equator), front and back.
        let (front, side, back): (Float, Float, Float) = switch length {
        case .short: (0.62, 0.2, -0.25)
        case .medium: (0.62, -0.55, -0.6)
        case .long: (0.62, -0.75, -0.95)
        case .notVisible: (0, 0, 0)
        }
        func lowest(_ azimuth: Float) -> Float {
            // azimuth 0 = front (+z). Blend front → side → back.
            let a = abs(atan2(sin(azimuth), cos(azimuth)))         // 0…π
            return a < .pi / 2 ? front + (side - front) * (a / (.pi / 2)) : side + (back - side) * ((a - .pi / 2) / (.pi / 2))
        }
        var positions: [SIMD3<Float>] = [], normals: [SIMD3<Float>] = [], uvs: [SIMD2<Float>] = []
        var indices: [UInt32] = []
        let bottom: Float = -1.3
        // How far the hanging part drops, in head half-heights per unit of hang: medium to the jaw line and
        // neck, long past the shoulders (about 12 cm below the chin on an adult figure).
        let drop: Float = length == .long ? 4.2 : 1.6
        for r in 0 ... rings {
            let t = Float(r) / Float(rings)
            for s in 0 ... segments {
                let azimuth = Float(s) / Float(segments) * 2 * .pi
                let low = lowest(azimuth)
                let elevation = .pi / 2 - t * (.pi / 2 - max(low, bottom))
                let dir = SIMD3(sin(azimuth) * cos(elevation), sin(elevation), cos(azimuth) * cos(elevation))
                var p = head.centre + dir * shell
                // Below the chin the hair hangs straight down instead of following the ellipsoid inwards.
                if elevation < -0.35 {
                    let hang = (-0.35 - elevation) / (.pi / 2 - 0.35)
                    let ring = head.centre + SIMD3(sin(azimuth) * cos(-0.35), sin(-0.35), cos(azimuth) * cos(-0.35)) * shell
                    p = SIMD3(ring.x, ring.y - hang * head.radii.y * drop, ring.z)
                }
                positions.append(p)
                normals.append(simd_normalize(SIMD3(dir.x, max(dir.y, 0), dir.z)))
                uvs.append(SIMD2(Float(s) / Float(segments), t))
            }
        }
        let w = UInt32(segments + 1)
        for r in 0 ..< UInt32(rings) {
            for s in 0 ..< UInt32(segments) {
                let a = r * w + s, b = a + 1, c = a + w, d = c + 1
                indices += [a, b, d, a, d, c]
            }
        }
        return SurfacePiece(positions: positions, normals: normals, uvs: uvs, indices: indices)
    }
}
