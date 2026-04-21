//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SpeziHealthKit


// HealthKit access is thread-safe; the only mutable state is the @Observable registrar,
// which is itself thread-safe. Matches the @unchecked Sendable pattern used by SpeziHealthKit's HealthKit.
@Observable
final class HealthDataFetcher: DefaultInitializable, Module, EnvironmentAccessible, @unchecked Sendable {
    static let defaultLookbackDays = 14
    @ObservationIgnored @Dependency(HealthKit.self) private var healthKit

    required init() { }

    // MARK: - Flexible Date-Range Queries

    /// Fetches quantity data for an arbitrary date range, returning daily values with dates.
    ///
    /// - Parameters:
    ///   - metric: The health metric to fetch.
    ///   - startDate: The start of the date range.
    ///   - endDate: The end of the date range.
    /// - Returns: An array of tuples containing the date and value for each day.
    func fetchQuantityData(
        for metric: HealthMetric,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [(date: Date, value: Double)] {
        guard let sampleType = metric.sampleType else {
            throw HealthDataFetcherError.unsupportedMetric
        }
        let timeRange = HealthKitQueryTimeRange(startDate..<endDate)
        let unit = sampleType.displayUnit
        let statistics: [HKStatistics]

        switch metric {
        case .steps, .activeEnergy, .exerciseMinutes:
            statistics = try await healthKit.statisticsQuery(
                sampleType,
                aggregatedBy: [.sum],
                over: .day,
                timeRange: timeRange
            )
        case .bodyWeight, .restingHeartRate:
            statistics = try await healthKit.statisticsQuery(
                sampleType,
                aggregatedBy: [.average],
                over: .day,
                timeRange: timeRange
            )
        case .sleep:
            throw HealthDataFetcherError.unsupportedMetric
        }

        return try statistics.map { stat in
            (date: stat.startDate, value: try metric.quantityValue(from: stat, unit: unit))
        }
    }

    /// Fetches sleep data for an arbitrary date range, attributing each sleep session to the calendar day it ended on.
    ///
    /// - Parameters:
    ///   - startDate: The start of the date range.
    ///   - endDate: The end of the date range.
    /// - Returns: An array of tuples containing the date and sleep hours for each day.
    func fetchSleepData(from startDate: Date, to endDate: Date) async throws -> [(date: Date, hours: Double)] {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)

        // Look back a day so a session whose wake-up is on startDay but began the previous evening is fully captured.
        guard let queryStart = calendar.date(byAdding: .day, value: -1, to: startDay) else {
            throw HealthDataFetcherError.invalidDateRange
        }

        let samples = try await healthKit.query(
            .sleepAnalysis,
            timeRange: HealthKitQueryTimeRange(queryStart..<endDay)
        )
        let sessions = try samples.splitIntoSleepSessions()

        let secondsByDay = Dictionary(
            sessions.map { (calendar.startOfDay(for: $0.endDate), $0.totalTimeSpentAsleep) },
            uniquingKeysWith: +
        )

        var result: [(date: Date, hours: Double)] = []
        var day = startDay
        while day < endDay {
            result.append((date: day, hours: (secondsByDay[day] ?? 0) / 3600))
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return result
    }
}
