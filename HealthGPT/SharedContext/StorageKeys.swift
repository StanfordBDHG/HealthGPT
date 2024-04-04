//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// Constants shared across the HealthGPT Application to access
/// storage information including the `AppStorage` and `SceneStorage`
enum StorageKeys {
    enum Defaults {
        static let enableTextToSpeech = false
        static let llmSource = LLMSource.openai
    }

    // MARK: - Onboarding
    /// A `Bool` flag indicating of the onboarding was completed.
    static let onboardingFlowComplete = "onboardingFlow.complete"
    /// A `Step` flag indicating the current step in the onboarding process.
    static let onboardingFlowStep = "onboardingFlow.step"
    /// An `LLMSource` flag indicating the source of the model (local vs. OpenAI)
    static let llmSource = "llmsource"
    /// An `LLMOpenAIModelType` flag indicating the OpenAI model to use
    static let openAIModel = "openAI.model"
    /// A `Bool` flag indicating if messages should be spoken.
    static let enableTextToSpeech = "settings.enableTextToSpeech"
}
