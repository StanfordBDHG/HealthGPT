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
    private typealias Session = HealthDataFetcher.SleepInterval

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
    func bucketsSessionsIntoThreePmWindows() {
        // 10 PM Apr 18 → 6 AM Apr 19 belongs to the Apr 19 window (15:00 Apr 18 – 15:00 Apr 19).
        // 11 PM Apr 19 → 7 AM Apr 20 belongs to the Apr 20 window.
        let sessions: [Session] = [
            Session(startDate: Self.at(2026, 4, 18, 22), endDate: Self.at(2026, 4, 19, 6), totalTimeSpentAsleep: 8 * 60 * 60),
            Session(startDate: Self.at(2026, 4, 19, 23), endDate: Self.at(2026, 4, 20, 7), totalTimeSpentAsleep: 7.5 * 60 * 60)
        ]

        let result = HealthDataFetcher.bucketSleepSessions(
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
    func excludesSessionsOutsideEachDayWindow() {
        // 8 AM Apr 19 ends before the 3 PM boundary that opens the Apr 20 window — it must not leak forward.
        let sessions: [Session] = [
            Session(startDate: Self.at(2026, 4, 19, 4), endDate: Self.at(2026, 4, 19, 8), totalTimeSpentAsleep: 4 * 60 * 60)
        ]

        let result = HealthDataFetcher.bucketSleepSessions(
            sessions: sessions,
            startDay: Self.day(2026, 4, 20),
            endDay: Self.day(2026, 4, 21),
            calendar: Self.calendar
        )

        #expect(result.count == 1)
        #expect(result[0].hours == 0)
    }

    @Test
    func sumsOverlappingSessionsWithinSameWindow() {
        let sessions: [Session] = [
            Session(startDate: Self.at(2026, 4, 19, 22), endDate: Self.at(2026, 4, 20, 2), totalTimeSpentAsleep: 4 * 60 * 60),
            Session(startDate: Self.at(2026, 4, 20, 3), endDate: Self.at(2026, 4, 20, 6), totalTimeSpentAsleep: 3 * 60 * 60)
        ]

        let result = HealthDataFetcher.bucketSleepSessions(
            sessions: sessions,
            startDay: Self.day(2026, 4, 20),
            endDay: Self.day(2026, 4, 21),
            calendar: Self.calendar
        )

        #expect(result.count == 1)
        #expect(result[0].hours == 7)
    }

    @Test
    func clipsSessionsThatStraddleThreePmBoundary() {
        // Session 11 AM → 7 PM Apr 20 (8 h elapsed, 6 h asleep) crosses the 3 PM boundary.
        // Apr 20 window (15:00 Apr 19 – 15:00 Apr 20) overlaps 11 AM – 3 PM (4 h of 8 h).
        // Apr 21 window (15:00 Apr 20 – 15:00 Apr 21) overlaps 3 PM – 7 PM (4 h of 8 h).
        // Each window should receive half of the 6 h asleep, not the full 6 h.
        let sessions: [Session] = [
            Session(startDate: Self.at(2026, 4, 20, 11), endDate: Self.at(2026, 4, 20, 19), totalTimeSpentAsleep: 6 * 60 * 60)
        ]

        let result = HealthDataFetcher.bucketSleepSessions(
            sessions: sessions,
            startDay: Self.day(2026, 4, 20),
            endDay: Self.day(2026, 4, 22),
            calendar: Self.calendar
        )

        #expect(result.count == 2)
        #expect(result[0].hours == 3)
        #expect(result[1].hours == 3)
    }

    @Test
    func emitsZeroHoursForDaysWithoutSessions() {
        let result = HealthDataFetcher.bucketSleepSessions(
            sessions: [],
            startDay: Self.day(2026, 4, 18),
            endDay: Self.day(2026, 4, 21),
            calendar: Self.calendar
        )

        #expect(result.count == 3)
        #expect(result.allSatisfy { $0.hours == 0 })
    }
}
