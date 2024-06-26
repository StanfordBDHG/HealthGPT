//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//
// SPDX-License-Identifier: MIT
//


import Foundation


extension HealthDataFetcher {
    /// Fetches and processes health data for the last 14 days.
    ///
    /// - Returns: An array of `HealthData` objects, one for each day in the last 14 days.
    func fetchAndProcessHealthData() async -> HealthData {
        let calendar = Calendar.current
        let today = Date()
        var healthData: HealthData = HealthData(dailyActivityData: [], ehrData: [])

        // Fetch activity data
        var activityData: [ActivityData] = []
        
        // Create an array of HealthData objects for the last 14 days
        for day in 1...14 {
            guard let endDate = calendar.date(byAdding: .day, value: -day, to: today) else { continue }
            activityData.append(
                ActivityData(
                    date: DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .none)
                )
            )
        }

        activityData = activityData.reversed()

        async let stepCounts = fetchLastTwoWeeksStepCount()
        async let sleepHours = fetchLastTwoWeeksSleep()
        async let caloriesBurned = fetchLastTwoWeeksActiveEnergy()
        async let exerciseTime = fetchLastTwoWeeksExerciseTime()
        async let bodyMass = fetchLastTwoWeeksBodyWeight()

        let fetchedStepCounts = try? await stepCounts
        let fetchedSleepHours = try? await sleepHours
        let fetchedCaloriesBurned = try? await caloriesBurned
        let fetchedExerciseTime = try? await exerciseTime
        let fetchedBodyMass = try? await bodyMass

        for day in 0...13 {
            activityData[day].steps = fetchedStepCounts?[day]
            activityData[day].sleepHours = fetchedSleepHours?[day]
            activityData[day].activeEnergy = fetchedCaloriesBurned?[day]
            activityData[day].exerciseMinutes = fetchedExerciseTime?[day]
            activityData[day].bodyWeight = fetchedBodyMass?[day]
        }

        healthData.dailyActivityData = activityData
        
        // Fetch EHR data
        let fetchedEhrData = try? await fetchAllEHRRecords()
        healthData.ehrData = fetchedEhrData

        return healthData
    }
}
