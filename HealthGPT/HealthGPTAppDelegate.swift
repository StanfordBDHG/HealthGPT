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
                LLMOpenAIPlatform(configuration: .init(authToken: .keychain(tag: .openAIKey, username: "edu.stanford.healthgpt")))
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
