//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//
// SPDX-License-Identifier: MIT
//


import Foundation


class PromptGenerator {
    var healthData: [HealthData]

    init(with healthData: [HealthData]) {
        self.healthData = healthData
    }

    func buildMainPrompt() -> String {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none)
        var mainPrompt = "You are HealthGPT, an enthusiastic, expert caretaker with a deep understanding in personal health. Given the context, provide a short response that could answer the user's question. Do NOT provide statistics. If numbers seem low, provide advice on how they can improve.\n\nSome health metrics over the past two weeks (14 days) to incorporate is given below. If a value is zero, the user has not inputted anything for that day. Today is \(today). Note that you do not have data about the current day.\n\n"
        mainPrompt += buildFourteenDaysHealthDataPrompt()
        return mainPrompt
    }

    private func buildFourteenDaysHealthDataPrompt() -> String {
        var healthDataPrompt = ""
        for day in 0...13 {
            let dayData = healthData[day]
            let dayPrompt = buildOneDayHealthDataPrompt(with: dayData)
            healthDataPrompt += "\(dayData.date): \(dayPrompt) \n"
        }
        return healthDataPrompt
    }

    private func buildOneDayHealthDataPrompt(with dayData: HealthData) -> String {
        var dayPrompt = ""
        if let steps = dayData.steps {
            dayPrompt += "\(Int(steps)) steps,"
        }
        if let sleepHours = dayData.sleepHours {
            dayPrompt += " \(Int(sleepHours)) hours of sleep,"
        }
        if let activeEnergy = dayData.activeEnergy {
            dayPrompt += " \(Int(activeEnergy)) calories burned,"
        }
        if let exerciseMinutes = dayData.exerciseMinutes {
            dayPrompt += " \(Int(exerciseMinutes)) minutes of exercise,"
        }
        if let bodyWeight = dayData.bodyWeight {
            dayPrompt += " \(bodyWeight) lbs of body weight,"
        }
        return dayPrompt
    }
}
