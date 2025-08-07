//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import OSLog
import Spezi
import SpeziHealthKit
import SpeziHealthKitUI


class HealthDataFetcher: DefaultInitializable, Module, EnvironmentAccessible {
    private let logger = Logger(subsystem: "HealthGPT", category: "HealthDataFetcher")
    @HealthKitStatisticsQuery(.stepCount, aggregatedBy: [.sum], over: .day, timeRange: .last(weeks: 2))
    private var stepCountStats
    
    @HealthKitStatisticsQuery(.activeEnergyBurned, aggregatedBy: [.sum], over: .day, timeRange: .last(weeks: 2))
    private var activeEnergyStats
    
    @HealthKitStatisticsQuery(.appleExerciseTime, aggregatedBy: [.sum], over: .day, timeRange: .last(weeks: 2))
    private var exerciseTimeStats
    
    @HealthKitStatisticsQuery(.bodyMass, aggregatedBy: [.average], over: .day, timeRange: .last(weeks: 2))
    private var bodyWeightStats
    
    @HealthKitStatisticsQuery(.heartRate, aggregatedBy: [.average], over: .day, timeRange: .last(weeks: 2))
    private var heartRateStats
    
    @HealthKitQuery(.sleepAnalysis, timeRange: .last(weeks: 2))
    private var sleepSamples
    
    required init() { }
    
    /// Fetches and processes health data for the last 14 days.
    ///
    /// - Returns: An array of `HealthData` objects, one for each day in the last 14 days.
    func fetchAndProcessHealthData() async -> [HealthData] {
        let calendar = Calendar.current
        let today = Date()
        var healthData: [HealthData] = []

        // Create an array of HealthData objects for the last 14 days
        for day in 1...14 {
            guard let endDate = calendar.date(byAdding: .day, value: -day, to: today) else { continue }
            healthData.append(
                HealthData(
                    date: DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .none)
                )
            )
        }

        healthData = healthData.reversed()

        // Convert SpeziHealthKit property wrapper data to arrays
        let stepCounts = convertStatisticsToDoubles(stepCountStats, unit: HKUnit.count()) { $0.sumQuantity() }
        let caloriesBurned = convertStatisticsToDoubles(activeEnergyStats, unit: HKUnit.largeCalorie()) { $0.sumQuantity() }
        let exerciseTime = convertStatisticsToDoubles(exerciseTimeStats, unit: .minute()) { $0.sumQuantity() }
        let bodyMass = convertStatisticsToDoubles(bodyWeightStats, unit: .pound()) { $0.averageQuantity() }
        let sleepHours = calculateSleepHours()

        // Populate health data with actual values
        for day in 0...13 {
            if day < stepCounts.count { healthData[day].steps = stepCounts[day] }
            if day < sleepHours.count { healthData[day].sleepHours = sleepHours[day] }
            if day < caloriesBurned.count { healthData[day].activeEnergy = caloriesBurned[day] }
            if day < exerciseTime.count { healthData[day].exerciseMinutes = exerciseTime[day] }
            if day < bodyMass.count { healthData[day].bodyWeight = bodyMass[day] }
        }

        return healthData
    }
    
    /// Converts HKStatistics array to Double array with the specified unit, ensuring exactly 14 days.
    private func convertStatisticsToDoubles(_ statistics: [HKStatistics], unit: HKUnit, extractValue: (HKStatistics) -> HKQuantity?) -> [Double] {
        var result: [Double] = Array(repeating: 0.0, count: 14)
        
        // Map statistics to the correct day index (most recent 14 days)
        for (index, stat) in statistics.prefix(14).enumerated() {
            if let quantity = extractValue(stat) {
                result[index] = quantity.doubleValue(for: unit)
            }
        }
        
        return result
    }
    
    /// Calculate sleep hours from raw sleep samples.
    private func calculateSleepHours() -> [Double] {
        var dailySleepData: [Double] = Array(repeating: 0.0, count: 14)
        
        // Group sleep samples by day (3 PM to 3 PM cycle)
        for day in 0..<14 {
            let dayOffset = -14 + day
            guard let startOfSleepDay = Calendar.current.date(byAdding: DateComponents(day: dayOffset - 1), to: Date.startOfDay()),
                  let startOfSleep = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: startOfSleepDay),
                  let endOfSleepDay = Calendar.current.date(byAdding: DateComponents(day: dayOffset), to: Date.startOfDay()),
                  let endOfSleep = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: endOfSleepDay) else {
                continue
            }
            
            let samplesForDay = sleepSamples.filter { sample in
                let sampleStart = sample.startDate
                let sampleEnd = sample.endDate
                
                // Check if sample overlaps with the sleep period for this day
                return sampleStart < endOfSleep && sampleEnd > startOfSleep &&
                       sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue
            }
            
            var secondsAsleep = 0.0
            for sample in samplesForDay {
                // Calculate overlap between sample and the day's sleep period
                let overlapStart = max(sample.startDate, startOfSleep)
                let overlapEnd = min(sample.endDate, endOfSleep)
                if overlapStart < overlapEnd {
                    secondsAsleep += overlapEnd.timeIntervalSince(overlapStart)
                }
            }
            
            dailySleepData[day] = secondsAsleep / (60 * 60)
        }
        
        return dailySleepData
    }
}
