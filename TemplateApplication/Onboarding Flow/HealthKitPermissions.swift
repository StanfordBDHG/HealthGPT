//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FHIR
import HealthKitDataSource
import Onboarding
import SwiftUI


struct HealthKitPermissions: View {
    @EnvironmentObject var healthKitDataSource: HealthKit<FHIR>
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    
    
    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "HEALTHKIT_PERMISSIONS_TITLE",
                        subtitle: "HEALTHKIT_PERMISSIONS_SUBTITLE"
                    )
                    Text("HEALTHKIT_PERMISSIONS_DESCRIPTION")
                }
            }, actionView: {
                OnboardingActionsView(
                    "HEALTHKIT_PERMISSIONS_BUTTON",
                    action: {
                        _Concurrency.Task {
                            do {
                                try await healthKitDataSource.askForAuthorization()
                            } catch {
                                print("Could not request HealthKit permissions.")
                            }
                            completedOnboardingFlow = true
                        }
                    }
                )
            }
        )
    }
}


struct HealthKitPermissions_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitPermissions()
    }
}
