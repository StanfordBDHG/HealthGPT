//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
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
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        // update this types set to request authorization to additional pieces of data
        let types: Set = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: types) { success, error in
            completion(success)
        }
    }
    
    func fetchLastTwoWeeksQuantityData(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, options: HKStatisticsOptions, completion: @escaping ([Double]) -> Void) {
        let predicate = createLastTwoWeeksPredicate()
        let query = HKStatisticsCollectionQuery(quantityType: HKObjectType.quantityType(forIdentifier: identifier)!, quantitySamplePredicate: predicate, options: options, anchorDate: Date.startOfDay(), intervalComponents: DateComponents(day: 1))

        var dailyData: [Double] = []

        query.initialResultsHandler = { query, results, error in
            if let statsCollection = results {
                statsCollection.enumerateStatistics(from: Date().twoWeeksAgoStartOfDay(), to: Date.startOfDay()) { statistics, _ in
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

    func fetchLastTwoWeeksCategoryData(for identifier: HKCategoryTypeIdentifier, completion: @escaping ([Double]) -> Void) {
        let predicate = createLastTwoWeeksPredicate()

        let query = HKSampleQuery(sampleType: HKObjectType.categoryType(forIdentifier: identifier)!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (_, samples, _) in
            var dailyData: [Double] = [Double](repeating: 0, count: 14)
            if let samples = samples as? [HKCategorySample] {

                for sample in samples {
                    let startOfSampleDay = Calendar.current.startOfDay(for: sample.startDate)
                    let distance = Int(Date().timeIntervalSince(startOfSampleDay) / 86400)
                    let minutes = Calendar.current.dateComponents([.minute], from: sample.startDate, to: sample.endDate).minute!

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
        fetchLastTwoWeeksQuantityData(for: .stepCount, unit: HKUnit.count(), options: [.cumulativeSum], completion: completion)
    }

    func fetchLastTwoWeeksActiveEnergy(completion: @escaping ([Double]) -> Void) {
        fetchLastTwoWeeksQuantityData(for: .activeEnergyBurned, unit: HKUnit.largeCalorie(), options: [.cumulativeSum], completion: completion)
    }
    
    func fetchLastTwoWeeksExerciseTime(completion: @escaping ([Double]) -> Void) {
        fetchLastTwoWeeksQuantityData(for: .appleExerciseTime, unit: .minute(), options: [.cumulativeSum], completion: completion)
    }
    
    func fetchLastTwoWeeksBodyWeight(completion: @escaping ([Double]) -> Void) {
        fetchLastTwoWeeksQuantityData(for: .bodyMass, unit: .pound(), options: [.discreteAverage], completion: completion)
    }
    
    func fetchLastTwoWeeksHeartRate(completion: @escaping ([Double]) -> Void) {
        fetchLastTwoWeeksQuantityData(for: .heartRate, unit: .count(), options: [.discreteAverage], completion: completion)
    }
    
    func fetchLastTwoWeeksSleep(completion: @escaping ([Double]) -> Void) {
        fetchLastTwoWeeksCategoryData(for: .sleepAnalysis, completion: completion)
    }

    private func createLastTwoWeeksPredicate() -> NSPredicate {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: now)!
        return HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
    }
}

private extension Date {
    static func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: Date())
    }

    func twoWeeksAgoStartOfDay() -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: -14), to: Date.startOfDay())!
    }
}
