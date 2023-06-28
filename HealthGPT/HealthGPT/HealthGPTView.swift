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
    @EnvironmentObject var openAPIComponent: OpenAIComponent<FHIR>
    @State private var messages: [Chat] = []
    @State private var gettingAnswer = false
    
    private let healthDataFetcher = HealthDataFetcher()

    var body: some View {
        NavigationView {
            VStack {
                ChatView($messages, disableInput: $gettingAnswer)
                    .navigationBarTitle("HealthGPT")
                    .gesture(
                        TapGesture().onEnded {
                            UIApplication.shared.hideKeyboard()
                        }
                    )
                    .onChange(of: messages) { _ in
                        if !gettingAnswer {
                            getAnswer()
                        }
                    }
            }
            //  create a sheet with settingsview, add a button
            //  SettingsView(chat: $messages)
        }
    }
    
    private func getAnswer() {
        _Concurrency.Task {
            do {
                gettingAnswer = true
                
                // add chat
                let healthData = try await healthDataFetcher.fetchAndProcessHealthData()

                let generator = PromptGenerator(with: healthData)
                let mainPrompt = generator.buildMainPrompt()
                
                // create full prompt
                var fullPrompt = [Chat(role: .system, content: mainPrompt)]
                for message in messages {
                    fullPrompt.append(Chat(role: message.role, content: message.content))
                }
                
                // add mainprompt to front of self.messages
                let chatStreamResults = try await openAPIComponent.queryAPI(withChat: fullPrompt)
                
                for try await chatStreamResult in chatStreamResults {
                    for choice in chatStreamResult.choices {
                        if messages.last?.role == .assistant {
                            let previousChatMessage = messages.last ?? Chat(role: .assistant, content: "")
                            messages[messages.count - 1] = Chat(
                                role: .assistant,
                                content: (previousChatMessage.content ?? "") + (choice.delta.content ?? "")
                            )
                        } else {
                            messages.append(Chat(role: .assistant, content: choice.delta.content ?? ""))
                        }
                    }
                }
                
                gettingAnswer = false
            } catch {
                print(error)
            }
            gettingAnswer = false
        }
    }
}
