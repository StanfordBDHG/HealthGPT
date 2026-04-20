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

        let period1 = try Self.resolveRange(start: period1Start, end: period1End, relativeTo: .now)
        let period2 = try Self.resolveRange(start: period2Start, end: period2End, relativeTo: .now)

        let period1Average = try await fetchAverage(for: metric, from: period1.start, to: period1.end)
        let period2Average = try await fetchAverage(for: metric, from: period2.start, to: period2.end)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"

        let period1Label = "\(dateFormatter.string(from: period1.start)) - \(dateFormatter.string(from: period1.end))"
        let period2Label = "\(dateFormatter.string(from: period2.start)) - \(dateFormatter.string(from: period2.end))"

        let difference = period1Average - period2Average
        let percentChangeLabel = Self.percentChange(current: period1Average, baseline: period2Average)
            .map { String(format: "%+.1f%%", $0) } ?? "no baseline data"

        return """
        \(metric.displayName) comparison:
        Period 1 (\(period1Label)): avg \(String(format: "%.1f", period1Average))
        Period 2 (\(period2Label)): avg \(String(format: "%.1f", period2Average))
        Difference: \(String(format: "%+.1f", difference)) (\(percentChangeLabel))
        """
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

    private func fetchAverage(for metric: HealthMetric, from startDate: Date, to endDate: Date) async throws -> Double {
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
