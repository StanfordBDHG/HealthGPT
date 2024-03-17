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
    
    @State private var path = NavigationPath()
    @Environment(\.dismiss) private var dismiss
    @AppStorage(StorageKeys.enableTextToSpeech) private var enableTextToSpeech = StorageKeys.Defaults.enableTextToSpeech
    @AppStorage(StorageKeys.openAIModel) private var openAIModel = LLMOpenAIModelType.gpt4

    var body: some View {
        NavigationStack(path: $path) {
            List {
                openAISettings
                speechSettings
                disclaimer
            }
            .navigationTitle("SETTINGS_TITLE")
            .navigationDestination(for: SettingsDestinations.self) { destination in
                navigate(to: destination)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("SETTINGS_DONE") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var openAISettings: some View {
        Section("SETTINGS_OPENAI") {
            NavigationLink(value: SettingsDestinations.openAIKey) {
                Text("SETTINGS_OPENAI_KEY")
            }
            NavigationLink(value: SettingsDestinations.openAIModelSelection) {
                Text("SETTINGS_OPENAI_MODEL")
            }
        }
    }
    
    private var speechSettings: some View {
        Section("SETTINGS_SPEECH") {
            Toggle(isOn: $enableTextToSpeech) {
                Text("SETTINGS_SPEECH_TEXT_TO_SPEECH")
            }
        }
    }
    
    private var disclaimer: some View {
        Section("SETTINGS_DISCLAIMER_TITLE") {
            Text("SETTINGS_DISCLAIMER_TEXT")
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
                    actionText: "OPEN_AI_MODEL_SAVE_ACTION"
                ) { model in
                    openAIModel = model
                    path.removeLast()
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
