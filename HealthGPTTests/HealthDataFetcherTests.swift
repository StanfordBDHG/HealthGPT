//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
@testable import HealthGPT
import Testing

@Suite("Health Data Fetcher Tests")
struct HealthDataFetcherTests {
    private typealias Session = (endDate: Date, totalTimeSpentAsleep: TimeInterval)

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }()

    private static func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.timeZone = TimeZone(identifier: "UTC")
        return calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }

    private static func at(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(identifier: "UTC")
        return calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }

    @Test
    func attributesSessionsToTheCalendarDayTheyEndedOn() {
        // Two sessions that began the previous evening but ended on the subject day.
        let sessions: [Session] = [
            (endDate: Self.at(2026, 4, 19, 6), totalTimeSpentAsleep: 8 * 3600),
            (endDate: Self.at(2026, 4, 20, 7), totalTimeSpentAsleep: 7.5 * 3600)
        ]

        let result = HealthDataFetcher.bucketSleepSessionsByEndDay(
            sessions: sessions,
            startDay: Self.day(2026, 4, 19),
            endDay: Self.day(2026, 4, 21),
            calendar: Self.calendar
        )

        #expect(result.count == 2)
        #expect(result[0].date == Self.day(2026, 4, 19))
        #expect(result[0].hours == 8)
        #expect(result[1].date == Self.day(2026, 4, 20))
        #expect(result[1].hours == 7.5)
    }

    @Test
    func sumsMultipleSessionsEndingOnTheSameDay() {
        let sessions: [Session] = [
            (endDate: Self.at(2026, 4, 20, 2), totalTimeSpentAsleep: 4 * 3600),
            (endDate: Self.at(2026, 4, 20, 14), totalTimeSpentAsleep: 1.5 * 3600)
        ]

        let result = HealthDataFetcher.bucketSleepSessionsByEndDay(
            sessions: sessions,
            startDay: Self.day(2026, 4, 20),
            endDay: Self.day(2026, 4, 21),
            calendar: Self.calendar
        )

        #expect(result.count == 1)
        #expect(result[0].hours == 5.5)
    }

    @Test
    func emitsZeroHoursForDaysWithoutSessions() {
        let result = HealthDataFetcher.bucketSleepSessionsByEndDay(
            sessions: [],
            startDay: Self.day(2026, 4, 18),
            endDay: Self.day(2026, 4, 21),
            calendar: Self.calendar
        )

        #expect(result.count == 3)
        #expect(result.map(\.date) == [Self.day(2026, 4, 18), Self.day(2026, 4, 19), Self.day(2026, 4, 20)])
        #expect(result.allSatisfy { $0.hours == 0 })
    }

    @Test
    func ignoresSessionsOutsideTheRequestedRange() {
        // Sessions ending before startDay or on/after endDay should not leak into the output.
        let sessions: [Session] = [
            (endDate: Self.at(2026, 4, 18, 7), totalTimeSpentAsleep: 9 * 3600),
            (endDate: Self.at(2026, 4, 20, 6), totalTimeSpentAsleep: 6 * 3600),
            (endDate: Self.at(2026, 4, 21, 6), totalTimeSpentAsleep: 4 * 3600)
        ]

        let result = HealthDataFetcher.bucketSleepSessionsByEndDay(
            sessions: sessions,
            startDay: Self.day(2026, 4, 19),
            endDay: Self.day(2026, 4, 21),
            calendar: Self.calendar
        )

        #expect(result.count == 2)
        #expect(result[0].date == Self.day(2026, 4, 19))
        #expect(result[0].hours == 0)
        #expect(result[1].date == Self.day(2026, 4, 20))
        #expect(result[1].hours == 6)
    }

    @Test
    func attributesMidnightEndedSessionToThatDay() {
        // A session ending exactly at 00:00 falls into that calendar day (startOfDay returns it unchanged).
        let sessions: [Session] = [
            (endDate: Self.day(2026, 4, 20), totalTimeSpentAsleep: 5 * 3600)
        ]

        let result = HealthDataFetcher.bucketSleepSessionsByEndDay(
            sessions: sessions,
            startDay: Self.day(2026, 4, 20),
            endDay: Self.day(2026, 4, 21),
            calendar: Self.calendar
        )

        #expect(result.count == 1)
        #expect(result[0].hours == 5)
    }
}
