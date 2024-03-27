//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog
import SpeziSecureStorage
import SwiftUI


private struct HealthGPTAppTestingSetup: ViewModifier {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @Environment(SecureStorage.self) var secureStorage

    let logger = Logger(subsystem: "HealthGPT", category: "Testing")

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
                        logger.error("Could not clear secure storage: \(error.localizedDescription)")
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
