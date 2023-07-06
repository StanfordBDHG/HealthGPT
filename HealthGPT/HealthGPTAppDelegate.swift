//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
import SpeziFHIR
import SpeziHealthKit
import SpeziHealthKitToFHIRAdapter
import SpeziOpenAI
import SpeziSecureStorage
import SwiftUI


class HealthGPTAppDelegate: SpeziAppDelegate {
    private lazy var healthDataInterpreter: HealthDataInterpreter = {
            return HealthDataInterpreter(
                openAPIComponent: OpenAIComponent<FHIR>,
                healthDataFetcher: healthKit.resolve()
            )
        }()
    
    override var configuration: Configuration {
        Configuration(standard: FHIR()) {
            OpenAIComponent()
            SecureStorage()
            if HKHealthStore.isHealthDataAvailable() {
                healthKit
            }
        }
    }


    private var healthKit: HealthKit<FHIR> {
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
        } adapter: {
            HealthKitToFHIRAdapter()
        }
    }
}