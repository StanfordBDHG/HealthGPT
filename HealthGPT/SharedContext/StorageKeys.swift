//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//


/// Constants shared across the CardinalKit Teamplate Application to access storage information including the `AppStorage` and `SceneStorage`
enum StorageKeys {
    // MARK: - Onboarding
    /// A `Bool` flag indicating of the onboarding was completed.
    static let onboardingFlowComplete = "onboardingFlow.complete"
    /// A `Step` flag indicating the current step in the onboarding process.
    static let onboardingFlowStep = "onboardingFlow.step"
}
