//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import Foundation
import OpenAI


@MainActor
class MessageManager: ObservableObject {
    @Published private(set) var messages: [Message]
    @Published private(set) var isQuerying = false
    private let openAIManager: OpenAIManager
    private let healthDataFetcher = HealthDataFetcher()

    /// Initializes a new instance of `MessageManager` with the specified API token and OpenAI model.
    ///
    /// - Parameters:
    ///   - apiToken: The API token for the OpenAI API.
    ///   - openAIModel: The OpenAI model to use for querying.
    init(apiToken: String = "", openAIModel: Model = .gpt3_5Turbo) {
        self.messages = []

        self.openAIManager = OpenAIManager(
            apiToken: apiToken,
            openAIModel: openAIModel
        )
    }

    /// Updates the API token for the OpenAI API.
    ///
    /// - Parameter newToken: The new API token.
    func updateAPIToken(_ newToken: String) {
        self.openAIManager.updateAPIToken(newToken)
    }

    /// Updates the OpenAI model to use for querying.
    ///
    /// - Parameter newModel: The new OpenAI model to use.
    func updateOpenAIModel(_ newModel: Model) {
        self.openAIManager.updateModel(newModel)
    }

    /// Processes the user message by appending it to the messages list and sending a query to the OpenAI API.
    ///
    /// - Parameter userMessage: The user message to process.
    func processUserMessage(_ userMessage: String) async {
        let newMessage = Message(content: userMessage, isBot: false)

        self.messages.append(newMessage)

        do {
            let healthData = try await healthDataFetcher.fetchAndProcessHealthData()

            let generator = PromptGenerator(with: healthData)
            let mainPrompt = generator.buildMainPrompt()

            Task {
                isQuerying = true
                do {
                    let botMessageContent = try await self.openAIManager.queryAPI(
                        mainPrompt: mainPrompt,
                        messages: self.messages
                    )
                    let botMessage = Message(content: botMessageContent, isBot: true)
                    self.messages.append(botMessage)
                    isQuerying = false
                } catch {
                    print("Error querying OpenAI API: \(error)")
                    isQuerying = false
                }
            }
        } catch {
            print("Error fetching and processing health data: \(error)")
        }
    }

    /// Clears the messages list
    func clearMessages() {
        messages = []
    }
}
