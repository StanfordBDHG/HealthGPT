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
    ///
    /// - Throws: `HealthDataFetcherError.authorizationFailed` if health data authorization fails.
    func fetchAndProcessHealthData() async throws -> [HealthData] {
        try await requestAuthorization()

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
            healthData[day].steps = fetchedStepCounts?[day]
            healthData[day].sleepHours = fetchedSleepHours?[day]
            healthData[day].activeEnergy = fetchedCaloriesBurned?[day]
            healthData[day].exerciseMinutes = fetchedExerciseTime?[day]
            healthData[day].bodyWeight = fetchedBodyMass?[day]
        }

        return healthData
    }
}
