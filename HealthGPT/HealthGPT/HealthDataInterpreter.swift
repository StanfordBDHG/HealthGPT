//
//  HealthDataInterpreter.swift
//  HealthGPT
//
//  Created by Rhea Malhotra on 6/29/23.
//

import Foundation
import Spezi
import SpeziOpenAI
import SpeziFHIR
import SpeziLocalStorage

// confused on this part!
class HealthDataInterpreter: ObservableObject {
    private let openAPIComponent: OpenAIComponent<FHIR>
    private let healthDataFetcher: HealthDataFetcher
    @Published var messages: [Chat] = []
    
    init(openAPIComponent: OpenAIComponent<FHIR>, healthDataFetcher: HealthDataFetcher) {
        self.openAPIComponent = openAPIComponent
        self.healthDataFetcher = healthDataFetcher
    }
    
    func configure() async {
        do {
            let healthData = try await healthDataFetcher.fetchAndProcessHealthData()
            let generator = PromptGenerator(with: healthData)
            let mainPrompt = generator.buildMainPrompt()
            
            // Create the full prompt
            var fullPrompt = [Chat(role: .system, content: mainPrompt)]
            for message in messages {
                fullPrompt.append(Chat(role: message.role, content: message.content))
            }
            
            // Query the API with the full prompt
            let chatStreamResults = try await openAPIComponent.queryAPI(withChat: fullPrompt)
            
            // Process the API response and update the messages
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
        } catch {
            print(error)
        }
    }
}
