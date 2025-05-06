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
import SpeziKeychainStorage
import SpeziLLM
import SpeziLLMLocal
import SpeziLLMOpenAI
import SpeziSpeechSynthesizer
import SwiftUI


class HealthGPTAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: HealthGPTStandard()) {
            if HKHealthStore.isHealthDataAvailable() {
                healthKit
            }
            LLMRunner {
                LLMOpenAIPlatform()
                LLMLocalPlatform()
                LLMMockPlatform()
            }
            HealthDataInterpreter()
            HealthDataFetcher()
            KeychainStorage()
        }
    }
    
    
    private var healthKit: HealthKit {
        HealthKit {
            RequestReadAccess(
                quantity:
                    [
                        .activeEnergyBurned,
                        .appleExerciseTime,
                        .bodyMass,
                        .heartRate,
                        .stepCount
                    ]
            )
            RequestReadAccess(category: [.sleepAnalysis])
        }
    }
}
