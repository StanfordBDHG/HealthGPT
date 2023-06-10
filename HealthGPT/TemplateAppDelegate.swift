//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziFHIR
import SpeziHealthKit
import SpeziHealthKitToFHIRAdapter
import SpeziSecureStorage
import HealthKit
import SwiftUI


class TemplateAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: FHIR()) {
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
