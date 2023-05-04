//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import Foundation
import OpenAI

enum OpenAIAPIError: Error {
    case noAPIToken
}

class OpenAIAPIHandler {
    private(set) var apiToken: String?
    private(set) var openAIModel: Model

    init(apiToken: String, openAIModel: Model) {
        self.apiToken = apiToken
        self.openAIModel = openAIModel
    }

    func queryAPI(mainPrompt: String, messages: [Message]) async throws -> String {
        guard let apiToken else {
            throw OpenAIAPIError.noAPIToken
        }

        let openAI = OpenAI(apiToken: apiToken)
        var currentChat: [Chat] = [.init(role: .system, content: mainPrompt)]

        for message in messages {
            currentChat.append(
                .init(
                    role: message.isBot ? .assistant : .user,
                    content: message.content
                )
            )
        }

        let query = ChatQuery(model: openAIModel, messages: currentChat)
        let botMessageContent = try await openAI.chats(query: query).choices[0].message.content
        return botMessageContent
    }

    func updateAPIToken(_ newToken: String) {
        self.apiToken = newToken
    }

    func updateModel(_ newModel: Model) {
        self.openAIModel = newModel
    }
}
