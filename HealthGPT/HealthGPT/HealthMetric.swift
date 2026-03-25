//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziHealthKit


enum HealthMetric: String, CaseIterable, Sendable {
    case steps
    case activeEnergy
    case exerciseMinutes
    case bodyWeight
    case restingHeartRate
    case sleep

    var sampleType: SampleType<HKQuantitySample>? {
        switch self {
        case .steps: .stepCount
        case .activeEnergy: .activeEnergyBurned
        case .exerciseMinutes: .appleExerciseTime
        case .bodyWeight: .bodyMass
        case .restingHeartRate: .restingHeartRate
        case .sleep: nil
        }
    }

    var identifier: HKQuantityTypeIdentifier? {
        switch self {
        case .steps: .stepCount
        case .activeEnergy: .activeEnergyBurned
        case .exerciseMinutes: .appleExerciseTime
        case .bodyWeight: .bodyMass
        case .restingHeartRate: .restingHeartRate
        case .sleep: nil
        }
    }

    var unit: HKUnit? {
        switch self {
        case .steps: .count()
        case .activeEnergy: .largeCalorie()
        case .exerciseMinutes: .minute()
        case .bodyWeight: .pound()
        case .restingHeartRate: .count().unitDivided(by: .minute())
        case .sleep: nil
        }
    }

    var options: HKStatisticsOptions? {
        switch self {
        case .steps, .activeEnergy, .exerciseMinutes: [.cumulativeSum]
        case .bodyWeight, .restingHeartRate: [.discreteAverage]
        case .sleep: nil
        }
    }

    var displayName: String {
        switch self {
        case .steps: "Steps"
        case .activeEnergy: "Active Energy (calories)"
        case .exerciseMinutes: "Exercise Minutes"
        case .bodyWeight: "Body Weight (lbs)"
        case .restingHeartRate: "Resting Heart Rate (bpm)"
        case .sleep: "Sleep (hours)"
        }
    }

    var description: String {
        switch self {
        case .steps: "Daily step count"
        case .activeEnergy: "Active energy burned in calories"
        case .exerciseMinutes: "Minutes of exercise"
        case .bodyWeight: "Body weight in pounds"
        case .restingHeartRate: "Average resting heart rate in beats per minute"
        case .sleep: "Hours of sleep per night"
        }
    }
}
