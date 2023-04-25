//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import SwiftUI


/// Displays an multi-step onboarding flow for the HealthGPT Application.
struct OnboardingFlow: View {
    enum Step: String, Codable {
        case disclaimer
        case apiKey
        case modelSelection
        case healthKitPermissions
    }

    @SceneStorage(StorageKeys.onboardingFlowStep) private var onboardingSteps: [Step] = []
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false


    var body: some View {
        NavigationStack(path: $onboardingSteps) {
            Welcome(onboardingSteps: $onboardingSteps)
                .navigationDestination(for: Step.self) { onboardingStep in
                    switch onboardingStep {
                    case .disclaimer:
                        Disclaimer(onboardingSteps: $onboardingSteps)
                    case .apiKey:
                        ApiKey(onboardingSteps: $onboardingSteps)
                    case .modelSelection:
                        ModelSelection(onboardingSteps: $onboardingSteps)
                    case .healthKitPermissions:
                        HealthKitPermissions()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled(!completedOnboardingFlow)
    }
}


#if DEBUG
struct OnboardingFlow_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlow()
    }
}
#endif
