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
    enum MissingPeriodOffset: CaseIterable, Sendable {
        case period1Start
        case period1End
        case period2Start
        case period2End
    }

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

    @Test(arguments: MissingPeriodOffset.allCases)
    func resolvePeriodOffsetsRequiresEveryOffset(missingOffset: MissingPeriodOffset) throws {
        let result = ComparePeriodsFunction.resolvePeriodOffsets(
            period1Start: missingOffset == .period1Start ? nil : 7,
            period1End: missingOffset == .period1End ? nil : 0,
            period2Start: missingOffset == .period2Start ? nil : 14,
            period2End: missingOffset == .period2End ? nil : 7
        )

        guard case .missing(let message) = result else {
            Issue.record("Expected .missing for missing \(missingOffset)")
            return
        }
        #expect(message.contains("period1Start"))
        #expect(message.contains("period1End"))
        #expect(message.contains("period2Start"))
        #expect(message.contains("period2End"))
        #expect(message.contains("required"))
    }

    @Test
    func resolvePeriodOffsetsHappyPathAssignsFields() throws {
        let result = ComparePeriodsFunction.resolvePeriodOffsets(
            period1Start: 7,
            period1End: 0,
            period2Start: 14,
            period2End: 7
        )

        guard case .resolved(let offsets) = result else {
            Issue.record("Expected .resolved when all offsets are provided")
            return
        }
        #expect(offsets.period1Start == 7)
        #expect(offsets.period1End == 0)
        #expect(offsets.period2Start == 14)
        #expect(offsets.period2End == 7)
    }

    @Test
    func resolveRangesMapsPeriod1AndPeriod2IndependentOffsets() throws {
        let offsets = ComparePeriodsFunction.PeriodOffsets(
            period1Start: 7,
            period1End: 0,
            period2Start: 14,
            period2End: 7
        )

        let ranges = try ComparePeriodsFunction.resolveRanges(
            from: offsets,
            relativeTo: Self.referenceDate,
            calendar: Self.calendar
        )

        let expectedP1Start = Self.calendar.date(byAdding: .day, value: -7, to: Self.referenceDate)
        let expectedP2Start = Self.calendar.date(byAdding: .day, value: -14, to: Self.referenceDate)
        let expectedP2End = Self.calendar.date(byAdding: .day, value: -7, to: Self.referenceDate)

        #expect(ranges.period1.start == expectedP1Start)
        #expect(ranges.period1.end == Self.referenceDate)
        #expect(ranges.period2.start == expectedP2Start)
        #expect(ranges.period2.end == expectedP2End)
    }

    @Test
    func executeReturnsRequiredOffsetsErrorBeforeFetchingData() async throws {
        let function = ComparePeriodsFunction(healthDataFetcher: HealthDataFetcher())

        let result = try await function.execute()

        #expect(result?.contains("period1Start") == true)
        #expect(result?.contains("period1End") == true)
        #expect(result?.contains("period2Start") == true)
        #expect(result?.contains("period2End") == true)
        #expect(result?.contains("required") == true)
    }

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
