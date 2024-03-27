//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziLLMOpenAI
import SpeziOnboarding
import SwiftUI


struct OpenAIModelSelection: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @AppStorage(StorageKeys.openAIModel) private var openAIModel = LLMOpenAIModelType.gpt4

    
    var body: some View {
        LLMOpenAIModelOnboardingStep(
            actionText: "OPEN_AI_MODEL_SAVE_ACTION",
            models: [.gpt3_5Turbo, .gpt4, .gpt4_turbo_preview]
        ) { model in
            openAIModel = model
            onboardingNavigationPath.nextStep()
        }
    }
}
