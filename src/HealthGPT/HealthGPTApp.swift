//
//  HealthGPTApplication.swift
//  HealthGPT
//
//

import CardinalKit
import SwiftUI


@main
struct HealthGPTApp: App {
    @UIApplicationDelegateAdaptor(HealthGPTAppDelegate.self) var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false


    var body: some Scene {
        WindowGroup {
            HealthGPTView()
                .sheet(isPresented: !$completedOnboardingFlow) {
                    OnboardingFlow()
                }
                .testingSetup()
                .cardinalKit(appDelegate)
        }
    }
}
