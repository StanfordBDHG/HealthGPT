//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziLLMOpenAI


struct ComparePeriodsFunction: LLMFunction {
    struct PeriodOffsets: Equatable, Sendable {
        let period1Start: Int
        let period1End: Int
        let period2Start: Int
        let period2End: Int
    }

    enum OffsetsResolution: Equatable, Sendable {
        case resolved(PeriodOffsets)
        case missing(message: String)
    }

    static let name: String = "compare_periods"
    static let description: String = """
        Compare a health metric between two time periods. \
        Specify each period as days ago from today. \
        For example, period1Start=7, period1End=0 means the last 7 days; \
        period2Start=14, period2End=7 means the 7 days before that. \
        All four period parameters are required.
        """

    @Parameter(description: "The health metric to compare") var metric: HealthMetric

    @Parameter(description: "Start of period 1 in days ago (required, e.g. 7 means 7 days ago)", minimum: 0) var period1Start: Int?

    @Parameter(description: "End of period 1 in days ago (required, e.g. 0 means today)", minimum: 0) var period1End: Int?

    @Parameter(description: "Start of period 2 in days ago (required)", minimum: 0) var period2Start: Int?

    @Parameter(description: "End of period 2 in days ago (required)", minimum: 0) var period2End: Int?

    let healthDataFetcher: HealthDataFetcher

    static func resolvePeriodOffsets(
        period1Start: Int?,
        period1End: Int?,
        period2Start: Int?,
        period2End: Int?
    ) -> OffsetsResolution {
        guard let period1Start, let period1End, let period2Start, let period2End else {
            let message = "Error: period1Start, period1End, period2Start, and "
                + "period2End are all required (non-negative integer days ago)."
            return .missing(message: message)
        }
        return .resolved(
            PeriodOffsets(
                period1Start: period1Start,
                period1End: period1End,
                period2Start: period2Start,
                period2End: period2End
            )
        )
    }

    private static func formatDateRange(_ range: (start: Date, end: Date)) -> String {
        let style = Date.FormatStyle.dateTime.month(.abbreviated).day()
        return "\(range.start.formatted(style)) - \(range.end.formatted(style))"
    }

    static func resolveRange(
        startDaysAgo: Int,
        endDaysAgo: Int,
        relativeTo now: Date,
        calendar: Calendar = .current
    ) throws -> (start: Date, end: Date) {
        guard startDaysAgo >= 0, endDaysAgo >= 0 else {
            throw HealthDataFetcherError.invalidDateRange
        }
        guard let startDate = calendar.date(byAdding: .day, value: -max(startDaysAgo, endDaysAgo), to: now),
              let endDate = calendar.date(byAdding: .day, value: -min(startDaysAgo, endDaysAgo), to: now) else {
            throw HealthDataFetcherError.invalidDateRange
        }
        return (startDate, endDate)
    }

    static func resolveRanges(
        from offsets: PeriodOffsets,
        relativeTo now: Date,
        calendar: Calendar = .current
    ) throws -> (period1: (start: Date, end: Date), period2: (start: Date, end: Date)) {
        let period1Range = try Self.resolveRange(
            startDaysAgo: offsets.period1Start,
            endDaysAgo: offsets.period1End,
            relativeTo: now,
            calendar: calendar
        )
        let period2Range = try Self.resolveRange(
            startDaysAgo: offsets.period2Start,
            endDaysAgo: offsets.period2End,
            relativeTo: now,
            calendar: calendar
        )
        return (period1Range, period2Range)
    }

    static func percentChange(current: Double, baseline: Double) -> Double? {
        guard baseline != 0 else {
            return nil
        }
        return ((current - baseline) / baseline) * 100
    }

    func execute() async throws -> String? {
        let offsets: PeriodOffsets
        switch Self.resolvePeriodOffsets(
            period1Start: period1Start,
            period1End: period1End,
            period2Start: period2Start,
            period2End: period2End
        ) {
        case .missing(let message):
            return message
        case .resolved(let resolved):
            offsets = resolved
        }

        let ranges: (period1: (start: Date, end: Date), period2: (start: Date, end: Date))
        do {
            ranges = try Self.resolveRanges(from: offsets, relativeTo: .now)
        } catch {
            return "Error: period offsets must be non-negative days."
        }

        let period1Average = try await averageValue(for: metric, from: ranges.period1.start, to: ranges.period1.end)
        let period2Average = try await averageValue(for: metric, from: ranges.period2.start, to: ranges.period2.end)

        let period1Label = "Period 1 (\(Self.formatDateRange(ranges.period1)))"
        let period2Label = "Period 2 (\(Self.formatDateRange(ranges.period2)))"

        switch (period1Average, period2Average) {
        case (nil, nil):
            return "\(metric.displayName) comparison: no data in either period."
        case let (nil, period2Value?):
            return """
            \(metric.displayName) comparison:
            \(period1Label): no data
            \(period2Label): avg \(String(format: "%.1f", period2Value))
            """
        case let (period1Value?, nil):
            return """
            \(metric.displayName) comparison:
            \(period1Label): avg \(String(format: "%.1f", period1Value))
            \(period2Label): no data
            """
        case let (period1Value?, period2Value?):
            let difference = period1Value - period2Value
            let percentChangeLabel = Self.percentChange(current: period1Value, baseline: period2Value)
                .map { String(format: "%+.1f%%", $0) } ?? "no baseline data"
            return """
            \(metric.displayName) comparison:
            \(period1Label): avg \(String(format: "%.1f", period1Value))
            \(period2Label): avg \(String(format: "%.1f", period2Value))
            Difference: \(String(format: "%+.1f", difference)) (\(percentChangeLabel))
            """
        }
    }

    private func averageValue(for metric: HealthMetric, from startDate: Date, to endDate: Date) async throws -> Double? {
        if metric == .sleep {
            let data = try await healthDataFetcher.fetchSleepData(from: startDate, to: endDate)
            let values = data.map(\.hours)
            guard !values.isEmpty else {
                return nil
            }
            return values.reduce(0, +) / Double(values.count)
        } else {
            let data = try await healthDataFetcher.fetchQuantityData(for: metric, from: startDate, to: endDate)
            let values = data.map(\.value)
            guard !values.isEmpty else {
                return nil
            }
            return values.reduce(0, +) / Double(values.count)
        }
    }
}
