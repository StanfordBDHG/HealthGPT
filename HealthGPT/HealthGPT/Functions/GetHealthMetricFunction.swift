//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziLLMOpenAI


struct GetHealthMetricFunction: LLMFunction {
    static let name: String = "get_health_metric"
    static let description: String = """
        Fetch daily values for a specific health metric over a given number of past days. \
        Use this to retrieve step counts, active energy, exercise minutes, \
        body weight, resting heart rate, or sleep data.
        """

    @Parameter(description: "The health metric to fetch") var metric: HealthMetric

    @Parameter(description: "Number of past days to fetch (1-90)") var days: Int

    nonisolated(unsafe) let healthDataFetcher: HealthDataFetcher

    func execute() async throws -> String? {
        let clampedDays = max(1, min(days, 90))
        let endDate = Calendar.current.startOfDay(for: .now)
        guard let startDate = Calendar.current.date(byAdding: .day, value: -clampedDays, to: endDate) else {
            throw HealthDataFetcherError.invalidDateRange
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if metric == .sleep {
            let data = try await healthDataFetcher.fetchSleepData(from: startDate, to: endDate)
            let lines = data.map { "\(dateFormatter.string(from: $0.date)): \(String(format: "%.1f", $0.hours)) hours" }
            return "\(metric.displayName) for the last \(clampedDays) days:\n" + lines.joined(separator: "\n")
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

            let unit = metric.unitLabel
            let lines = data.map { "\(dateFormatter.string(from: $0.date)): \(String(format: "%.1f", $0.value)) \(unit)" }
            return "\(metric.displayName) for the last \(clampedDays) days:\n" + lines.joined(separator: "\n")
        }
    }
}
