import BodyGeometry
import simd
import Testing
@testable import SelfModel

@Suite("V37-10 personal head: face patch and hair on the figure (HEAD-T01…)")
struct PersonalHeadTests {
    func headFrame() throws -> HeadFrame {
        let snapshot = try AvatarSnapshot.make(for: .neutral())
        return try #require(HeadFrame.of(try BodyMesh.make(from: snapshot)))
    }

    @Test("HEAD-T01 the head sits on top of the figure, wider than deep is not assumed")
    func frame() throws {
        let h = try headFrame()
        #expect(h.radii.x > 0.06 && h.radii.x < 0.12)
        #expect(h.radii.y > 0.08 && h.radii.y < 0.16)
        #expect(h.crownY > 1.5)
    }

    @Test("HEAD-T02 face patch: front only, outside the head, outward normals, CCW from the front, full UV square")
    func patch() throws {
        let h = try headFrame()
        let p = PersonalHead.facePatch(h)
        #expect(p.indices.count > 600)
        #expect(p.normals.allSatisfy { $0.z > 0.25 })
        for (pos, n) in zip(p.positions, p.normals) {
            let q = (pos - h.centre) / h.radii
            #expect(simd_length(q) >= 0.999, "on or just outside the head")
            #expect(simd_dot(pos - h.centre, n) > 0)
        }
        for t in stride(from: 0, to: p.indices.count, by: 3) {
            let a = p.positions[Int(p.indices[t])], b = p.positions[Int(p.indices[t + 1])], c = p.positions[Int(p.indices[t + 2])]
            #expect(simd_cross(b - a, c - a).z > 0, "faces the viewer")
        }
        let us = p.uvs.map(\.x), vs = p.uvs.map(\.y)
        #expect(us.min()! < 0.2 && us.max()! > 0.8 && vs.min()! < 0.2 && vs.max()! > 0.8)
    }

    @Test("HEAD-T03 hair: none when not visible; long reaches below the chin, short does not")
    func hair() throws {
        let h = try headFrame()
        #expect(PersonalHead.hair(h, length: .notVisible) == nil)
        let short = try #require(PersonalHead.hair(h, length: .short))
        let long = try #require(PersonalHead.hair(h, length: .long))
        #expect(short.positions.map(\.y).min()! > h.chinY)
        #expect(long.positions.map(\.y).min()! < h.chinY - 0.05)
        // The face stays free: no hair in front of the eyes (front, middle height).
        #expect(!short.positions.contains { $0.z > h.centre.z + h.radii.z * 0.8 && abs($0.y - h.centre.y) < h.radii.y * 0.3 })
        #expect(short.positions.allSatisfy { $0.x.isFinite && $0.y.isFinite && $0.z.isFinite })
    }
}

@Suite("V37-01 accepting the proposal (ACCEPT-T01…)")
struct AcceptTests {
    @Test("ACCEPT-T01 photo estimates shape the figure but never reach size advice")
    func estimatesAreNotMeasurements() async throws {
        let out = await SelfModelPipeline.run(fixture("person-c"), options: .testing(userHeightCm: 178))
        let p = try #require(out.envelope.value)
        let edits = p.bodyEdits(accepting: [.height, .chest, .waist])
        #expect(edits.count == 3)
        #expect(edits.first { $0.parameter == .height }?.source == .userMeasured)
        #expect(edits.filter { $0.parameter != .height }.allSatisfy { $0.source == .photoEstimated })
        var profile = BodyProfile.neutral()
        for e in edits { profile = try profile.applying(e) }
        #expect(profile.measuredCentimeters.keys.sorted { $0.rawValue < $1.rawValue } == [.height])
        #expect(profile[.chest].source.label == "Fotoğraftan tahmin (ölçü değil)")
    }

    @Test("ACCEPT-T02 the face is drawn only with the texture opt-in and the likeness confirmation")
    func faceNeedsBothYeses() async throws {
        let out = await SelfModelPipeline.run(fixture("person-b"), options: .testing(userHeightCm: 170, makeFaceTexture: true))
        let p = try #require(out.envelope.value)
        #expect(p.look(withFace: true, confirmedLikeness: true)?.drawsFace == true)
        #expect(p.look(withFace: true, confirmedLikeness: false)?.drawsFace == false)
        #expect(p.look(withFace: false, confirmedLikeness: true)?.faceTexturePNG == nil)
    }
}
