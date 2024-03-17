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
        LLMOpenAIModelOnboardingStep {_ in
            onboardingNavigationPath.nextStep()
        }
    }
}
