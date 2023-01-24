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


typealias TemplateApplicationScheduler = Scheduler<FHIR, TemplateApplicationTaskContext>


class TemplateAppDelegate: CardinalKitAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: FHIR()) {
            if HKHealthStore.isHealthDataAvailable() {
                HealthKit {
                    CollectSample(
                        HKQuantityType(.stepCount),
                        deliverySetting: .background(.afterAuthorizationAndApplicationWillLaunch)
                    )
                } adapter: {
                    HealthKitToFHIRAdapter()
                }
            }
            QuestionnaireDataSource()
            MockDataStorageProvider()
            TemplateApplicationScheduler(
                tasks: [
                    Task(
                        title: String(localized: "TASK_SOCIAL_SUPPORT_QUESTIONNAIRE_TITLE"),
                        description: String(localized: "TASK_SOCIAL_SUPPORT_QUESTIONNAIRE_DESCRIPTION"),
                        schedule: Schedule(
                            start: Calendar.current.startOfDay(for: Date()),
                            dateComponents: .init(hour: 0, minute: 30), // Every Day at 12:30 AM
                            end: .numberOfEvents(356)
                        ),
                        context: TemplateApplicationTaskContext.questionnaire(Bundle.main.questionnaire(withName: "SocialSupportQuestionnaire"))
                    )
                ]
            )
        }
    }
}
