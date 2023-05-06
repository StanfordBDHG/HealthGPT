//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import HealthGPT
import XCTest

class PromptGeneratorTests: XCTestCase {
    var sampleHealthData: [HealthData] = createSampleHealthData()

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
                sleepHours: sleepHours
            )

            healthData.append(healthDataItem)
        }
        return healthData
    }

    func testBuildMainPrompt() {
        let promptGenerator = PromptGenerator(with: sampleHealthData)
        let mainPrompt = promptGenerator.buildMainPrompt()
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none)

        XCTAssertNotNil(mainPrompt)

        // swiftlint:disable:next line_length
        XCTAssertTrue(mainPrompt.contains("You are HealthGPT, an enthusiastic, expert caretaker with a deep understanding in personal health. Given the context, provide a short response that could answer the user's question. Do NOT provide statistics. If numbers seem low, provide advice on how they can improve.\n\nSome health metrics over the past two weeks (14 days) to incorporate is given below. If a value is zero, the user has not inputted anything for that day."))
        
        XCTAssertTrue(mainPrompt.contains("Today is \(today)"))

        for healthDataItem in sampleHealthData {
            XCTAssertTrue(mainPrompt.contains(healthDataItem.date))
            if let steps = healthDataItem.steps {
                XCTAssertTrue(mainPrompt.contains("\(Int(steps)) steps"))
            }
            if let sleepHours = healthDataItem.sleepHours {
                XCTAssertTrue(mainPrompt.contains("\(Int(sleepHours)) hours of sleep"))
            }
            if let activeEnergy = healthDataItem.activeEnergy {
                XCTAssertTrue(mainPrompt.contains("\(Int(activeEnergy)) calories burned"))
            }
            if let exerciseMinutes = healthDataItem.exerciseMinutes {
                XCTAssertTrue(mainPrompt.contains("\(Int(exerciseMinutes)) minutes of exercise"))
            }
            if let bodyWeight = healthDataItem.bodyWeight {
                XCTAssertTrue(mainPrompt.contains("\(bodyWeight) lbs of body weight"))
            }
        }
    }
}
