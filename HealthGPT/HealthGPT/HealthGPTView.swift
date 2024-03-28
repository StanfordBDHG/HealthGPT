//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziChat
import SpeziLLM
import SpeziLLMOpenAI
import SpeziSpeechSynthesizer
import SwiftUI


struct HealthGPTView: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @AppStorage(StorageKeys.enableTextToSpeech) private var textToSpeech = StorageKeys.Defaults.enableTextToSpeech
    @AppStorage(StorageKeys.openAIModel) private var openAIModel = LLMOpenAIModelType.gpt4
    
    @Environment(HealthDataInterpreter.self) private var healthDataInterpreter
    @State private var showSettings = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            if let llm = healthDataInterpreter.llm {
                let contextBinding = Binding { llm.context } set: { llm.context = $0 }
                ChatView(contextBinding, exportFormat: .text)
                    .speak(llm.context, muted: !textToSpeech)
                    .speechToolbarButton(muted: !$textToSpeech)
                    .viewStateAlert(state: llm.state)
                    .navigationTitle("WELCOME_TITLE")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            settingsButton
                        }
                        ToolbarItem(placement: .primaryAction) {
                            resetChatButton
                        }
                    }
                    .onChange(of: llm.context, initial: true) { _, _ in
                        Task {
                            if !llm.context.isEmpty && llm.state != .generating && llm.context.last?.role != .system {
                                do {
                                    try await healthDataInterpreter.queryLLM()
                                } catch {
                                    showErrorAlert = true
                                    errorMessage = "Error querying LLM: \(error.localizedDescription)"
                                }
                            }
                        }
                    }
            } else {
                loadingChatView
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .alert("ERROR_ALERT_TITLE", isPresented: $showErrorAlert) {
            Button("ERROR_ALERT_CANCEL", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .task {
            await healthDataInterpreter.prepareLLM(with: openAIModel)
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
