//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SpeziHealthKit
import SpeziOpenAI
import SwiftUI


class HealthGPTAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: HealthGPTStandard()) {
            OpenAIComponent()
            HealthDataInterpreter()
            if HKHealthStore.isHealthDataAvailable() {
                healthKit
            }
        }
    }


    private var healthKit: HealthKit {
        HealthKit {
            CollectSamples(
                [
                    HKQuantityType(.stepCount),
                    HKQuantityType(.activeEnergyBurned),
                    HKQuantityType(.appleExerciseTime),
                    HKQuantityType(.bodyMass),
                    HKQuantityType(.heartRate),
                    HKCategoryType(.sleepAnalysis)
                ],
                deliverySetting: .manual()
            )
        }
    }
}
