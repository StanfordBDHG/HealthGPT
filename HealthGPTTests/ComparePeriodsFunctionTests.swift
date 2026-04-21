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


@Suite("Compare Periods Function Tests")
struct ComparePeriodsFunctionTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
        return calendar
    }()

    private static let referenceDate: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 4
        components.day = 20
        components.hour = 12
        components.timeZone = TimeZone(identifier: "UTC")
        return calendar.date(from: components) ?? Date(timeIntervalSince1970: 0)
    }()

    @Test
    func resolveRangeNormalizesReversedOffsets() throws {
        let inOrder = try ComparePeriodsFunction.resolveRange(startDaysAgo: 7, endDaysAgo: 0, relativeTo: Self.referenceDate, calendar: Self.calendar)
        let reversed = try ComparePeriodsFunction.resolveRange(startDaysAgo: 0, endDaysAgo: 7, relativeTo: Self.referenceDate, calendar: Self.calendar)

        #expect(inOrder.start == reversed.start)
        #expect(inOrder.end == reversed.end)
        #expect(inOrder.start < inOrder.end)
    }

    @Test
    func resolveRangeReturnsExpectedDayOffsets() throws {
        let range = try ComparePeriodsFunction.resolveRange(startDaysAgo: 14, endDaysAgo: 7, relativeTo: Self.referenceDate, calendar: Self.calendar)

        let expectedStart = Self.calendar.date(byAdding: .day, value: -14, to: Self.referenceDate)
        let expectedEnd = Self.calendar.date(byAdding: .day, value: -7, to: Self.referenceDate)

        #expect(range.start == expectedStart)
        #expect(range.end == expectedEnd)
    }

    @Test
    func resolveRangeAllowsZeroLengthWindow() throws {
        let range = try ComparePeriodsFunction.resolveRange(startDaysAgo: 3, endDaysAgo: 3, relativeTo: Self.referenceDate, calendar: Self.calendar)

        #expect(range.start == range.end)
    }

    @Test
    func resolveRangeRejectsNegativeOffsets() {
        #expect(throws: HealthDataFetcherError.invalidDateRange) {
            _ = try ComparePeriodsFunction.resolveRange(startDaysAgo: -1, endDaysAgo: 7, relativeTo: Self.referenceDate, calendar: Self.calendar)
        }
        #expect(throws: HealthDataFetcherError.invalidDateRange) {
            _ = try ComparePeriodsFunction.resolveRange(startDaysAgo: 7, endDaysAgo: -3, relativeTo: Self.referenceDate, calendar: Self.calendar)
        }
    }

    @Test
    func percentChangeReturnsNilWhenBaselineIsZero() {
        #expect(ComparePeriodsFunction.percentChange(current: 1234, baseline: 0) == nil)
    }

    @Test
    func percentChangeComputesSignedRelativeDelta() throws {
        let increase = try #require(ComparePeriodsFunction.percentChange(current: 120, baseline: 100))
        let decrease = try #require(ComparePeriodsFunction.percentChange(current: 80, baseline: 100))
        let unchanged = try #require(ComparePeriodsFunction.percentChange(current: 50, baseline: 50))

        #expect(increase == 20)
        #expect(decrease == -20)
        #expect(unchanged == 0)
    }
}
