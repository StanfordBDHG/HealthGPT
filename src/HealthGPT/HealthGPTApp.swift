//
//  HealthGPTApplication.swift
//  HealthGPT
//
//  Created by Vishnu Ravi on 4/19/23.
//

import CardinalKit
import SwiftUI


@main
struct HealthGPTApp: App {
    @UIApplicationDelegateAdaptor(HealthGPTAppDelegate.self) var appDelegate
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
