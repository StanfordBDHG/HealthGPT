//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOpenAI
import SpeziSpeechSynthesizer
import SwiftUI


struct HealthGPTView: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @AppStorage(StorageKeys.enableTextToSpeech) private var textToSpeech = StorageKeys.Defaults.enableTextToSpeech
    @EnvironmentObject private var openAPIComponent: OpenAIComponent
    @EnvironmentObject private var healthDataInterpreter: HealthDataInterpreter
    @State private var showSettings = false
    @StateObject private var speechSynthesizer = SpeechSynthesizer()

    
    var body: some View {
        NavigationView {
            VStack {
                ChatView($healthDataInterpreter.runningPrompt, disableInput: $healthDataInterpreter.querying)
                    .navigationTitle("WELCOME_TITLE")
                    .gesture(
                        TapGesture().onEnded {
                            UIApplication.shared.hideKeyboard()
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            settingsButton
                        }
                        ToolbarItem(placement: .primaryAction) {
                            textToSpeechButton
                        }
                    }
            }
            .onAppear {
                generatePrompt()
            }
            .onChange(of: completedOnboardingFlow) { _ in
                generatePrompt()
            }
            .onChange(of: healthDataInterpreter.querying) { _ in
                if textToSpeech,
                    healthDataInterpreter.runningPrompt.last?.role == .assistant,
                    let lastMessageContent = healthDataInterpreter.runningPrompt.last?.content {
                    speechSynthesizer.speak(lastMessageContent)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(chat: $healthDataInterpreter.runningPrompt)
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

    private var textToSpeechButton: some View {
        Button(
            action: {
                textToSpeech.toggle()
            },
            label: {
                if textToSpeech {
                    Image(systemName: "speaker")
                        .accessibilityLabel(Text("SPEAKER_ENABLED"))
                } else {
                    Image(systemName: "speaker.slash")
                        .accessibilityLabel(Text("SPEAKER_DISABLED"))
                }
            }
        )
        .accessibilityIdentifier("textToSpeechButton")
    }

    private func generatePrompt() {
        _Concurrency.Task {
            guard completedOnboardingFlow else {
                return
            }
            try await healthDataInterpreter.generateMainPrompt()
        }
    }
}
