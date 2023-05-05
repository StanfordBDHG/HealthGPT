//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import HealthKit


class HealthDataFetcher {
    private let healthStore = HKHealthStore()

    /// Requests authorization to access the user's health data.
    ///
    /// - Returns: A `Bool` value indicating whether the authorization was successful.
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HKError(.errorHealthDataUnavailable)
        }

        let types: Set = [
            HKQuantityType(.stepCount),
            HKQuantityType(.appleExerciseTime),
            HKQuantityType(.bodyMass),
            HKQuantityType(.heartRate),
            HKCategoryType(.sleepAnalysis)
        ]

        try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: types)
    }

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
        let predicate = createLastTwoWeeksPredicate()

        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            throw HealthDataFetcherError.invalidObjectType
        }

        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: options,
            anchorDate: Date.startOfDay(),
            intervalComponents: DateComponents(day: 1)
        )

        return try await withCheckedThrowingContinuation { continuation in
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let statsCollection = results {
                    var dailyData: [Double] = []

                    statsCollection.enumerateStatistics(
                        from: Date().twoWeeksAgoStartOfDay(),
                        to: Date.startOfDay()
                    ) { statistics, _ in
                        if let quantity = statistics.sumQuantity() {
                            dailyData.append(quantity.doubleValue(for: unit))
                        } else {
                            dailyData.append(0)
                        }
                    }

                    continuation.resume(returning: dailyData)
                } else {
                    continuation.resume(throwing: HealthDataFetcherError.resultsNotFound)
                }
            }

            healthStore.execute(query)
        }
    }

    /// Fetches the user's health data for the specified category type identifier for the last two weeks.
    ///
    /// - Parameter identifier: The `HKCategoryTypeIdentifier` representing the type of health data to fetch.
    /// - Returns: An array of `Double` values representing the daily health data for the specified identifier.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksCategoryData(
        for identifier: HKCategoryTypeIdentifier
    ) async throws -> [Double] {
        let predicate = createLastTwoWeeksPredicate()

        guard let sampleType = HKObjectType.categoryType(forIdentifier: identifier) else {
            throw HealthDataFetcherError.invalidObjectType
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samplesOrNil, errorOrNil in
                if let error = errorOrNil {
                    continuation.resume(throwing: error)
                } else if let samples = samplesOrNil as? [HKCategorySample] {
                    var dailyData: [Double] = [Double](repeating: 0, count: 14)
                    for sample in samples {
                        let startOfSampleDay = Calendar.current.startOfDay(for: sample.startDate)
                        let distance = Int(Date().timeIntervalSince(startOfSampleDay) / 86400)
                        guard let minutes = Calendar.current.dateComponents(
                            [.minute],
                            from: sample.startDate,
                            to: sample.endDate
                        ).minute else {
                            return
                        }

                        if distance < 14 {
                            dailyData[distance] = Double(minutes) / 60.0
                        }
                    }

                    continuation.resume(returning: dailyData)
                } else {
                    continuation.resume(throwing: HealthDataFetcherError.resultsNotFound)
                }
            }

            healthStore.execute(query)
        }
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

    /// Fetches the user's heart rate data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily average heart rates.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksHeartRate() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .heartRate,
            unit: .count(),
            options: [.discreteAverage]
        )
    }

    /// Fetches the user's sleep data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily sleep duration in hours.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksSleep() async throws -> [Double] {
        try await fetchLastTwoWeeksCategoryData(for: .sleepAnalysis)
    }

    private func createLastTwoWeeksPredicate() -> NSPredicate {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: now) ?? Date()
        return HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
    }
}
