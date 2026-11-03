import Foundation
import LivingWorld
import Testing

@Suite("World streets: catalogue and nearest city (Look Around backdrop)")
struct WorldStreetsTests {
    @Test("Every entry is well formed: unique id, a real time zone, a point on Earth, a street name")
    func wellFormed() {
        let all = FamousStreetCatalog.all
        #expect(all.count >= 30)
        #expect(Set(all.map(\.id)).count == all.count)
        for s in all {
            #expect(s.timeZone != nil, "\(s.id) time zone")
            #expect((-90...90).contains(s.latitude) && (-180...180).contains(s.longitude), "\(s.id) position")
            #expect(!s.street.isEmpty && !s.city.isEmpty && s.country.count == 2)
            #expect(s.id.hasPrefix(s.country + "-"), "\(s.id) country prefix")
        }
        // Two catalogue cities closer than the match radius would make "nearest" ambiguous.
        for (i, a) in all.enumerated() {
            for b in all.dropFirst(i + 1) {
                #expect(FamousStreetCatalog.distanceKm(a.latitude, a.longitude, b.latitude, b.longitude) > FamousStreetCatalog.matchRadiusKm,
                        "\(a.id) and \(b.id) overlap")
            }
        }
    }

    @Test("A position in a city resolves to that city's street; open sea or a far town resolves to none")
    func nearest() {
        #expect(FamousStreetCatalog.nearest(latitude: 41.0082, longitude: 28.9784)?.street == "İstiklal Caddesi") // Sultanahmet
        #expect(FamousStreetCatalog.nearest(latitude: 41.0600, longitude: 29.0100)?.id == "TR-IST") // Beşiktaş
        #expect(FamousStreetCatalog.nearest(latitude: 48.8566, longitude: 2.3522)?.id == "FR-PAR")
        #expect(FamousStreetCatalog.nearest(latitude: 35.6812, longitude: 139.7671)?.id == "JP-TYO")
        #expect(FamousStreetCatalog.nearest(latitude: 0, longitude: -30) == nil, "mid-Atlantic")
        #expect(FamousStreetCatalog.nearest(latitude: 39.7767, longitude: 30.5206) == nil, "Eskişehir is not Ankara")
    }

    @Test("The owned 3D streets are tied to their cities; distance is symmetric and about right")
    func ownedAndDistance() {
        #expect(FamousStreetCatalog.street(id: "TR-IST")?.ownedScene == .istanbul)
        #expect(FamousStreetCatalog.street(id: "ES-BCN")?.ownedScene == .barcelona)
        let d = FamousStreetCatalog.distanceKm(41.0082, 28.9784, 39.9334, 32.8597)
        #expect(abs(d - 351) < 10, "İstanbul–Ankara ≈ 351 km, got \(d)")
        #expect(abs(d - FamousStreetCatalog.distanceKm(39.9334, 32.8597, 41.0082, 28.9784)) < 1e-9)
    }
}
