//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

@testable import HealthGPT
import Testing

struct PromptGeneratorTests {
    let sampleHealthData: [HealthData] = Self.createSampleHealthData()
    
    private static func createSampleHealthData() -> [HealthData] {
        var healthData: [HealthData] = []
        for day in 0...13 {
            guard let date = Calendar.current.date(byAdding: .day, value: -(13 - day), to: Date()) else {
                continue
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)

            let steps = Double.random(in: 5000..<10000)
            let activeEnergy = Double.random(in: 100..<500)
            let exerciseMinutes = Double.random(in: 10..<100)
            let bodyWeight = Double.random(in: 100..<120)
            let sleepHours = Double.random(in: 4..<9)
            
            let healthDataItem = HealthData(
                date: dateString,
                steps: steps,
                activeEnergy: activeEnergy,
                exerciseMinutes: exerciseMinutes,
                bodyWeight: bodyWeight,
                sleepHours: sleepHours,
                heartRate: nil
            )

            healthData.append(healthDataItem)
        }
        return healthData
    }
    
    @Test
    func buildMainPrompt() throws {
        let promptGenerator = PromptGenerator(with: sampleHealthData)
        let mainPrompt = promptGenerator.buildMainPrompt()
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none)
        
        // Instead of XCTAssertNotNil(mainPrompt), we require that mainPrompt is not an empty string.
        try #require(!mainPrompt.isEmpty, "Main prompt should not be empty")
        
        var mainPromptStr = "You are HealthGPT, an enthusiastic, expert caretaker with a deep understanding in personal health. Given the context, provide a short response that could answer the user's question. Do NOT provide statistics. If numbers seem low, provide advice on how they can improve.\n\nSome health metrics over the past two weeks (14 days) to incorporate is given below. If a value is zero, the user has not inputted anything for that day. Today is \(today). Note that you do not have data about the current day. \n\n"
        
        try #require(mainPrompt.contains(mainPromptStr))
        
        try #require(mainPrompt.contains("Today is \(today)"), "Main prompt should contain today's date")
        
        for healthDataItem in sampleHealthData {
            try #require(mainPrompt.contains(healthDataItem.date), "Main prompt missing date: \(healthDataItem.date)")
            if let steps = healthDataItem.steps {
                try #require(mainPrompt.contains("\(Int(steps)) steps"), "Main prompt missing steps info for date \(healthDataItem.date)")
            }
            if let sleepHours = healthDataItem.sleepHours {
                try #require(mainPrompt.contains("\(Int(sleepHours)) hours of sleep"), "Main prompt missing sleep hours for date \(healthDataItem.date)")
            }
            if let activeEnergy = healthDataItem.activeEnergy {
                try #require(mainPrompt.contains("\(Int(activeEnergy)) calories burned"), "Main prompt missing active energy for date \(healthDataItem.date)")
            }
            if let exerciseMinutes = healthDataItem.exerciseMinutes {
                try #require(mainPrompt.contains("\(Int(exerciseMinutes)) minutes of exercise"), "Main prompt missing exercise minutes for date \(healthDataItem.date)")
            }
            if let bodyWeight = healthDataItem.bodyWeight {
                try #require(mainPrompt.contains("\(bodyWeight) lbs of body weight"), "Main prompt missing body weight for date \(healthDataItem.date)")
            }
        }
    }
}
