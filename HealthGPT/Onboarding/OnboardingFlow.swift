//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziLLMOpenAI
import SpeziViews
import SwiftUI


/// Displays an multi-step onboarding flow for the Stanford HealthGPT Application.
struct OnboardingFlow: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @AppStorage(StorageKeys.llmSource) var llmSource = StorageKeys.Defaults.llmSource
    
    
    var body: some View {
        ManagedNavigationStack(didComplete: $completedOnboardingFlow) {
            Welcome()
            Disclaimer()

            // Presents the onboarding flow for the respective local, fog, or cloud LLM
            LLMSourceSelection()

            if HKHealthStore.isHealthDataAvailable() {
                HealthKitPermissions()
            }
        }
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(!completedOnboardingFlow)
    }
}


#if DEBUG
#Preview {
    OnboardingFlow()
}
#endif
