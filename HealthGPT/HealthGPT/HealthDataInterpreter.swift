//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziOpenAI
import SpeziSpeechSynthesizer


class HealthDataInterpreter: DefaultInitializable, Component, ObservableObject, ObservableObjectProvider {
    @Dependency var openAIComponent = OpenAIComponent()

    
    var querying = false {
        willSet {
            _Concurrency.Task { @MainActor in
                objectWillChange.send()
            }
        }
    }
    
    var runningPrompt: [Chat] = [] {
        willSet {
            _Concurrency.Task { @MainActor in
                objectWillChange.send()
            }
        }
        didSet {
            _Concurrency.Task {
                if runningPrompt.last?.role == .user {
                    do {
                        try await queryOpenAI()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    
    required init() {}


    func generateMainPrompt() async throws {
        let healthDataFetcher = HealthDataFetcher()
        let healthData = try await healthDataFetcher.fetchAndProcessHealthData()

        let generator = PromptGenerator(with: healthData)
        let mainPrompt = generator.buildMainPrompt()
        runningPrompt = [Chat(role: .system, content: mainPrompt)]
    }
    
    func queryOpenAI() async throws {
        querying = true
        
        let chatStreamResults = try await openAIComponent.queryAPI(withChat: runningPrompt)
        
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
