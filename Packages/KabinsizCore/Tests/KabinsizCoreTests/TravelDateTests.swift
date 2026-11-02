import Foundation
import Testing
@testable import TravelEngine

@Suite("Travel dates and destinations")
struct TravelDateTests {
    let today = LocalDate("2026-11-03")!

    @Test("T-TRV-003 duplicate city names need disambiguation")
    func duplicateCity() {
        let results = CityDirectory.search("barselona")
        #expect(results.count == 2)
        #expect(Set(results.map(\.timeZoneID)) == ["Europe/Madrid", "America/Caracas"])
        #expect(CityDirectory.search("İZMİR").count == 1)
        #expect(CityDirectory.search("izmir").count == 1)
    }

    @Test("T-TRV-004 destination-local date differs from device date across the date line")
    func timezoneCrossing() {
        // 2026-11-03 20:00 in Istanbul is already 11-04 in Tokyo.
        let instant = ISO8601DateFormatter().date(from: "2026-11-03T17:00:00Z")!
        #expect(LocalDate(instant: instant, timeZone: TimeZone(identifier: "Europe/Istanbul")!).description == "2026-11-03")
        #expect(LocalDate(instant: instant, timeZone: TimeZone(identifier: "Asia/Tokyo")!).description == "2026-11-04")
    }

    @Test("T-TRV-005 five days and five nights are different trips")
    func daysVersusNights() throws {
        #expect(TripLength.days(5).calendarDays == 5)
        #expect(TripLength.nights(5).calendarDays == 6)
        #expect(try TripDates.endDate(start: today, length: .days(5)).get().description == "2026-11-07")
        #expect(try TripDates.endDate(start: today, length: .nights(5)).get().description == "2026-11-08")
    }

    @Test("T-TRV-006 leap-year transition counts Feb 29")
    func leapYear() throws {
        let start = LocalDate("2028-02-28")!
        let days = try TripDates.validate(start: start, end: LocalDate("2028-03-01")!, today: today).get()
        #expect(days.map(\.description) == ["2028-02-28", "2028-02-29", "2028-03-01"])
        #expect(LocalDate(year: 2027, month: 2, day: 29) == nil)
    }

    @Test("T-TRV-007 DST transitions do not add or drop a day", arguments: ["2027-03-26", "2027-10-29"])
    func dst(start: String) throws {
        let s = LocalDate(start)!
        let days = try TripDates.validate(start: s, end: s.adding(days: 4), today: today).get()
        #expect(days.count == 5)
        #expect(Set(days).count == 5)
    }

    @Test("T-TRV-008 invalid and past dates are rejected politely")
    func invalidDates() {
        #expect(TripDates.validate(start: LocalDate("2026-11-01")!, end: LocalDate("2026-11-05")!, today: today) == .failure(.startInPast))
        #expect(TripDates.validate(start: LocalDate("2026-11-10")!, end: LocalDate("2026-11-05")!, today: today) == .failure(.endBeforeStart))
        #expect(TripDates.endDate(start: today, length: .days(0)) == .failure(.zeroLength))
    }

    @Test("T-TRV-009 trips longer than 14 days are clearly refused")
    func maxLength() {
        #expect(TripDates.validate(start: today, end: today.adding(days: 14), today: today) == .failure(.tooLong(maxDays: 14)))
        #expect((try? TripDates.validate(start: today, end: today.adding(days: 13), today: today).get())?.count == 14)
    }

    @Test("Manual destination is marked TIMEZONE_UNVERIFIED")
    func manualDestination() {
        let d = CityDirectory.manual(city: " Kaş ", country: "Türkiye", deviceTimeZone: TimeZone(identifier: "Europe/Istanbul")!)
        #expect(d.city == "Kaş")
        #expect(d.timeZoneVerified == false)
    }

    @Test("Trip lifecycle only allows documented transitions")
    func lifecycle() {
        #expect(TripState.draft.canMove(to: .planned))
        #expect(!TripState.draft.canMove(to: .inTrip))
        #expect(!TripState.archived.canMove(to: .draft))
    }
}
