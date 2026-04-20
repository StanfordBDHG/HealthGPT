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
        period2Start=14, period2End=7 means the 7 days before that.
        """

    @Parameter(description: "The health metric to compare") var metric: HealthMetric

    @Parameter(description: "Start of period 1 in days ago (e.g. 7 means 7 days ago)", minimum: 0) var period1Start: Int?

    @Parameter(description: "End of period 1 in days ago (e.g. 0 means today)", minimum: 0) var period1End: Int?

    @Parameter(description: "Start of period 2 in days ago", minimum: 0) var period2Start: Int?

    @Parameter(description: "End of period 2 in days ago", minimum: 0) var period2End: Int?

    let healthDataFetcher: HealthDataFetcher

    func execute() async throws -> String? {
        guard let period1Start, let period1End, let period2Start, let period2End else {
            throw HealthDataFetcherError.invalidDateRange
        }

        let period1Range = try Self.resolveRange(start: period1Start, end: period1End, relativeTo: .now)
        let period2Range = try Self.resolveRange(start: period2Start, end: period2End, relativeTo: .now)

        let period1Mean = try await averageValue(for: metric, from: period1Range.start, to: period1Range.end)
        let period2Mean = try await averageValue(for: metric, from: period2Range.start, to: period2Range.end)

        let difference = period1Mean - period2Mean
        let percentChangeLabel = Self.percentChange(current: period1Mean, baseline: period2Mean)
            .map { String(format: "%+.1f%%", $0) } ?? "no baseline data"

        return """
        \(metric.displayName) comparison:
        Period 1 (\(Self.format(range: period1Range))): avg \(String(format: "%.1f", period1Mean))
        Period 2 (\(Self.format(range: period2Range))): avg \(String(format: "%.1f", period2Mean))
        Difference: \(String(format: "%+.1f", difference)) (\(percentChangeLabel))
        """
    }

    private static func format(range: (start: Date, end: Date)) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: range.start)) - \(formatter.string(from: range.end))"
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

    private func averageValue(for metric: HealthMetric, from startDate: Date, to endDate: Date) async throws -> Double {
        if metric == .sleep {
            let data = try await healthDataFetcher.fetchSleepData(from: startDate, to: endDate)
            let values = data.map(\.hours)
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        } else {
            let data = try await healthDataFetcher.fetchQuantityData(
                for: metric,
                from: startDate,
                to: endDate
            )
            let values = data.map(\.value)
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        }
    }
}
