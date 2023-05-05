//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit

struct HealthData: Codable {
    var date: String
    var steps: Double?
    var activeEnergy: Double?
    var exerciseMinutes: Double?
    var bodyWeight: Double?
    var sleepHours: Double?
    var heartRate: Double?
}

class HealthDataFetcher {
    private let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // update the types set below to request authorization to additional pieces of data
        guard HKHealthStore.isHealthDataAvailable(),
              let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
              let appleExerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime),
              let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
              let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
              let sleepAnalysis = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(false)
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
            completion(success)
        }
    }
    
    func fetchLastTwoWeeksQuantityData(
        for identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        options: HKStatisticsOptions,
        completion: @escaping ([Double]) -> Void
    ) {
        let predicate = createLastTwoWeeksPredicate()

        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return
        }

        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: options,
            anchorDate: Date.startOfDay(),
            intervalComponents: DateComponents(day: 1)
        )

        var dailyData: [Double] = []

        query.initialResultsHandler = { _, results, _ in
            if let statsCollection = results {
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

                completion(dailyData)
            } else {
                completion([])
            }
        }

        healthStore.execute(query)
    }

    func fetchLastTwoWeeksCategoryData(
        for identifier: HKCategoryTypeIdentifier,
        completion: @escaping ([Double]) -> Void
    ) {
        let predicate = createLastTwoWeeksPredicate()

        guard let sampleType = HKObjectType.categoryType(forIdentifier: identifier) else {
            return
        }

        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, _ in
            var dailyData: [Double] = [Double](repeating: 0, count: 14)
            if let samples = samples as? [HKCategorySample] {
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

                completion(dailyData)
            } else {
                completion([])
            }
        }

        healthStore.execute(query)
    }

    func fetchLastTwoWeeksStepCount(completion: @escaping ([Double]) -> Void) {
        fetchLastTwoWeeksQuantityData(
            for: .stepCount,
            unit: HKUnit.count(),
            options: [.cumulativeSum],
            completion: completion
        )
    }

    func fetchLastTwoWeeksActiveEnergy(completion: @escaping ([Double]) -> Void) {
        fetchLastTwoWeeksQuantityData(
            for: .activeEnergyBurned,
            unit: HKUnit.largeCalorie(),
            options: [.cumulativeSum],
            completion: completion
        )
    }
    
    func fetchLastTwoWeeksExerciseTime(completion: @escaping ([Double]) -> Void) {
        fetchLastTwoWeeksQuantityData(
            for: .appleExerciseTime,
            unit: .minute(),
            options: [.cumulativeSum],
            completion: completion
        )
    }
    
    func fetchLastTwoWeeksBodyWeight(completion: @escaping ([Double]) -> Void) {
        fetchLastTwoWeeksQuantityData(
            for: .bodyMass,
            unit: .pound(),
            options: [.discreteAverage],
            completion: completion
        )
    }
    
    func fetchLastTwoWeeksHeartRate(completion: @escaping ([Double]) -> Void) {
        fetchLastTwoWeeksQuantityData(
            for: .heartRate,
            unit: .count(),
            options: [.discreteAverage],
            completion: completion
        )
    }

    func fetchLastTwoWeeksSleep(completion: @escaping ([Double]) -> Void) {
        fetchLastTwoWeeksCategoryData(for: .sleepAnalysis, completion: completion)
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
