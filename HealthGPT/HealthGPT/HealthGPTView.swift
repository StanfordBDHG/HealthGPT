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
    @Environment(HealthDataInterpreter.self) private var healthDataInterpreter
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let llm = healthDataInterpreter.llm {
                    let contextBinding = Binding { llm.context } set: { llm.context = $0 }
                    ChatView(contextBinding)
                        .speak(llm.context, muted: !textToSpeech)
                        .speechToolbarButton(muted: !$textToSpeech)
                        .viewStateAlert(state: llm.state)
                        .onChange(of: llm.context, initial: true) { _, _ in
                            Task {
                                if llm.state != .generating {
                                    try? await healthDataInterpreter.queryLLM()
                                }
                            }
                        }
                        .navigationTitle("WELCOME_TITLE")
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                settingsButton
                            }
                        }
                        .sheet(isPresented: $showSettings) {
                            SettingsView()
                        }
                }
            }
            .onAppear {
                Task {
                    await healthDataInterpreter.prepareLLM()
                }
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
