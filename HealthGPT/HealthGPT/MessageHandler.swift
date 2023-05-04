//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import Foundation
import OpenAI


@MainActor
class MessageHandler: ObservableObject {
    @Published private(set) var messages: [Message]
    @Published private(set) var isQuerying = false
    private let openAIAPIHandler: OpenAIAPIHandler
    private let healthDataFetcher = HealthDataFetcher()

    init(apiToken: String = "", openAIModel: Model = .gpt3_5Turbo) {
        self.messages = []

        self.openAIAPIHandler = OpenAIAPIHandler(
            apiToken: apiToken,
            openAIModel: openAIModel
        )
    }

    func updateAPIToken(_ newToken: String) {
        self.openAIAPIHandler.updateAPIToken(newToken)
    }

    func updateOpenAIModel(_ newModel: Model) {
        self.openAIAPIHandler.updateModel(newModel)
    }

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
                    let botMessageContent = try await self.openAIAPIHandler.queryAPI(
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

    func clearMessages() {
        messages = []
    }
}
