//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziChat
import SpeziLLM
import SpeziLLMFog
import SpeziLLMLocal
import SpeziLLMOpenAI
import SpeziSpeechSynthesizer
import SwiftUI


struct HealthGPTView: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @AppStorage(StorageKeys.enableTextToSpeech) private var textToSpeech = StorageKeys.Defaults.enableTextToSpeech
    @AppStorage(StorageKeys.llmSource) private var llmSource = StorageKeys.Defaults.llmSource
    @AppStorage(StorageKeys.openAIModel) private var openAIModel = LLMOpenAIParameters.ModelType.gpt4o
    @AppStorage(StorageKeys.fogModel) private var fogModel = LLMFogParameters.FogModelType.llama3_1_8B

    @Environment(HealthDataInterpreter.self) private var healthDataInterpreter
    @State private var showSettings = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var modelSettingRefreshId = UUID()
    @State private var messageTaskId = 0

    var body: some View {
        NavigationStack {
            if let llm = self.healthDataInterpreter.llm {
                let contextBinding = Binding { llm.context.chat } set: { llm.context.chat = $0 }
                
                ChatView(contextBinding, exportFormat: .text)
                    .speak(llm.context.chat, muted: !self.textToSpeech)
                    .speechToolbarButton(muted: !self.$textToSpeech)
                    .viewStateAlert(state: llm.state)
                    .navigationTitle("WELCOME_TITLE")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            self.settingsButton
                        }
                        ToolbarItem(placement: .primaryAction) {
                            self.resetChatButton
                        }
                    }
                    .onChange(of: llm.context, initial: true) { _, _ in
                        // Once the user enters a message in the chat, increase `messageTaskId` that triggers LLM inference
                        if !llm.context.isEmpty && llm.state != .generating && llm.context.last?.role != .system {
                            self.messageTaskId += 1
                        }
                    }
                    // Triggered on every new user message in the chat via `messageTaskId`
                    // Automatically cancels the LLM inference once view disappears
                    .task(id: self.messageTaskId) {
                        do {
                            try await healthDataInterpreter.queryLLM()
                        } catch {
                            showErrorAlert = true
                            errorMessage = "Error querying LLM: \(error.localizedDescription)"
                        }
                    }
            } else {
                self.loadingChatView
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(modelSettingRefreshId: $modelSettingRefreshId)
        }
        .alert("ERROR_ALERT_TITLE", isPresented: $showErrorAlert) {
            Button("ERROR_ALERT_CANCEL", role: .cancel) {}
        } message: {
            Text(self.errorMessage)
        }
        .task(id: self.modelSettingRefreshId) {      // Clears model context and reinits LLM if model settings changed
            do {
                if FeatureFlags.mockMode {
                    try await healthDataInterpreter.prepareLLM(with: LLMMockSchema())
                } else if FeatureFlags.localLLM || llmSource == .local {
                    try await healthDataInterpreter.prepareLLM(with: LLMLocalSchema(model: .llama3_2_3B_4bit))
                } else if llmSource == .fog {
                    try await healthDataInterpreter.prepareLLM(
                        with: LLMFogSchema(parameters: .init(modelType: self.fogModel))
                    )
                } else {
                    try await healthDataInterpreter.prepareLLM(with: LLMOpenAISchema(parameters: .init(modelType: openAIModel)))
                }
            } catch {
                self.showErrorAlert = true
                self.errorMessage = "Error querying LLM: \(error.localizedDescription)"
            }
        }
    }
    
    private var settingsButton: some View {
        Button(
            action: {
                showSettings = true
            },
            label: {
                Image(systemName: "gearshape")
                    .accessibilityLabel(Text("OPEN_SETTINGS"))
            }
        )
        .accessibilityIdentifier("settingsButton")
    }
    
    private var resetChatButton: some View {
        Button(
            action: {
                Task {
                    await healthDataInterpreter.resetChat()
                }
            },
            label: {
                Image(systemName: "arrow.counterclockwise")
                    .accessibilityLabel(Text("RESET"))
            }
        )
        .accessibilityIdentifier("resetChatButton")
    }
    
    private var loadingChatView: some View {
        VStack {
            Text("LOADING_CHAT_VIEW")
            ProgressView()
        }
    }
}
