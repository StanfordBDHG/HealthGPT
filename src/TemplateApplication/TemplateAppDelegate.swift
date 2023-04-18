//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CardinalKit
import CardinalKitFHIR
import CardinalKitFHIRMockDataStorageProvider
import CardinalKitFHIRToFirestoreAdapter
import CardinalKitFirebaseAccount
import class FirebaseFirestore.FirestoreSettings
import CardinalKitFirestore
import CardinalKitFirestorePrefixUserIdAdapter
import CardinalKitHealthKit
import CardinalKitHealthKitToFHIRAdapter
import FirebaseAuth
import HealthKit
import SwiftUI


class TemplateAppDelegate: CardinalKitAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: FHIR()) {
            if !FeatureFlags.disableFirebase {
                if FeatureFlags.useFirebaseEmulator {
                    FirebaseAccountConfiguration(emulatorSettings: (host: "localhost", port: 9099))
                } else {
                    FirebaseAccountConfiguration()
                }
                firestore
            }
            if HKHealthStore.isHealthDataAvailable() {
                healthKit
            }
        }
    }
    
    
    private var firestore: Firestore<FHIR> {
        let settings = FirestoreSettings()
        if FeatureFlags.useFirebaseEmulator {
            settings.host = "localhost:8080"
            settings.isPersistenceEnabled = false
            settings.isSSLEnabled = false
        }
        
        return Firestore(
            adapter: {
                FHIRToFirestoreAdapter()
                FirestorePrefixUserIdAdapter()
            },
            settings: settings
        )
    }
    
    // ADD HK SAMPLES
    private var healthKit: HealthKit<FHIR> {
        HealthKit {
            CollectSample(
                HKQuantityType(.stepCount),
                deliverySetting: .anchorQuery(.afterAuthorizationAndApplicationWillLaunch)
            )
        } adapter: {
            HealthKitToFHIRAdapter()
        }
    }
}
