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
    enum MetricType: String, LLMFunctionParameterEnum {
        case steps
        case activeEnergy
        case exerciseMinutes
        case bodyWeight
        case restingHeartRate
        case sleep
    }

    static let name: String = "compare_periods"
    // swiftlint:disable:next line_length
    static let description: String = "Compare a health metric between two time periods. Specify each period as days ago from today. For example, period1Start=7, period1End=0 means the last 7 days; period2Start=14, period2End=7 means the 7 days before that."

    @Parameter(description: "The health metric to compare") var metric: MetricType

    @Parameter(description: "Start of period 1 in days ago (e.g. 7 means 7 days ago)") var period1Start: String

    @Parameter(description: "End of period 1 in days ago (e.g. 0 means today)") var period1End: String

    @Parameter(description: "Start of period 2 in days ago") var period2Start: String

    @Parameter(description: "End of period 2 in days ago") var period2End: String

    nonisolated(unsafe) let healthDataFetcher: HealthDataFetcher

    func execute() async throws -> String? {
        let now = Date()
        let calendar = Calendar.current
        let healthMetric = HealthMetric(rawValue: metric.rawValue) ?? .steps

        let p1s = Int(period1Start) ?? 7
        let p1e = Int(period1End) ?? 0
        let p2s = Int(period2Start) ?? 14
        let p2e = Int(period2End) ?? 7

        guard let p1Start = calendar.date(byAdding: .day, value: -max(p1s, p1e), to: now),
              let p1End = calendar.date(byAdding: .day, value: -min(p1s, p1e), to: now),
              let p2Start = calendar.date(byAdding: .day, value: -max(p2s, p2e), to: now),
              let p2End = calendar.date(byAdding: .day, value: -min(p2s, p2e), to: now) else {
            return "Error: Could not calculate date ranges."
        }

        let avg1 = try await fetchAverage(for: healthMetric, from: p1Start, to: p1End)
        let avg2 = try await fetchAverage(for: healthMetric, from: p2Start, to: p2End)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"

        let period1Label = "\(dateFormatter.string(from: p1Start)) - \(dateFormatter.string(from: p1End))"
        let period2Label = "\(dateFormatter.string(from: p2Start)) - \(dateFormatter.string(from: p2End))"

        let diff = avg1 - avg2
        let percentChange = avg2 != 0 ? (diff / avg2) * 100 : 0

        return """
        \(healthMetric.displayName) comparison:
        Period 1 (\(period1Label)): avg \(String(format: "%.1f", avg1))
        Period 2 (\(period2Label)): avg \(String(format: "%.1f", avg2))
        Difference: \(String(format: "%+.1f", diff)) (\(String(format: "%+.1f", percentChange))%)
        """
    }

    private func fetchAverage(for metric: HealthMetric, from startDate: Date, to endDate: Date) async throws -> Double {
        if metric == .sleep {
            let data = try await healthDataFetcher.fetchSleepData(from: startDate, to: endDate)
            let values = data.map(\.hours)
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        } else {
            guard let identifier = metric.identifier,
                  let unit = metric.unit,
                  let options = metric.options else {
                return 0
            }

            let data = try await healthDataFetcher.fetchQuantityData(
                for: identifier,
                unit: unit,
                options: options,
                from: startDate,
                to: endDate
            )
            let values = data.map(\.value)
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        }
    }
}
