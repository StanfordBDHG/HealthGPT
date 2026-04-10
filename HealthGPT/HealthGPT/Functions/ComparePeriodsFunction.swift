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

    @Parameter(description: "Start of period 1 in days ago (e.g. 7 means 7 days ago)") var period1Start: Int

    @Parameter(description: "End of period 1 in days ago (e.g. 0 means today)") var period1End: Int

    @Parameter(description: "Start of period 2 in days ago") var period2Start: Int

    @Parameter(description: "End of period 2 in days ago") var period2End: Int

    nonisolated(unsafe) let healthDataFetcher: HealthDataFetcher

    func execute() async throws -> String? {
        let calendar = Calendar.current

        guard let period1StartDate = calendar.date(byAdding: .day, value: -max(period1Start, period1End), to: .now),
              let period1EndDate = calendar.date(byAdding: .day, value: -min(period1Start, period1End), to: .now),
              let period2StartDate = calendar.date(byAdding: .day, value: -max(period2Start, period2End), to: .now),
              let period2EndDate = calendar.date(byAdding: .day, value: -min(period2Start, period2End), to: .now) else {
            throw HealthDataFetcherError.invalidDateRange
        }

        let period1Average = try await fetchAverage(for: metric, from: period1StartDate, to: period1EndDate)
        let period2Average = try await fetchAverage(for: metric, from: period2StartDate, to: period2EndDate)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"

        let period1Label = "\(dateFormatter.string(from: period1StartDate)) - \(dateFormatter.string(from: period1EndDate))"
        let period2Label = "\(dateFormatter.string(from: period2StartDate)) - \(dateFormatter.string(from: period2EndDate))"

        let difference = period1Average - period2Average
        let percentChange: Double? = period2Average != 0 ? (difference / period2Average) * 100 : nil
        let percentChangeLabel = percentChange.map { String(format: "%+.1f%%", $0) } ?? "no baseline data"

        return """
        \(metric.displayName) comparison:
        Period 1 (\(period1Label)): avg \(String(format: "%.1f", period1Average))
        Period 2 (\(period2Label)): avg \(String(format: "%.1f", period2Average))
        Difference: \(String(format: "%+.1f", difference)) (\(percentChangeLabel))
        """
    }

    private func fetchAverage(for metric: HealthMetric, from startDate: Date, to endDate: Date) async throws -> Double {
        if metric == .sleep {
            let data = try await healthDataFetcher.fetchSleepData(from: startDate, to: endDate)
            let values = data.map(\.hours)
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        } else {
            guard let sampleType = metric.sampleType,
                  let aggregation = metric.aggregation else {
                throw HealthDataFetcherError.unsupportedMetric
            }

            let data = try await healthDataFetcher.fetchQuantityData(
                for: sampleType,
                aggregatedBy: aggregation,
                from: startDate,
                to: endDate
            )
            let values = data.map(\.value)
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        }
    }
}
