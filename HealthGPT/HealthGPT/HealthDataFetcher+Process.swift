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

        let stepCounts = try? await fetchLastTwoWeeksStepCount()
        let sleepHours = try? await fetchLastTwoWeeksSleep()
        let caloriesBurned = try? await fetchLastTwoWeeksActiveEnergy()
        let exerciseTime = try? await fetchLastTwoWeeksExerciseTime()
        let bodyMass = try? await fetchLastTwoWeeksBodyWeight()
        let restingHeartRate = try? await fetchLastTwoWeeksRestingHeartRate()

        for day in 0...13 {
            healthData[day].steps = stepCounts?[day]
            healthData[day].sleepHours = sleepHours?[day]
            healthData[day].activeEnergy = caloriesBurned?[day]
            healthData[day].exerciseMinutes = exerciseTime?[day]
            healthData[day].bodyWeight = bodyMass?[day]
            healthData[day].restingHeartRate = restingHeartRate?[day]
        }

        return healthData
    }
}
