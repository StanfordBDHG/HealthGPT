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
        body weight, resting heart rate, or sleep data. \
        The `days` parameter is required and must be between 1 and 90.
        """

    @Parameter(description: "The health metric to fetch") var metric: HealthMetric

    @Parameter(description: "Number of past days to fetch (1-90, required)", minimum: 1, maximum: 90) var days: Int?

    let healthDataFetcher: HealthDataFetcher

    func execute() async throws -> String? {
        guard let days else {
            return "Error: `days` is required. Provide an integer between 1 and 90."
        }
        guard (1...90).contains(days) else {
            return "Error: `days` must be between 1 and 90 (received \(days))."
        }

        let endDate = Date.now
        guard let startDate = Calendar.current.date(byAdding: .day, value: -days, to: endDate) else {
            throw HealthDataFetcherError.invalidDateRange
        }

        if metric == .sleep {
            let data = try await healthDataFetcher.fetchSleepData(from: startDate, to: endDate)
            let lines = data.map {
                "\($0.date.formatted(.iso8601.year().month().day())): \(String(format: "%.1f", $0.hours)) hours"
            }
            return "\(metric.displayName) for the last \(days) days:\n" + lines.joined(separator: "\n")
        } else {
            let data = try await healthDataFetcher.fetchQuantityData(
                for: metric,
                from: startDate,
                to: endDate
            )

            let unit = metric.unitLabel
            let lines = data.map {
                "\($0.date.formatted(.iso8601.year().month().day())): \(String(format: "%.1f", $0.value)) \(unit)"
            }
            return "\(metric.displayName) for the last \(days) days:\n" + lines.joined(separator: "\n")
        }
    }
}
