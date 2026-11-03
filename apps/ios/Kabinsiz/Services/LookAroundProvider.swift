import Foundation
import LivingWorld
import MapKit
import SystemContracts

/// A Look Around scene, carried across the gate's `Sendable` boundary. The scene is an opaque MapKit
/// handle: it holds no user data and is only read on the main actor by the home backdrop.
struct LookAroundSceneBox: @unchecked Sendable {
    let scene: MKLookAroundScene
}

/// EG-003: Apple Look Around for one catalogue street (`FamousStreetCatalog`), behind `CitadelGate`.
/// Sends only that street's bundled point, rounded to 4 decimals: never the device position. MapKit
/// performs the HTTP call; the gate authorises it first and the call runs inside its transport.
struct LookAroundProvider {
    let gate: CitadelGate

    static let egress = EgressIntent(
        destinationHost: "mapkit.apple.com", method: .get, endpointPath: "/look-around/scene",
        classification: .localPrivate, purpose: .streetImagery, fields: ["street_coordinate"],
        consentBasis: .explicitUserAction, userVisibleEffect: "Seçilen şehrin ünlü caddesinin Apple Look Around görüntüsü",
        retention: .session
    )

    /// Nil when Apple has no Look Around scene near that point.
    func scene(for street: FamousStreet) async throws -> LookAroundSceneBox? {
        let grant = try await gate.issue(module: .occasionVenue, capability: .streetImageryFetch)
        return try await gate.send(Self.egress, payload: StreetImageryRequest(latitude: street.latitude, longitude: street.longitude),
                                   module: .occasionVenue, grant: grant) { authorized in
            guard let point = StreetImageryRequest.coordinate(from: authorized) else { throw FaultCode.egressBlocked }
            let request = MKLookAroundSceneRequest(coordinate: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
            return try await request.scene.map(LookAroundSceneBox.init)
        }
    }
}
