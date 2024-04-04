//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2024 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI

struct LLMSourceSelection: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @AppStorage(StorageKeys.llmSource) private var llmSource = StorageKeys.Defaults.llmSource
    
    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "LLM_SOURCE_SELECTION_TITLE",
                        subtitle: "LLM_SOURCE_SELECTION_SUBTITLE"
                    )
                    Spacer()
                    sourceSelector
                    Spacer()
                }
            },
            actionView: {
                OnboardingActionsView(
                    "LLM_SOURCE_SELECTION_BUTTON"
                ) {
                    if llmSource == .local {
                        onboardingNavigationPath.append(customView: LLMLocalDownload())
                    } else {
                        onboardingNavigationPath.append(customView: OpenAIAPIKey())
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

#Preview {
    LLMSourceSelection()
}
