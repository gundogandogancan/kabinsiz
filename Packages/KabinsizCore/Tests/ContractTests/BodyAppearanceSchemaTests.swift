import BodyGeometry
import DomainSchemas
import Foundation
import SystemContracts
import Testing

/// ADR-011 in the stored body schema: template and weight live in the morph state (the picture), and a
/// weight estimate is never promoted to a measurement or to size advice.
@Suite("Body schema v2: template and weight (ADR-011)")
struct BodyAppearanceSchemaTests {
    @Test("v1 ↔ v2 keeps template, weight and estimate sources; estimates never become measurements")
    func roundTrip() throws {
        let w = try BodyProfile.neutral()
            .applying(.measured(.waist, 80, .centimeters))
            .withAppearance(template: .female, weightKg: 61.5)
        let v2 = try BodyProfileMigration.upgrade(w, at: Date(timeIntervalSince1970: 0))
        #expect(v2.measurements.map(\.region) == [.waist])
        #expect(v2.avatarMorphState.values.first { $0.region == .chest }?.source == .weightEstimate)
        #expect(v2.avatarMorphState.template == .female && v2.avatarMorphState.weightKg == 61.5)
        let back = try BodyProfileMigration.downgrade(v2)
        #expect(back.values == w.values && back.template == .female && back.weightKg == 61.5)
        // Strict contract round trip.
        let data = try ContractCoder.encode(v2)
        #expect(try ContractCoder.decode(BodyProfileV2.self, from: data) == v2)
    }

    @Test("A neutral body without weight has no template or weight keys; an out-of-range weight is refused")
    func neutralAndGuard() throws {
        let v2 = try BodyProfileMigration.upgrade(.neutral(), at: Date(timeIntervalSince1970: 0))
        #expect(v2.avatarMorphState.template == nil && v2.avatarMorphState.weightKg == nil)
        var bad = v2
        bad.avatarMorphState.weightKg = 400
        #expect(throws: FaultCode.self) { try bad.validate() }
    }

    @Test("A v1 file written after ADR-011 (template, weight) is read and upgraded")
    func readsNewV1Keys() throws {
        let p = try BodyProfile.neutral().withAppearance(template: .male, weightKg: 90)
        let v2 = try BodyProfileMigration.read(JSONEncoder().encode(p), now: Date(timeIntervalSince1970: 0))
        #expect(v2.avatarMorphState.template == .male && v2.avatarMorphState.weightKg == 90)
    }
}
