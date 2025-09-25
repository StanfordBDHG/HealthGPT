//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2024 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SpeziViews
import SwiftUI

struct LLMSourceSelection: View {
    @Environment(ManagedNavigationStack.Path.self) private var onboardingNavigationPath
    @AppStorage(StorageKeys.llmSource) private var llmSource = StorageKeys.Defaults.llmSource
    
    var body: some View {
        OnboardingView(
            content: {
                VStack {
                    OnboardingTitleView(
                        title: "LLM_SOURCE_SELECTION_TITLE",
                        subtitle: "LLM_SOURCE_SELECTION_SUBTITLE"
                    )
                    Spacer()
                    self.sourceSelector
                    Spacer()
                }
            },
            footer: {
                OnboardingActionsView(
                    "LLM_SOURCE_SELECTION_BUTTON"
                ) {
                    switch self.llmSource {
                    case .openai:
                        self.onboardingNavigationPath.append(customView: OpenAIAPIKey())
                    case .fog:
                        self.onboardingNavigationPath.append(customView: FogInformationView())
                    case .local:
                        self.onboardingNavigationPath.append(customView: LLMLocalDownload())
                    }
                }
            }
        )
    }
    
    private var sourceSelector: some View {
        Picker("LLM_SOURCE_PICKER_LABEL", selection: $llmSource) {
            ForEach(LLMSource.allCases) { source in
                Text(source.localizedDescription)
                    .tag(source)
            }
        }
        .pickerStyle(.inline)
        .accessibilityIdentifier("llmSourcePicker")
    }
}


#if DEBUG
#Preview {
    LLMSourceSelection()
}
#endif
