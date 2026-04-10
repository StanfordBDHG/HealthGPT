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

    private static var basePrompt: String {
        let today = DateFormatter.localizedString(from: .now, dateStyle: .full, timeStyle: .none)
        return """
        You are HealthGPT, an enthusiastic, expert caretaker with a deep understanding in personal health. \
        If numbers seem low, provide advice on how they can improve. \
        Provide concise, actionable insights rather than just repeating raw numbers. \
        Today is \(today). You do not have data about the current day.
        """
    }

    static func buildToolUsePrompt() -> String {
        basePrompt + "\n\n" + """
        You have access to tools that let you fetch the user's real Apple Health data on demand. \
        You do NOT have any health data pre-loaded. You MUST call the available tools to fetch data \
        before answering any health-related questions. Do not guess or make up health data. \
        When the user asks about their health, call the appropriate tool(s) to fetch the relevant data first. \
        If the user asks a vague question, fetch the most relevant metrics for the last 7 days.
        """
    }

    func buildMainPrompt() -> String {
        Self.basePrompt + "\n\n" + """
        Some health metrics over the past two weeks (14 days) to incorporate is given below. \
        If a value is zero, the user has not inputted anything for that day.

        """ + buildFourteenDaysHealthDataPrompt()
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
        if let heartRate = dayData.restingHeartRate {
            dayPrompt += "and \(heartRate) bpm average resting heart rate."
        }
        return dayPrompt
    }
}
