//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import CardinalKit
import SwiftUI


@main
struct TemplateApplication: App {
    @UIApplicationDelegateAdaptor(TemplateAppDelegate.self) var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .sheet(isPresented: !$completedOnboardingFlow) {
                    OnboardingFlow()
                }
                .testingSetup()
                .cardinalKit(appDelegate)
        }
    }
}
