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
            let healthDataItem = HealthData(
                date: dateString,
                steps: 1000.0,
                activeEnergy: 200.0,
                exerciseMinutes: 30.0,
                bodyWeight: 150,
                sleepHours: 7.0
            )
            healthData.append(healthDataItem)
        }
        return healthData
    }

    func testBuildMainPrompt() {
        let promptGenerator = PromptGenerator(with: sampleHealthData)
        let mainPrompt = promptGenerator.buildMainPrompt()
        XCTAssertNotNil(mainPrompt)
        XCTAssertTrue(mainPrompt.contains("HealthGPT"))
        XCTAssertTrue(mainPrompt.contains("14 days"))
        XCTAssertTrue(mainPrompt.contains("Today is"))

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
