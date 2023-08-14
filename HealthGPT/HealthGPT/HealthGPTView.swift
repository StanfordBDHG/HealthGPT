//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFHIR
import SpeziOpenAI
import SwiftUI


struct HealthGPTView: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @EnvironmentObject private var openAPIComponent: OpenAIComponent<FHIR>
    @EnvironmentObject private var healthDataInterpreter: HealthDataInterpreter<FHIR>
    @State private var showSettings = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                ChatView($healthDataInterpreter.runningPrompt, disableInput: $healthDataInterpreter.querying)
                    .navigationBarTitle("WELCOME_TITLE")
                    .gesture(
                        TapGesture().onEnded {
                            UIApplication.shared.hideKeyboard()
                        }
                    )
            }
            .onAppear {
                generatePrompt()
            }
            .onChange(of: completedOnboardingFlow) { _ in
                generatePrompt()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(chat: $healthDataInterpreter.runningPrompt)
            }
            .navigationBarItems(
                trailing:
                    Button(
                        action: {
                            showSettings = true
                        },
                        label: {
                            Image(systemName: "gearshape")
                        }
                    )
            )
        }
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
