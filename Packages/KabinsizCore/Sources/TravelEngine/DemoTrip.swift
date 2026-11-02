import DomainContracts
import Foundation

/// The §56 fictional demo: 5 days in Barcelona, city walks + museum + one smart dinner,
/// cabin bag, no laundry, light packing. Tagged `SYNTHETIC_DEMO_ONLY` everywhere.
public enum DemoTrip {
    public static func barcelona(start: LocalDate, now: Date = Date()) -> Trip {
        let destination = CityDirectory.entries.first { $0.city == "Barselona" && $0.country == "İspanya" }!
        let dates = (0..<5).map { start.adding(days: $0) }
        let events = [
            TripEvent(id: "ev-1-walk", localDate: dates[0], timeBlock: .afternoon, activity: .cityWalk),
            TripEvent(id: "ev-2-museum", localDate: dates[1], timeBlock: .morning, activity: .museum),
            TripEvent(id: "ev-3-walk", localDate: dates[2], timeBlock: .afternoon, activity: .cityWalk),
            TripEvent(id: "ev-3-dinner", localDate: dates[2], timeBlock: .evening, activity: .dinner),
            TripEvent(id: "ev-4-walk", localDate: dates[3], timeBlock: .fullDay, activity: .cityWalk),
            TripEvent(id: "ev-5-depart", localDate: dates[4], timeBlock: .morning, activity: .other),
        ]
        return Trip(
            id: "demo-barcelona", title: "Barselona (örnek)", destination: destination, dates: dates, events: events,
            policy: PackingPolicy(bagType: .cabin, laundryAccess: .no, preference: .light),
            isSyntheticDemo: true, now: now
        )
    }

    /// Synthetic forecast for the first three days only, so days 4–5 show "no data" like a real horizon.
    public static func syntheticWeather(start: LocalDate) -> FixtureWeatherProvider {
        FixtureWeatherProvider([
            FixtureWeatherProvider.day(start, low: 13, high: 19),
            FixtureWeatherProvider.day(start.adding(days: 1), low: 12, high: 18, rain: 0.6),
            FixtureWeatherProvider.day(start.adding(days: 2), low: 15, high: 22),
        ])
    }
}
