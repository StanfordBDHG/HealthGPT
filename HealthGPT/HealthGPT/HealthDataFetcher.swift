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


@Observable
class HealthDataFetcher: DefaultInitializable, Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency(HealthKit.self) private var healthKit

    required init() { }
    

    private static let defaultLookbackDays = 14

    // MARK: - Flexible Date-Range Queries

    /// Fetches quantity data for an arbitrary date range, returning daily values with dates.
    ///
    /// - Parameters:
    ///   - sampleType: The `SampleType` representing the type of health data to fetch.
    ///   - aggregatedBy: The aggregation mode to use (e.g., `.sum` or `.average`).
    ///   - startDate: The start of the date range.
    ///   - endDate: The end of the date range.
    /// - Returns: An array of tuples containing the date and value for each day.
    func fetchQuantityData(
        for sampleType: SampleType<HKQuantitySample>,
        aggregatedBy aggregation: SpeziHealthKit.StatisticsAggregationOption,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [(date: Date, value: Double)] {
        let timeRange = HealthKitQueryTimeRange(startDate..<endDate)
        let unit = sampleType.displayUnit
        let statistics = try await healthKit.statisticsQuery(sampleType, aggregatedBy: [aggregation], over: .day, timeRange: timeRange)

        return statistics.map { stat in
            let value: Double = switch aggregation {
            case .sum: stat.sumQuantity()?.doubleValue(for: unit) ?? 0
            case .average: stat.averageQuantity()?.doubleValue(for: unit) ?? 0
            }
            return (date: stat.startDate, value: value)
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

        // Build the full query range: 3 PM the day before startDay through 3 PM on the last day.
        guard let queryStart = calendar.date(bySettingHour: 15, minute: 0, second: 0, of:
                    calendar.date(byAdding: .day, value: -1, to: startDay) ?? startDay),
              let queryEnd = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: endDay) else {
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

        // Split samples into sessions for proper overlap handling.
        let sleepSessions = try allSamples.splitIntoSleepSessions()

        // Bucket sessions into per-day 3 PM–3 PM windows.
        var dailySleepData: [(date: Date, hours: Double)] = []
        var currentDay = startDay
        while currentDay < endDay {
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay),
                  let startOfSleep = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: previousDay),
                  let endOfSleep = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: currentDay) else {
                dailySleepData.append((date: currentDay, hours: 0))
                currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? endDay
                continue
            }

            let secondsAsleep = sleepSessions
                .filter { $0.startDate < endOfSleep && $0.endDate > startOfSleep }
                .reduce(0.0) { $0 + $1.totalTimeSpentAsleep }

            dailySleepData.append((date: currentDay, hours: secondsAsleep / (60 * 60)))
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? endDay
        }

        return dailySleepData
    }

    // MARK: - Last Two Weeks Convenience Methods

    /// Fetches the user's step count data for the last two weeks.
    func fetchLastTwoWeeksStepCount() async throws -> [Double] {
        try await fetchLastTwoWeeksData(for: .stepCount, aggregatedBy: .sum)
    }

    /// Fetches the user's active energy burned data for the last two weeks.
    func fetchLastTwoWeeksActiveEnergy() async throws -> [Double] {
        try await fetchLastTwoWeeksData(for: .activeEnergyBurned, aggregatedBy: .sum)
    }

    /// Fetches the user's exercise time data for the last two weeks.
    func fetchLastTwoWeeksExerciseTime() async throws -> [Double] {
        try await fetchLastTwoWeeksData(for: .appleExerciseTime, aggregatedBy: .sum)
    }

    /// Fetches the user's body weight data for the last two weeks.
    func fetchLastTwoWeeksBodyWeight() async throws -> [Double] {
        try await fetchLastTwoWeeksData(for: .bodyMass, aggregatedBy: .average)
    }

    /// Fetches the user's resting heart rate data for the last two weeks.
    func fetchLastTwoWeeksRestingHeartRate() async throws -> [Double] {
        try await fetchLastTwoWeeksData(for: .restingHeartRate, aggregatedBy: .average)
    }

    /// Fetches the user's sleep data for the last two weeks.
    func fetchLastTwoWeeksSleep() async throws -> [Double] {
        let endDate = Date.now
        guard let startDate = Calendar.current.date(byAdding: .day, value: -Self.defaultLookbackDays, to: endDate) else {
            return []
        }
        let data = try await fetchSleepData(from: startDate, to: endDate)
        return data.map(\.hours)
    }

    // MARK: - Private Helpers

    private func fetchLastTwoWeeksData(
        for sampleType: SampleType<HKQuantitySample>,
        aggregatedBy aggregation: SpeziHealthKit.StatisticsAggregationOption
    ) async throws -> [Double] {
        let endDate = Date.now
        guard let startDate = Calendar.current.date(byAdding: .day, value: -Self.defaultLookbackDays, to: endDate) else {
            return []
        }
        let data = try await fetchQuantityData(for: sampleType, aggregatedBy: aggregation, from: startDate, to: endDate)
        return data.map(\.value)
    }
}
