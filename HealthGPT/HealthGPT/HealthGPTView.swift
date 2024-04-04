//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziChat
import SpeziLLM
import SpeziLLMLocal
import SpeziLLMOpenAI
import SpeziSpeechSynthesizer
import SwiftUI


struct HealthGPTView: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @AppStorage(StorageKeys.enableTextToSpeech) private var textToSpeech = StorageKeys.Defaults.enableTextToSpeech
    @AppStorage(StorageKeys.llmSource) private var llmSource = StorageKeys.Defaults.llmSource
    @AppStorage(StorageKeys.openAIModel) private var openAIModel = LLMOpenAIModelType.gpt4
    
    @Environment(HealthDataInterpreter.self) private var healthDataInterpreter
    @State private var showSettings = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            if let llm = healthDataInterpreter.llm {
                let contextBinding = Binding { llm.context.chatEntity } set: { llm.context = $0.llmContextEntity }
                
                ChatView(contextBinding, exportFormat: .text)
                    .speak(llm.context.chatEntity, muted: !textToSpeech)
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
            if FeatureFlags.mockMode {
                await healthDataInterpreter.prepareLLM(with: LLMMockSchema())
            } else if FeatureFlags.localLLM || llmSource == .local {
                await healthDataInterpreter.prepareLLM(with: LLMLocalSchema(modelPath: .cachesDirectory.appending(path: "llm.gguf")))
            } else {
                await healthDataInterpreter.prepareLLM(with: LLMOpenAISchema(parameters: .init(modelType: openAIModel)))
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

extension Array where Element == LLMContextEntity {
    var chatEntity: [ChatEntity] {
        self.map { llmContextEntity in
            let role: ChatEntity.Role
            
            switch llmContextEntity.role {
            case .user:
                role = .user
            case .assistant:
                role = .assistant
            case .system, .tool:
                role = .hidden(type: .unknown)
            }
            
            return ChatEntity(
                role: role,
                content: llmContextEntity.content,
                complete: llmContextEntity.complete,
                id: llmContextEntity.id,
                date: llmContextEntity.date
            )
        }
    }
}

extension Array where Element == ChatEntity {
    var llmContextEntity: [LLMContextEntity] {
        self.map { chatEntity in
            let role: LLMContextEntity.Role
            
            switch chatEntity.role {
            case .user:
                role = .user
            case .assistant:
                role = .assistant()
            case .hidden:
                role = .system
            }

            return LLMContextEntity(
                role: role,
                content: chatEntity.content,
                complete: chatEntity.complete,
                id: chatEntity.id,
                date: chatEntity.date
            )
        }
    }
}
