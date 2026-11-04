import Foundation

/// The rings every body surface is lofted from, in centimetres (y up from the floor, right side, +x).
/// `BodyMesh` lofts the skin from them and `GarmentMesh` lofts clothes from the same rings pushed
/// outwards, so a garment always follows the body it is drawn on and the two cannot drift apart.
struct BodyRig {
    struct Arm {
        let joint: SIMD3<Double>
        /// Unit vector from shoulder to hand.
        let axis: SIMD3<Double>
        /// Unit vector perpendicular to the axis in the x-y plane, pointing away from the body.
        let side: SIMD3<Double>
        let length: Double
        func point(_ t: Double) -> SIMD3<Double> { joint + axis * (t * length) }
    }

    let shape: Silhouette
    let h: Double
    let outline: [Silhouette.Point]
    let depths: [Double]
    /// Forward shift of the torso ring centre at each outline sample (cm): the bust or chest projection.
    /// `depths` already include it, so the front surface is at `zShift + depth` and the back at `zShift - depth`.
    let zShift: [Double]
    let crotchIndex: Int
    /// Crown to crotch, then a short tuck that narrows inside the legs, so the seat has no ledge.
    let torsoRings: [BodyMesh.Ring]
    /// Right leg from inside the torso to the floor; the last ring is the foot.
    let legRings: [BodyMesh.Ring]
    let arm: Arm
    let armRings: [BodyMesh.Ring]
    /// Arm ring parameter (0 = shoulder, 1 = hand) for every ring in `armRings`.
    let armT: [Double]

    init(_ shape: Silhouette) throws(BodyEditError) {
        try shape.validate()
        self.shape = shape
        let h = shape.heightCm
        self.h = h
        let outline = shape.rightOutline
        self.outline = outline
        var depths = BodyMesh.depthProfile(shape)
        guard depths.count == outline.count else { throw .unsafeGeometry("depth") }
        // Girths for the projection come back from the widths the silhouette drew them with.
        let k = Silhouette.FormProportions.of(shape.form)
        let chestCm = (shape.halfWidthsCm[.chest] ?? 0) * k.chestDivisor
        let waistCm = (shape.halfWidthsCm[.waist] ?? 0) * 5.2
        var shift = [Double](repeating: 0, count: outline.count)
        for i in outline.indices {
            let d = BodyMesh.frontProjection(form: shape.form, fraction: outline[i].y / h, chestCm: chestCm, waistCm: waistCm, heightCm: h)
            shift[i] = d
            depths[i] += d
        }
        self.depths = depths
        self.zShift = shift
        let crotchIndex = outline.firstIndex { $0.y >= BodyMesh.crotchFraction * h } ?? outline.count / 2
        self.crotchIndex = crotchIndex

        var torso: [BodyMesh.Ring] = []
        for i in 0...crotchIndex {
            let p = outline[i]
            torso.append(.init(center: SIMD3(0, h - p.y, shift[i]), a: p.x, b: depths[i], u: SIMD3(1, 0, 0)))
        }
        for k in 1...BodyMesh.tuckRings where crotchIndex + k < outline.count {
            let p = outline[crotchIndex + k]
            let f = 1 - 0.1 * Double(k)
            torso.append(.init(center: SIMD3(0, h - p.y, 0), a: p.x * f, b: depths[crotchIndex] * f, u: SIMD3(1, 0, 0)))
        }
        torsoRings = torso

        // Right leg (viewer's right, +x): outer edge on the silhouette, inner edge at the gap.
        var leg: [BodyMesh.Ring] = []
        let legStart = max(crotchIndex - 3, 0) // starts inside the torso so the joint has no seam
        let blendEnd = min(crotchIndex + BodyMesh.tuckRings + 2, outline.count - 1)
        for i in legStart..<outline.count {
            let w = outline[i].x
            let r = max((w - BodyMesh.legGap(outline[i].y / h) * h) / 2, 0.004 * h)
            var depth = r * BodyMesh.legDepthRatio(outline[i].y / h)
            // Near the seat the leg takes the torso's depth and hands over gradually, so front and back
            // have no ledge where the torso ends inside the legs.
            if i < blendEnd {
                let t = Double(i - legStart) / Double(blendEnd - legStart)
                let s = t * t * (3 - 2 * t)
                depth = depths[min(i, crotchIndex)] * (1 - s) + depth * s
            }
            leg.append(.init(center: SIMD3(w - r, h - outline[i].y, 0), a: r, b: depth, u: SIMD3(1, 0, 0)))
        }
        // Foot: one short ring down to the floor, flat sole.
        if let ankle = leg.last {
            leg.append(.init(center: SIMD3(ankle.center.x, 0.004 * h, 0.012 * h), a: ankle.a * 1.05, b: ankle.b * 1.6, u: SIMD3(1, 0, 0)))
        }
        legRings = leg

        // Right arm: a straight tube in the x-y plane, tilted out just enough to clear the hips.
        let shoulderHalf = shape.halfWidthsCm[.shoulder] ?? outline[0].x
        let jointY = h * (1 - 0.195)
        let (tilt, jointX) = BodyMesh.armPlacement(shape: shape, jointX: max(shoulderHalf - BodyMesh.armRadii[0].r * h * 0.85, 0.01 * h), jointY: jointY)
        let arm = Arm(joint: SIMD3(jointX, jointY, 0), axis: SIMD3(sin(tilt), -cos(tilt), 0), side: SIMD3(cos(tilt), sin(tilt), 0),
                      length: BodyMesh.armLengthFraction * h)
        self.arm = arm
        let samples = 24
        var rings: [BodyMesh.Ring] = []
        var ts: [Double] = []
        for k in 0...samples {
            let t = Double(k) / Double(samples)
            let r = BodyMesh.armRadius(at: t) * h
            rings.append(.init(center: arm.point(t), a: r, b: r * 0.92, u: arm.side))
            ts.append(t)
        }
        armRings = rings
        armT = ts
    }

    /// Index of the first outline sample at or below a height fraction measured from the crown.
    func outlineIndex(atFraction f: Double) -> Int {
        outline.firstIndex { $0.y >= f * h } ?? outline.count - 1
    }
}
