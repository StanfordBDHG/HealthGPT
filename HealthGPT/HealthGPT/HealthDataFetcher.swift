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
    private static let sleepWindowHour = 15
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

    /// Fetches sleep data for an arbitrary date range using 3PM-3PM sleep windows.
    ///
    /// - Parameters:
    ///   - startDate: The start of the date range.
    ///   - endDate: The end of the date range.
    /// - Returns: An array of tuples containing the date and sleep hours for each day.
    func fetchSleepData(from startDate: Date, to endDate: Date) async throws -> [(date: Date, hours: Double)] {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)

        // Build the full query range: sleepWindowHour the day before startDay through sleepWindowHour on the last day.
        guard let queryStart = calendar.date(bySettingHour: Self.sleepWindowHour, minute: 0, second: 0, of:
                    calendar.date(byAdding: .day, value: -1, to: startDay) ?? startDay),
              let queryEnd = calendar.date(bySettingHour: Self.sleepWindowHour, minute: 0, second: 0, of: endDay) else {
            return []
        }

        // Single HealthKit query for the entire range.
        let asleepPredicate = HKCategoryValueSleepAnalysis.predicateForSamples(
            equalTo: HKCategoryValueSleepAnalysis.allAsleepValues
        )
        let allSamples = try await healthKit.query(
            .sleepAnalysis,
            timeRange: HealthKitQueryTimeRange(queryStart..<queryEnd),
            predicate: asleepPredicate
        )

        let sessions = try allSamples.splitIntoSleepSessions().map {
            SleepInterval(startDate: $0.startDate, endDate: $0.endDate, totalTimeSpentAsleep: $0.totalTimeSpentAsleep)
        }

        return Self.bucketSleepSessions(sessions: sessions, startDay: startDay, endDay: endDay, calendar: calendar)
    }

    struct SleepInterval: Sendable {
        let startDate: Date
        let endDate: Date
        let totalTimeSpentAsleep: TimeInterval
    }

    static func bucketSleepSessions(
        sessions: [SleepInterval],
        startDay: Date,
        endDay: Date,
        calendar: Calendar = .current
    ) -> [(date: Date, hours: Double)] {
        var dailySleepData: [(date: Date, hours: Double)] = []
        var currentDay = startDay
        while currentDay < endDay {
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay),
                  let startOfSleep = calendar.date(bySettingHour: sleepWindowHour, minute: 0, second: 0, of: previousDay),
                  let endOfSleep = calendar.date(bySettingHour: sleepWindowHour, minute: 0, second: 0, of: currentDay) else {
                dailySleepData.append((date: currentDay, hours: 0))
                currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? endDay
                continue
            }

            // Clip each session to the window so a session that straddles the 3 PM boundary
            // doesn't get fully counted in both adjacent days.
            let secondsAsleep = sessions.reduce(0.0) { partial, session in
                let overlapStart = max(session.startDate, startOfSleep)
                let overlapEnd = min(session.endDate, endOfSleep)
                guard overlapEnd > overlapStart else {
                    return partial
                }
                let sessionDuration = session.endDate.timeIntervalSince(session.startDate)
                guard sessionDuration > 0 else {
                    return partial
                }
                let proportion = min(1, overlapEnd.timeIntervalSince(overlapStart) / sessionDuration)
                return partial + session.totalTimeSpentAsleep * proportion
            }

            dailySleepData.append((date: currentDay, hours: secondsAsleep / (60 * 60)))
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? endDay
        }

        return dailySleepData
    }

}
