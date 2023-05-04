//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import HealthKit


class HealthDataFetcher {
    private let healthStore = HKHealthStore()

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            // update the types set below to request authorization to additional pieces of data
            guard HKHealthStore.isHealthDataAvailable(),
                  let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
                  let appleExerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime),
                  let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                  let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
                  let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
                continuation.resume(returning: false)
                return
            }

            let types: Set = [
                stepCount,
                appleExerciseTime,
                bodyMass,
                heartRate,
                sleepAnalysis
            ]

            healthStore.requestAuthorization(toShare: nil, read: types) { success, _ in
                continuation.resume(returning: success)
            }
        }
    }
    
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

    func fetchLastTwoWeeksStepCount() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .stepCount,
            unit: HKUnit.count(),
            options: [.cumulativeSum]
        )
    }

    func fetchLastTwoWeeksActiveEnergy() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .activeEnergyBurned,
            unit: HKUnit.largeCalorie(),
            options: [.cumulativeSum]
        )
    }
    
    func fetchLastTwoWeeksExerciseTime() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .appleExerciseTime,
            unit: .minute(),
            options: [.cumulativeSum]
        )
    }
    
    func fetchLastTwoWeeksBodyWeight() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .bodyMass,
            unit: .pound(),
            options: [.discreteAverage]
        )
    }
    
    func fetchLastTwoWeeksHeartRate() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .heartRate,
            unit: .count(),
            options: [.discreteAverage]
        )
    }

    func fetchLastTwoWeeksSleep() async throws -> [Double] {
        try await fetchLastTwoWeeksCategoryData(for: .sleepAnalysis)
    }

    private func createLastTwoWeeksPredicate() -> NSPredicate {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: now) ?? Date()
        return HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
    }
}

extension Date {
    static func startOfDay() -> Date {
        Calendar.current.startOfDay(for: Date())
    }

    func twoWeeksAgoStartOfDay() -> Date {
        Calendar.current.date(byAdding: DateComponents(day: -14), to: Date.startOfDay()) ?? Date()
    }
}
