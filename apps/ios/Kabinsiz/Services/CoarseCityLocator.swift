import CoreLocation
import LivingWorld

/// "Konumumdaki şehir" (UI28-T060): one reduced-accuracy fix, matched on this device to the nearest
/// catalogue city, then dropped. Only the city's id is kept by the caller; the position is never
/// stored, logged or sent. The only file allowed to use Core Location's manager (privacy source scan).
@MainActor
final class CoarseCityLocator: NSObject, CLLocationManagerDelegate {
    enum Outcome: Equatable {
        case city(FamousStreet)
        /// Located, but no catalogue city within its radius.
        case noCityNearby
        case denied
        case unavailable
    }

    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<Outcome, Never>?

    /// Asks for When In Use permission only at this tap (never at launch), then for one fix.
    func locate() async -> Outcome {
        guard continuation == nil else { return .unavailable }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
        return await withCheckedContinuation { c in
            continuation = c
            proceed(manager.authorizationStatus)
        }
    }

    private func proceed(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways: manager.requestLocation()
        default: finish(.denied)
        }
    }

    private func finish(_ outcome: Outcome) {
        continuation?.resume(returning: outcome)
        continuation = nil
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            guard self.continuation != nil, status != .notDetermined else { return }
            self.proceed(status)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        let lat = last.coordinate.latitude, lon = last.coordinate.longitude
        Task { @MainActor in
            self.manager.stopUpdatingLocation()
            self.finish(FamousStreetCatalog.nearest(latitude: lat, longitude: lon).map(Outcome.city) ?? .noCityNearby)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let denied = (error as? CLError)?.code == .denied
        Task { @MainActor in self.finish(denied ? .denied : .unavailable) }
    }
}
