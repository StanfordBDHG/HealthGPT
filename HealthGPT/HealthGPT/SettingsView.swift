//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog
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
    @Environment(HealthDataInterpreter.self) private var healthDataInterpreter
    @AppStorage(StorageKeys.enableTextToSpeech) private var enableTextToSpeech = StorageKeys.Defaults.enableTextToSpeech
    @AppStorage(StorageKeys.llmSource) private var llmSource = StorageKeys.Defaults.llmSource
    @AppStorage(StorageKeys.openAIModel) private var openAIModel = LLMOpenAIModelType.gpt4
    let logger = Logger(subsystem: "HealthGPT", category: "Settings")

    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !FeatureFlags.localLLM && !(llmSource == .local) {
                    openAISettings
                }

                chatSettings
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
                .accessibilityIdentifier("settingsList")
        }
    }
    
    private var openAISettings: some View {
        Section("SETTINGS_OPENAI") {
            NavigationLink(value: SettingsDestinations.openAIKey) {
                Text("SETTINGS_OPENAI_KEY")
            }
                .accessibilityIdentifier("openAIKey")
            NavigationLink(value: SettingsDestinations.openAIModelSelection) {
                Text("SETTINGS_OPENAI_MODEL")
            }
                .accessibilityIdentifier("openAIModel")
        }
    }
    
    private var chatSettings: some View {
        Section("SETTINGS_CHAT") {
            Button("SETTINGS_CHAT_RESET") {
                Task {
                    await healthDataInterpreter.resetChat()
                    dismiss()
                }
            }
                .buttonStyle(PlainButtonStyle())
                .accessibilityIdentifier("resetButton")
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
                    actionText: "OPEN_AI_MODEL_SAVE_ACTION",
                    models: [.gpt3_5Turbo, .gpt4, .gpt4_turbo_preview]
                ) { model in
                    Task {
                        openAIModel = model
                        await healthDataInterpreter.prepareLLM(with: LLMOpenAISchema(parameters: .init(modelType: model)))
                        path.removeLast()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
