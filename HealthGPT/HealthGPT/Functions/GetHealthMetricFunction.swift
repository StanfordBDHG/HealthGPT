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
    enum MetricType: String, LLMFunctionParameterEnum {
        case steps
        case activeEnergy
        case exerciseMinutes
        case bodyWeight
        case restingHeartRate
        case sleep
    }

    static let name: String = "get_health_metric"
    // swiftlint:disable:next line_length
    static let description: String = "Fetch daily values for a specific health metric over a given number of past days. Use this to retrieve step counts, active energy, exercise minutes, body weight, resting heart rate, or sleep data."

    @Parameter(description: "The health metric to fetch") var metric: MetricType

    @Parameter(description: "Number of past days to fetch (1-90)") var days: String

    nonisolated(unsafe) let healthDataFetcher: HealthDataFetcher

    func execute() async throws -> String? {
        let clampedDays = max(1, min(Int(days) ?? 7, 90))
        let endDate = Date()
        guard let startDate = Calendar.current.date(byAdding: .day, value: -clampedDays, to: endDate) else {
            return "Error: Could not calculate date range."
        }

        let healthMetric = HealthMetric(rawValue: metric.rawValue) ?? .steps
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if healthMetric == .sleep {
            let data = try await healthDataFetcher.fetchSleepData(from: startDate, to: endDate)
            let lines = data.map { "\(dateFormatter.string(from: $0.date)): \(String(format: "%.1f", $0.hours)) hours" }
            return "\(healthMetric.displayName) for the last \(clampedDays) days:\n" + lines.joined(separator: "\n")
        } else {
            guard let identifier = healthMetric.identifier,
                  let unit = healthMetric.unit,
                  let options = healthMetric.options else {
                return "Error: Unsupported metric."
            }

            let data = try await healthDataFetcher.fetchQuantityData(
                for: identifier,
                unit: unit,
                options: options,
                from: startDate,
                to: endDate
            )

            let lines = data.map { "\(dateFormatter.string(from: $0.date)): \(String(format: "%.1f", $0.value))" }
            return "\(healthMetric.displayName) for the last \(clampedDays) days:\n" + lines.joined(separator: "\n")
        }
    }
}
