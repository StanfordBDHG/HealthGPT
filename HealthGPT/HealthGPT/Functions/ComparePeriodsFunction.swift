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

    func execute() async throws -> String? {
        guard let period1Start, let period1End, let period2Start, let period2End else {
            return "Error: period1Start, period1End, period2Start, and period2End are all required (non-negative integer days ago)."
        }

        let period1Range: (start: Date, end: Date)
        let period2Range: (start: Date, end: Date)
        do {
            period1Range = try Self.resolveRange(start: period1Start, end: period1End, relativeTo: .now)
            period2Range = try Self.resolveRange(start: period2Start, end: period2End, relativeTo: .now)
        } catch {
            return "Error: period offsets must be non-negative days."
        }

        let period1Mean = try await averageValue(for: metric, from: period1Range.start, to: period1Range.end)
        let period2Mean = try await averageValue(for: metric, from: period2Range.start, to: period2Range.end)

        let period1Label = "Period 1 (\(Self.format(range: period1Range)))"
        let period2Label = "Period 2 (\(Self.format(range: period2Range)))"

        switch (period1Mean, period2Mean) {
        case (nil, nil):
            return "\(metric.displayName) comparison: no data in either period."
        case let (nil, baseline?):
            return """
            \(metric.displayName) comparison:
            \(period1Label): no data
            \(period2Label): avg \(String(format: "%.1f", baseline))
            """
        case let (current?, nil):
            return """
            \(metric.displayName) comparison:
            \(period1Label): avg \(String(format: "%.1f", current))
            \(period2Label): no data
            """
        case let (current?, baseline?):
            let difference = current - baseline
            let percentChangeLabel = Self.percentChange(current: current, baseline: baseline)
                .map { String(format: "%+.1f%%", $0) } ?? "no baseline data"
            return """
            \(metric.displayName) comparison:
            \(period1Label): avg \(String(format: "%.1f", current))
            \(period2Label): avg \(String(format: "%.1f", baseline))
            Difference: \(String(format: "%+.1f", difference)) (\(percentChangeLabel))
            """
        }
    }

    private static func format(range: (start: Date, end: Date)) -> String {
        let style = Date.FormatStyle.dateTime.month(.abbreviated).day()
        return "\(range.start.formatted(style)) - \(range.end.formatted(style))"
    }

    static func resolveRange(
        start: Int,
        end: Int,
        relativeTo now: Date,
        calendar: Calendar = .current
    ) throws -> (start: Date, end: Date) {
        guard start >= 0, end >= 0 else {
            throw HealthDataFetcherError.invalidDateRange
        }
        guard let startDate = calendar.date(byAdding: .day, value: -max(start, end), to: now),
              let endDate = calendar.date(byAdding: .day, value: -min(start, end), to: now) else {
            throw HealthDataFetcherError.invalidDateRange
        }
        return (startDate, endDate)
    }

    static func percentChange(current: Double, baseline: Double) -> Double? {
        guard baseline != 0 else {
            return nil
        }
        return ((current - baseline) / baseline) * 100
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
