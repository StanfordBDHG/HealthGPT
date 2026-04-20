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

    var unitLabel: String {
        switch self {
        case .sleep: "hours"
        case .steps, .activeEnergy, .exerciseMinutes, .bodyWeight, .restingHeartRate:
            sampleType?.displayUnit.unitString ?? ""
        }
    }

    var displayName: String {
        "\(sampleType?.displayTitle ?? "Sleep") (\(unitLabel))"
    }

    func quantityValue(from statistic: HKStatistics, unit: HKUnit) throws -> Double {
        switch self {
        case .steps, .activeEnergy, .exerciseMinutes:
            return statistic.sumQuantity()?.doubleValue(for: unit) ?? 0
        case .bodyWeight, .restingHeartRate:
            return statistic.averageQuantity()?.doubleValue(for: unit) ?? 0
        case .sleep:
            throw HealthDataFetcherError.unsupportedMetric
        }
    }
}
