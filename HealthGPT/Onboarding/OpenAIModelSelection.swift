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
    
    
    var body: some View {
        LLMOpenAIModelOnboardingStep(
            actionText: "OPEN_AI_MODEL_SAVE_ACTION",
            models: [.gpt4_turbo_preview, .gpt4, .gpt3_5Turbo]
        ) {_ in
            onboardingNavigationPath.nextStep()
        }
    }
}
