//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziHealthKit
import SpeziLLMOpenAI


enum HealthMetric: String, CaseIterable, Sendable, LLMFunctionParameterEnum {
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

    var aggregation: SpeziHealthKit.StatisticsAggregationOption? {
        switch self {
        case .steps, .activeEnergy, .exerciseMinutes: .sum
        case .bodyWeight, .restingHeartRate: .average
        case .sleep: nil
        }
    }

    var unitLabel: String {
        sampleType?.displayUnit.unitString ?? "hours"
    }

    var displayName: String {
        if let sampleType {
            return "\(sampleType.displayTitle) (\(unitLabel))"
        }
        return "Sleep (hours)"
    }
}
