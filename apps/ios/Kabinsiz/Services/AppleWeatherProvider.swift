import CoreLocation
import Foundation
import SwiftUI
import SystemContracts
import TravelEngine
import WeatherKit

/// Apple WeatherKit behind the `WeatherProvider` seam (ADR-004). Sends only the bundled city-centre
/// point of the destination, looked up at request time from `CityDirectory` (never a stored or device
/// coordinate), and only after the user taps "get forecast". Egress register: EG-001.
struct AppleWeatherProvider: WeatherProvider {
    let name = "APPLE_WEATHER"

    enum Failure: Error { case noCityCenter, egressDenied(FaultCode) }

    /// The declaration checked before every request (§112.2). If it stops validating, no request is made.
    static let egress = EgressIntent(
        destinationHost: "weatherkit.apple.com", method: .get, endpointPath: "/api/v1/weather",
        classification: .localPrivate, purpose: .weatherForecast, fields: ["city_center_coordinate"],
        consentBasis: .explicitUserAction, userVisibleEffect: "Seyahat şehrinin günlük hava tahmini getirilir",
        retention: .cacheWithTTL
    )

    func snapshots(for destination: Destination, dates: [LocalDate]) async -> [WeatherSnapshot] {
        (try? await fetch(destination: destination, dates: dates)) ?? dates.map(WeatherSnapshot.noData)
    }

    /// Days outside what WeatherKit returns stay `NO_DATA`; the horizon is read from the response, not assumed.
    func fetch(destination: Destination, dates: [LocalDate]) async throws -> [WeatherSnapshot] {
        do { try Self.egress.validate() } catch { throw Failure.egressDenied(error) }
        guard let center = CityDirectory.cityCenter(for: destination) else { throw Failure.noCityCenter }
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let forecast = try await WeatherService.shared.weather(for: location, including: .daily)
        let retrieved = forecast.metadata.date
        let expires = forecast.metadata.expirationDate
        var byDate: [LocalDate: WeatherSnapshot] = [:]
        for day in forecast {
            let date = LocalDate(instant: day.date, timeZone: destination.timeZone)
            byDate[date] = WeatherSnapshot(
                localDate: date, evidence: .liveForecast, provider: name, retrievedAt: retrieved, validUntil: expires,
                lowC: day.lowTemperature.converted(to: .celsius).value,
                highC: day.highTemperature.converted(to: .celsius).value,
                precipitationProbability: day.precipitationChance,
                windKph: day.wind.speed.converted(to: .kilometersPerHour).value,
                isSynthetic: false
            )
        }
        return dates.map { byDate[$0] ?? .noData($0) }
    }
}

/// Apple Weather mark + legal link, required wherever WeatherKit data is shown. Loading the mark is a
/// request to Apple with no user data (egress register EG-002); it only appears after the user fetched weather.
struct WeatherAttributionView: View {
    @Environment(\.colorScheme) private var scheme
    @State private var attribution: WeatherAttribution?

    var body: some View {
        HStack(spacing: 8) {
            if let attribution {
                AsyncImage(url: scheme == .dark ? attribution.combinedMarkDarkURL : attribution.combinedMarkLightURL) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Text(attribution.serviceName).font(.caption2)
                }
                .frame(height: 12)
                .accessibilityLabel(attribution.serviceName)
                Link("Veri kaynakları", destination: attribution.legalPageURL).font(.caption2)
            } else {
                Text("\u{F8FF} Weather").font(.caption2)
                Link("Veri kaynakları", destination: URL(string: "https://weatherkit.apple.com/legal-attribution.html")!).font(.caption2)
            }
        }
        .accessibilityIdentifier("weatherAttribution")
        .task { attribution = try? await WeatherService.shared.attribution }
    }
}
