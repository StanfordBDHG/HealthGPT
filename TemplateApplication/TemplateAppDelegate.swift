//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CardinalKit
import FHIR
import HealthKit
import HealthKitDataSource
import HealthKitToFHIRAdapter
import Questionnaires
import Scheduler
import SwiftUI
import TemplateMockDataStorageProvider
import TemplateSchedule


class TemplateAppDelegate: CardinalKitAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: FHIR()) {
            if HKHealthStore.isHealthDataAvailable() {
                HealthKit {
                    CollectSample(
                        HKQuantityType(.stepCount),
                        deliverySetting: .anchorQuery(.afterAuthorizationAndApplicationWillLaunch)
                    )
                } adapter: {
                    HealthKitToFHIRAdapter()
                }
            }
            QuestionnaireDataSource()
            MockDataStorageProvider()
            TemplateApplicationScheduler()
        }
    }
}
