//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//
// SPDX-License-Identifier: MIT
//


import Foundation


extension HealthDataFetcher {
    /// Fetches and processes health data for the configured lookback window.
    ///
    /// - Returns: An array of `HealthData` objects, one per day over `HealthDataFetcher.defaultLookbackDays`.
    func fetchAndProcessHealthData() async -> [HealthData] {
        let calendar = Calendar.current
        let today = Date.now

        var dayDates: [Date] = []
        for day in 1...HealthDataFetcher.defaultLookbackDays {
            guard let date = calendar.date(byAdding: .day, value: -day, to: today) else { continue }
            dayDates.append(calendar.startOfDay(for: date))
        }
        dayDates.reverse()

        guard let startDate = dayDates.first,
              let lastDay = dayDates.last,
              let endDate = calendar.date(byAdding: .day, value: 1, to: lastDay) else {
            return []
        }

        let steps = await dailyValues(for: .steps, from: startDate, to: endDate, calendar: calendar)
        let activeEnergy = await dailyValues(for: .activeEnergy, from: startDate, to: endDate, calendar: calendar)
        let exerciseMinutes = await dailyValues(for: .exerciseMinutes, from: startDate, to: endDate, calendar: calendar)
        let bodyWeight = await dailyValues(for: .bodyWeight, from: startDate, to: endDate, calendar: calendar)
        let restingHeartRate = await dailyValues(for: .restingHeartRate, from: startDate, to: endDate, calendar: calendar)
        let sleepHours = await dailySleepHours(from: startDate, to: endDate, calendar: calendar)

        return dayDates.map { day in
            HealthData(
                date: DateFormatter.localizedString(from: day, dateStyle: .short, timeStyle: .none),
                steps: steps[day],
                activeEnergy: activeEnergy[day],
                exerciseMinutes: exerciseMinutes[day],
                bodyWeight: bodyWeight[day],
                sleepHours: sleepHours[day],
                restingHeartRate: restingHeartRate[day]
            )
        }
    }

    private func dailyValues(
        for metric: HealthMetric,
        from startDate: Date,
        to endDate: Date,
        calendar: Calendar
    ) async -> [Date: Double] {
        guard let data = try? await fetchQuantityData(for: metric, from: startDate, to: endDate) else {
            return [:]
        }
        return Dictionary(
            data.map { (calendar.startOfDay(for: $0.date), $0.value) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    private func dailySleepHours(
        from startDate: Date,
        to endDate: Date,
        calendar: Calendar
    ) async -> [Date: Double] {
        guard let data = try? await fetchSleepData(from: startDate, to: endDate) else {
            return [:]
        }
        return Dictionary(
            data.map { (calendar.startOfDay(for: $0.date), $0.hours) },
            uniquingKeysWith: { first, _ in first }
        )
    }
}
