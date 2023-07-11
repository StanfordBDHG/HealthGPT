//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziFHIR
import SpeziOpenAI
import Foundation

//healthdata interpreter has a getanswer property. add here.

@MainActor class HealthDataInterpreter<ComponentStandard: Standard>: DefaultInitializable, Component, ObservableObject, ObservableObjectProvider {
    var runningPrompt: [Chat] = [] {
        didSet {
            _Concurrency.Task {
                if runningPrompt.last?.role == .user {
                    try await queryOpenAI()
                }
            }
        }
        willSet {
            objectWillChange.send()
        }
    }
    @Published var querying: Bool = false
    
    required init() {}

    func generateMainPrompt() async throws {
        let healthDataFetcher = HealthDataFetcher()
        let healthData = try await healthDataFetcher.fetchAndProcessHealthData()

        let generator = PromptGenerator(with: healthData)
        let mainPrompt = generator.buildMainPrompt()
        runningPrompt =  [Chat(role: .system, content: mainPrompt)]
    }
    
    func queryOpenAI() async throws {
        querying = true
        let openAPIComponent: OpenAIComponent<FHIR> = OpenAIComponent()
        let chatStreamResults = try await openAPIComponent.queryAPI(withChat: runningPrompt)
        
        for try await chatStreamResult in chatStreamResults {
            for choice in chatStreamResult.choices {
                if runningPrompt.last?.role == .assistant {
                    let previousChatMessage = runningPrompt.last ?? Chat(role: .assistant, content: "")
                    runningPrompt[runningPrompt.count - 1] = Chat(
                        role: .assistant,
                        content: (previousChatMessage.content ?? "") + (choice.delta.content ?? "")
                    )
                } else {
                    runningPrompt.append(Chat(role: .assistant, content: choice.delta.content ?? ""))
                }
            }
        }
        querying = false
    }
}
