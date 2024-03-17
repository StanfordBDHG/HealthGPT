//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziChat
import SpeziLLMOpenAI
import SwiftUI

struct SettingsView: View {
    private enum SettingsDestinations {
        case openAIKey
        case openAIModelSelection
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("SETTINGS_OPENAI") {
                    NavigationLink(value: SettingsDestinations.openAIKey) {
                        Text("SETTINGS_OPENAI_KEY")
                    }
                    NavigationLink(value: SettingsDestinations.openAIModelSelection) {
                        Text("SETTINGS_OPENAI_MODEL")
                    }
                }
                Section("SETTINGS_DISCLAIMER_TITLE") {
                    Text("SETTINGS_DISCLAIMER_TEXT")
                }
            }
            .navigationTitle("SETTINGS_TITLE")
            .navigationDestination(for: SettingsDestinations.self) { destination in
                navigate(to: destination)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("SETTINGS_CANCEL") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func navigate(to destination: SettingsDestinations) -> some View {
        Group {
            switch destination {
            case .openAIKey:
                LLMOpenAIAPITokenOnboardingStep(actionText: "OPEN_AI_KEY_SAVE_ACTION") {
                    path.removeLast()
                }
            case .openAIModelSelection:
                LLMOpenAIModelOnboardingStep(
                    actionText: "OPEN_AI_MODEL_SAVE_ACTION",
                    models: [.gpt4_turbo_preview, .gpt4, .gpt3_5Turbo]
                ) { _ in
                    path.removeLast()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
