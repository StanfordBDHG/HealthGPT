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
    

    /// Fetches the user's health data for the specified quantity type identifier for the last two weeks.
    ///
    /// - Parameters:
    ///   - identifier: The `HKQuantityTypeIdentifier` representing the type of health data to fetch.
    ///   - unit: The `HKUnit` to use for the fetched health data values.
    ///   - options: The `HKStatisticsOptions` to use when fetching the health data.
    /// - Returns: An array of `Double` values representing the daily health data for the specified identifier.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksQuantityData(
        for identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        options: HKStatisticsOptions
    ) async throws -> [Double] {
        let sampleType = SampleType<HKQuantitySample>.quantity(identifier, displayUnit: unit)

        let statistics: [HKStatistics]
        if options.contains(.cumulativeSum) {
            statistics = try await healthKit.statisticsQuery(sampleType, aggregatedBy: [.sum], over: .day, timeRange: .last(days: 14))
        } else {
            statistics = try await healthKit.statisticsQuery(sampleType, aggregatedBy: [.average], over: .day, timeRange: .last(days: 14))
        }

        let calendar = Calendar.current
        var lookup: [Date: Double] = [:]
        for stat in statistics {
            let day = calendar.startOfDay(for: stat.startDate)
            if options.contains(.cumulativeSum) {
                lookup[day] = stat.sumQuantity()?.doubleValue(for: unit) ?? 0
            } else {
                lookup[day] = stat.averageQuantity()?.doubleValue(for: unit) ?? 0
            }
        }

        var dailyData: [Double] = []
        for dayOffset in -14..<0 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: calendar.startOfDay(for: Date())) else {
                dailyData.append(0)
                continue
            }
            dailyData.append(lookup[date] ?? 0)
        }

        return dailyData
    }

    /// Fetches the user's step count data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily step counts.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksStepCount() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .stepCount,
            unit: HKUnit.count(),
            options: [.cumulativeSum]
        )
    }

    /// Fetches the user's active energy burned data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily active energy burned.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksActiveEnergy() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .activeEnergyBurned,
            unit: HKUnit.largeCalorie(),
            options: [.cumulativeSum]
        )
    }

    /// Fetches the user's exercise time data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily exercise times in minutes.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksExerciseTime() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .appleExerciseTime,
            unit: .minute(),
            options: [.cumulativeSum]
        )
    }

    /// Fetches the user's body weight data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily body weights in pounds.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksBodyWeight() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .bodyMass,
            unit: .pound(),
            options: [.discreteAverage]
        )
    }

    /// Fetches the user's resting heart rate data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily average resting heart rate.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksRestingHeartRate() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .restingHeartRate,
            unit: .count().unitDivided(by: .minute()),
            options: [.discreteAverage]
        )
    }

    /// Fetches the user's sleep data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily sleep duration in hours.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksSleep() async throws -> [Double] {
        var dailySleepData: [Double] = []

        // We go through all possible days in the last two weeks.
        for day in -14..<0 {
            // We start the calculation at 3 PM the previous day to 3 PM on the day in question.
            guard let startOfSleepDay = Calendar.current.date(byAdding: DateComponents(day: day - 1), to: Date.startOfDay()),
                  let startOfSleep = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: startOfSleepDay),
                  let endOfSleepDay = Calendar.current.date(byAdding: DateComponents(day: day), to: Date.startOfDay()),
                  let endOfSleep = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: endOfSleepDay) else {
                dailySleepData.append(0)
                continue
            }

            let asleepPredicate = HKCategoryValueSleepAnalysis.predicateForSamples(
                equalTo: HKCategoryValueSleepAnalysis.allAsleepValues
            )
            let results = try await healthKit.query(
                .sleepAnalysis,
                timeRange: HealthKitQueryTimeRange(startOfSleep..<endOfSleep),
                predicate: asleepPredicate
            )

            var secondsAsleep = 0.0
            for result in results {
                secondsAsleep += result.endDate.timeIntervalSince(result.startDate)
            }

            // Append the hours of sleep for that date
            dailySleepData.append(secondsAsleep / (60 * 60))
        }

        return dailySleepData
    }

    // MARK: - Flexible Date-Range Queries

    /// Fetches quantity data for an arbitrary date range, returning daily values with dates.
    ///
    /// - Parameters:
    ///   - identifier: The `HKQuantityTypeIdentifier` representing the type of health data to fetch.
    ///   - unit: The `HKUnit` to use for the fetched health data values.
    ///   - options: The `HKStatisticsOptions` to use when fetching the health data.
    ///   - startDate: The start of the date range.
    ///   - endDate: The end of the date range.
    /// - Returns: An array of tuples containing the date and value for each day.
    func fetchQuantityData(
        for identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        options: HKStatisticsOptions,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [(date: Date, value: Double)] {
        let sampleType = SampleType<HKQuantitySample>.quantity(identifier, displayUnit: unit)
        let timeRange = HealthKitQueryTimeRange(startDate..<endDate)

        let statistics: [HKStatistics]
        if options.contains(.cumulativeSum) {
            statistics = try await healthKit.statisticsQuery(sampleType, aggregatedBy: [.sum], over: .day, timeRange: timeRange)
        } else {
            statistics = try await healthKit.statisticsQuery(sampleType, aggregatedBy: [.average], over: .day, timeRange: timeRange)
        }

        return statistics.map { stat in
            let value: Double
            if options.contains(.cumulativeSum) {
                value = stat.sumQuantity()?.doubleValue(for: unit) ?? 0
            } else {
                value = stat.averageQuantity()?.doubleValue(for: unit) ?? 0
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
        var dailySleepData: [(date: Date, hours: Double)] = []

        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)

        var currentDay = startDay
        while currentDay <= endDay {
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay),
                  let startOfSleep = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: previousDay),
                  let endOfSleep = calendar.date(bySettingHour: 15, minute: 0, second: 0, of: currentDay) else {
                dailySleepData.append((date: currentDay, hours: 0))
                currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? endDay
                continue
            }

            let asleepPredicate = HKCategoryValueSleepAnalysis.predicateForSamples(
                equalTo: HKCategoryValueSleepAnalysis.allAsleepValues
            )
            let results = try await healthKit.query(
                .sleepAnalysis,
                timeRange: HealthKitQueryTimeRange(startOfSleep..<endOfSleep),
                predicate: asleepPredicate
            )

            var secondsAsleep = 0.0
            for result in results {
                secondsAsleep += result.endDate.timeIntervalSince(result.startDate)
            }

            dailySleepData.append((date: currentDay, hours: secondsAsleep / (60 * 60)))
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? endDay
        }

        return dailySleepData
    }
}
