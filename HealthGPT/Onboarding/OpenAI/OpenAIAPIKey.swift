//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziLLMOpenAI
import SpeziViews
import SwiftUI


struct OpenAIAPIKey: View {
    @Environment(ManagedNavigationStack.Path.self) private var onboardingNavigationPath
    
    
    var body: some View {
        LLMOpenAIAPITokenOnboardingStep {
            onboardingNavigationPath.append(customView: OpenAIModelSelection())
        }
    }
}


#if DEBUG
#Preview {
    OpenAIAPIKey()
}
#endif
