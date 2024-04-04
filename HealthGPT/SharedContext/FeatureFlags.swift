//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// A collection of feature flags for the HealthGPT app.
enum FeatureFlags {
    /// Skips the onboarding flow to enable easier development of features in the application
    /// and to allow UI tests to skip the onboarding flow.
    static let skipOnboarding = CommandLine.arguments.contains("--skipOnboarding")
    /// Always show the onboarding when the application is launched. Makes it easy to modify
    /// and test the onboarding flow without the need to manually remove the application or reset the simulator.
    static let showOnboarding = CommandLine.arguments.contains("--showOnboarding")
    /// Resets all credentials in Secure Storage when the application is launched in order to facilitate testing of OpenAI API keys.
    static let resetSecureStorage = CommandLine.arguments.contains("--resetSecureStorage")
    /// Configures SpeziLLM to use a local model stored on the device downloaded during onboarding
    static let localLLM = CommandLine.arguments.contains("--localLLM")
    /// Configures SpeziLLM to mock all generated responses for development and UI tests
    static let mockMode = CommandLine.arguments.contains("--mockMode")
}
