//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import SwiftUI


private struct TemplateAppTestingSetup: ViewModifier {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    
    
    func body(content: Content) -> some View {
        content
            .task {
                if FeatureFlags.skipOnboarding {
                    completedOnboardingFlow = true
                }
                if FeatureFlags.showOnboarding {
                    completedOnboardingFlow = false
                }
            }
    }
}


extension View {
    func testingSetup() -> some View {
        self.modifier(TemplateAppTestingSetup())
    }
}
