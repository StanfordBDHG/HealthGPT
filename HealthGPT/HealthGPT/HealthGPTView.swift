//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFHIR
import SpeziOpenAI
import SpeziSecureStorage
import SwiftUI

struct HealthGPTView: View {
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
            .task {
                do {
                    try await healthDataInterpreter.generateMainPrompt()
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            .task(id:StorageKeys.onboardingFlowComplete){
                do {
                    try await healthDataInterpreter.generateMainPrompt()
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(chat: $healthDataInterpreter.runningPrompt)
            }
            .navigationBarItems(trailing:
                                    Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape")
            }
            )
        }
    }
}
