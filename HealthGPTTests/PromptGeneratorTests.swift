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


@Suite("Prompt Generator Tests")
struct PromptGeneratorTests {
    private static let fixture: [HealthData] = [
        HealthData(
            date: "2026-04-18",
            steps: 8421,
            activeEnergy: 312,
            exerciseMinutes: 47,
            bodyWeight: 178.4,
            sleepHours: 7.2,
            restingHeartRate: 62
        ),
        HealthData(
            date: "2026-04-19",
            steps: 5102,
            activeEnergy: 198,
            exerciseMinutes: nil,
            bodyWeight: nil,
            sleepHours: 6.5,
            restingHeartRate: nil
        )
    ]

    @Test
    func dataPromptIncludesProvidedHealthData() {
        let prompt = PromptGenerator(with: Self.fixture).buildPrompt(usesTools: false)

        #expect(prompt.contains("Some health metrics over the past two weeks"))
        #expect(prompt.contains(
            "2026-04-18: 8421 steps, 7 hours of sleep, 312 calories burned, "
            + "47 minutes of exercise, 178.4 lbs of body weight,and 62.0 bpm average resting heart rate."
        ))
        #expect(prompt.contains("2026-04-19: 5102 steps, 6 hours of sleep, 198 calories burned,"))
    }

    @Test
    func dataPromptOmitsNilFields() {
        let prompt = PromptGenerator(with: Self.fixture).buildPrompt(usesTools: false)

        let dayTwoLine = prompt
            .split(separator: "\n")
            .first { $0.contains("2026-04-19") }
            .map(String.init) ?? ""

        #expect(!dayTwoLine.contains("minutes of exercise"))
        #expect(!dayTwoLine.contains("lbs of body weight"))
        #expect(!dayTwoLine.contains("bpm"))
    }

    @Test
    func toolPromptDoesNotEmbedHealthData() {
        let prompt = PromptGenerator(with: Self.fixture).buildPrompt(usesTools: true)

        #expect(prompt.contains("MUST call the available tools"))
        #expect(prompt.contains("Do NOT have any health data pre-loaded"))
        for day in Self.fixture {
            #expect(!prompt.contains(day.date))
        }
    }
}
