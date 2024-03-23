//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziSecureStorage
import SwiftUI


private struct HealthGPTAppTestingSetup: ViewModifier {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @Environment(SecureStorage.self) var secureStorage


    func body(content: Content) -> some View {
        content
            .task {
                if FeatureFlags.skipOnboarding {
                    completedOnboardingFlow = true
                }
                if FeatureFlags.showOnboarding {
                    completedOnboardingFlow = false
                }
                if FeatureFlags.resetSecureStorage {
                    do {
                        try secureStorage.deleteAllCredentials()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
    }
}


extension View {
    func testingSetup() -> some View {
        self.modifier(HealthGPTAppTestingSetup())
    }
}
