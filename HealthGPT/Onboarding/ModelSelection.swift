//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CardinalKitOnboarding
import OpenAI
import SwiftUI


struct ModelSelection: View {
    @AppStorage(StorageKeys.openAIModel) private var openAIModel = Model.gpt3_5Turbo
    @Binding private var onboardingSteps: [OnboardingFlow.Step]
    @State private var selectedModel: Model = .gpt3_5Turbo
    
    
    var body: some View {
        OnboardingView(
            titleView: {
                OnboardingTitleView(
                    title: "MODEL_SELECTION_TITLE".moduleLocalized,
                    subtitle: "MODEL_SELECTION_SUBTITLE".moduleLocalized
                )
            },
            contentView: {
                Picker("Select OpenAI Model", selection: $selectedModel) {
                    Text("GPT 3.5 Turbo")
                        .tag(Model.gpt3_5Turbo)
                    Text("GPT 4")
                        .tag(Model.gpt4)
                }
                    .pickerStyle(.wheel)
                    .accessibilityIdentifier("modelPicker")
            },
            actionView: {
                OnboardingActionsView(
                    "Save",
                    action: {
                        openAIModel = self.selectedModel
                        onboardingSteps.append(.healthKitPermissions)
                    }
                )
            }
        )
    }
    
    
    init(onboardingSteps: Binding<[OnboardingFlow.Step]>) {
        self._onboardingSteps = onboardingSteps
    }
}


#if DEBUG
struct ModelSelection_Previews: PreviewProvider {
    @State private static var path: [OnboardingFlow.Step] = []
    
    
    static var previews: some View {
        ModelSelection(onboardingSteps: $path)
    }
}
#endif
