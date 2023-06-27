//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//
// SPDX-License-Identifier: MIT
//


import Foundation
import SpeziFHIR
import SpeziOpenAI


@MainActor
class MessageManager: ObservableObject {
    @Published private(set) var messages: [Chat]
    @Published private(set) var isQuerying = false
    private var openAIComponent: OpenAIComponent<FHIR>
    private let healthDataFetcher = HealthDataFetcher()

    /// Initializes a new instance of `MessageManager` with the specified API token and OpenAI model.
    ///
    /// - Parameters:
    ///   - apiToken: The API token for the OpenAI API.
    ///   - openAIModel: The OpenAI model to use for querying.
    init(apiToken: String = "", openAIModel: Model = .gpt3_5Turbo) {
        self.messages = []
        self.openAIComponent = OpenAIComponent<FHIR>(
            apiToken: apiToken,
            openAIModel: openAIModel
        )
    }
    
    /// Updates the API token for the OpenAI API.
    ///
    /// - Parameter newToken: The new API token.
    func updateAPIToken(_ newToken: String) {
        self.openAIComponent.apiToken = newToken
    }

    /// Updates the OpenAI model to use for querying.
    ///
    /// - Parameter newModel: The new OpenAI model to use.
    func updateOpenAIModel(_ newModel: Model) {
        self.openAIComponent.openAIModel = newModel
    }

    /// Processes the user message by appending it to the messages list and sending a query to the OpenAI API.
    ///
    /// - Parameter userMessage: The user message to process.
    func processUserMessage(_ userMessage: String) async {
        let newMessage = Chat(role: .user, content: userMessage)

        self.messages.append(newMessage)

        isQuerying = true

        do {
            let healthData = try await healthDataFetcher.fetchAndProcessHealthData()

            let generator = PromptGenerator(with: healthData)
            let mainPrompt = generator.buildMainPrompt()

            let botMessageStream = try await self.openAIComponent.queryAPI(withChat: self.messages)

            for try await partialBotMessageResult in botMessageStream {
                for choice in partialBotMessageResult.choices {
                    let botMessage = Chat(
                        role: .assistant,
                        content: choice.delta.content ?? nil,
                        name: partialBotMessageResult.id
                    )
                    if let existingBotMessageIndex = self.messages.firstIndex(where: {
                        $0.name == partialBotMessageResult.id
                    }) {
                        let previousBotMessage = messages[existingBotMessageIndex]
                        let combinedBotMessage = Chat(
                            role: .assistant,
                            content: (previousBotMessage.content ?? "") + (botMessage.content ?? "")
                        )
                        self.messages[existingBotMessageIndex] = combinedBotMessage
                    } else {
                        self.messages.append(botMessage)
                    }
                }
            }
            isQuerying = false
        } catch {
            print("Error querying OpenAI API: \(error)")
            isQuerying = false
        }
    }

    /// Clears the messages list
    func clearMessages() {
        messages = []
    }
}
