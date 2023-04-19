//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import CardinalKit
import CardinalKitFHIR
import CardinalKitHealthKit
import CardinalKitHealthKitToFHIRAdapter
import HealthKit
import SwiftUI


class TemplateAppDelegate: CardinalKitAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: FHIR()) {
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
