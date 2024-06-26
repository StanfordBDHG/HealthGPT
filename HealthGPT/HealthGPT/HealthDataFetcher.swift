//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi


@Observable
class HealthDataFetcher: DefaultInitializable, Module, EnvironmentAccessible {
    @ObservationIgnored private let healthStore = HKHealthStore()
    
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
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            throw HealthDataFetcherError.invalidObjectType
        }

        let predicate = createLastTwoWeeksPredicate()

        let quantityLastTwoWeeks = HKSamplePredicate.quantitySample(
            type: quantityType,
            predicate: predicate
        )

        let query = HKStatisticsCollectionQueryDescriptor(
            predicate: quantityLastTwoWeeks,
            options: options,
            anchorDate: Date.startOfDay(),
            intervalComponents: DateComponents(day: 1)
        )

        let quantityCounts = try await query.result(for: healthStore)

        var dailyData = [Double]()

        quantityCounts.enumerateStatistics(
            from: Date().twoWeeksAgoStartOfDay(),
            to: Date.startOfDay()
        ) { statistics, _ in
            if let quantity = statistics.sumQuantity() {
                dailyData.append(quantity.doubleValue(for: unit))
            } else {
                dailyData.append(0)
            }
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
            
            
            let sleepType = HKCategoryType(.sleepAnalysis)

            let dateRangePredicate = HKQuery.predicateForSamples(withStart: startOfSleep, end: endOfSleep, options: .strictEndDate)
            let allAsleepValuesPredicate = HKCategoryValueSleepAnalysis.predicateForSamples(equalTo: HKCategoryValueSleepAnalysis.allAsleepValues)
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dateRangePredicate, allAsleepValuesPredicate])

            let descriptor = HKSampleQueryDescriptor(
                predicates: [.categorySample(type: sleepType, predicate: compoundPredicate)],
                sortDescriptors: []
            )
            
            let results = try await descriptor.result(for: healthStore)

            var secondsAsleep = 0.0
            for result in results {
                secondsAsleep += result.endDate.timeIntervalSince(result.startDate)
            }
            
            // Append the hours of sleep for that date
            dailySleepData.append(secondsAsleep / (60 * 60))
        }
        
        return dailySleepData
    }
    
    /// Fetches the user's complete ehr data.
    ///
    /// - Returns: An array of `String` values representing ehr data as FHIR json strings.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchAllEHRRecords() async throws -> [String] {
        let clinicalTypes: [HKClinicalTypeIdentifier: String] = [
            .allergyRecord: "Allergies",
            //.clinicalNoteRecord: "Clinical notes", // Uncomment or remove based on availability in your HealthKit version
            .conditionRecord: "Conditions",
            .immunizationRecord: "Immunizations",
            .labResultRecord: "Lab results",
            .medicationRecord: "Medications",
            .procedureRecord: "Procedures",
            .vitalSignRecord: "Vital signs",
            //.coverageRecord: "Coverage records" // Note: Some identifiers might not be available in all iOS versions.
        ]

        var allRecords: [HKClinicalRecord] = []

        for (clinicalTypeIdentifier, typeString) in clinicalTypes {
            guard let clinicalType = HKObjectType.clinicalType(forIdentifier: clinicalTypeIdentifier) else {
                continue // Or handle the error as needed
            }

            let records = try await fetchEHRRecordsByType(for: clinicalType)
            allRecords.append(contentsOf: records)
        }
        
        // Convert clinical records to JSON strings
        let ehrRecordStrings: [String] = allRecords.compactMap {
            clinicalRecord in
            if let fhirRecord = clinicalRecord.fhirResource,
               let fhirData = String(data: fhirRecord.data, encoding: .utf8) {
                return fhirData
            }
            return nil
        }

        return ehrRecordStrings
    }

    private func fetchEHRRecordsByType(for clinicalType: HKClinicalType) async throws -> [HKClinicalRecord] {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: clinicalType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, samples, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let clinicalRecords = samples as? [HKClinicalRecord] ?? []
                continuation.resume(returning: clinicalRecords)
            }
            
            healthStore.execute(query)
        }
    }
    
    /// Fetches the user's ehr data for a specific type.
    ///
    /// - Returns: An array of `String` values representing ehr data of the given type.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchEHRDataForType(for type: HKClinicalType) async throws -> [String] {
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let ehrSamples = samples as? [HKClinicalRecord] else {
                    continuation.resume(returning: []) // Resume with an empty array if no samples are found
                    return
                }
                
                let records: [String] = ehrSamples.compactMap { clinicalRecord in
                    if let fhirRecord = clinicalRecord.fhirResource,
                       let fhirData = String(data: fhirRecord.data, encoding: .utf8) {
                        return fhirData
                    }
                    return nil
                }
                
                continuation.resume(returning: records)
            }
            
            healthStore.execute(query)
        }
    }

    private func createLastTwoWeeksPredicate() -> NSPredicate {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: now) ?? Date()
        return HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
    }
}
