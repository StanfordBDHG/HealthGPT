//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import TemplateSharedContext


/// Displays an multi-step onboarding flow for the CardinalKit Template Application.
public struct OnboardingFlow: View {
    enum Step: String, Codable {
        case interestingModules
        case consent
        case healthKitPermissions
    }
    
    
    @SceneStorage(StorageKeys.onboardingFlowStep) private var onboardingSteps: [Step] = []
    
    
    public var body: some View {
        NavigationStack(path: $onboardingSteps) {
            Welcome(onboardingSteps: $onboardingSteps)
                .navigationDestination(for: Step.self) { onboardingStep in
                    switch onboardingStep {
                    case .interestingModules:
                        InterestingModules(onboardingSteps: $onboardingSteps)
                    case .consent:
                        Consent(onboardingSteps: $onboardingSteps)
                    case .healthKitPermissions:
                        HealthKitPermissions()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    public init() {}
}


struct OnboardingFlow_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlow()
    }
}
