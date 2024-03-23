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
    
    var body: some View {
        NavigationStack {
            if let llm = healthDataInterpreter.llm {
                let contextBinding = Binding { llm.context } set: { llm.context = $0 }
                ChatView(contextBinding)
                    .speak(llm.context, muted: !textToSpeech)
                    .speechToolbarButton(muted: !$textToSpeech)
                    .viewStateAlert(state: llm.state)
                    .navigationTitle("WELCOME_TITLE")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            settingsButton
                        }
                    }
                    .onChange(of: llm.context, initial: true) { _, _ in
                        Task {
                            if llm.state != .generating {
                                try? await healthDataInterpreter.queryLLM()
                            }
                        }
                    }
            } else {
                VStack {
                    Text("LOADING_CHAT_VIEW")
                    ProgressView()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            Task {
                try? await healthDataInterpreter.prepareLLM(with: openAIModel)
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
}
