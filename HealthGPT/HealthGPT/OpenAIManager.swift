//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//
// SPDX-License-Identifier: MIT
//


import Foundation
import OpenAI

enum OpenAIAPIError: Error {
    case noAPIToken
}

/// `OpenAIManager` is a class responsible for managing the interactions with the OpenAI API.
class OpenAIManager {
    private(set) var apiToken: String?
    private(set) var openAIModel: Model

    /// Initializes a new instance of `OpenAIManager` with the specified API token and OpenAI model.
    ///
    /// - Parameters:
    ///   - apiToken: The API token for the OpenAI API.
    ///   - openAIModel: The OpenAI model to use for querying.
    init(apiToken: String, openAIModel: Model) {
        self.apiToken = apiToken
        self.openAIModel = openAIModel
    }

    /// Queries the OpenAI API using the provided main prompt and messages.
    ///
    /// - Parameters:
    ///   - mainPrompt: The prompt to use for the query.
    ///   - messages: The array of messages used in the conversation.
    ///
    /// - Returns: The content of the response from the API.
    func queryAPI(mainPrompt: String, messages: [Message]) async throws -> AsyncThrowingStream<ChatStreamResult, Error> {
        guard let apiToken, !apiToken.isEmpty else {
            throw OpenAIAPIError.noAPIToken
        }

        var currentChat: [Chat] = [.init(role: .system, content: mainPrompt)]

        for message in messages {
            currentChat.append(
                .init(
                    role: message.isBot ? .assistant : .user,
                    content: message.content
                )
            )
        }

        let openAIClient = OpenAI(apiToken: apiToken)
        let query = ChatQuery(model: openAIModel, messages: currentChat)
        return openAIClient.chatsStream(query: query)
    }

    /// Updates the API token for the OpenAI API.
    ///
    /// - Parameter newToken: The new API token to use.
    func updateAPIToken(_ newToken: String) {
        self.apiToken = newToken
    }

    /// Updates the OpenAI model to use for querying.
    ///
    /// - Parameter newModel: The new OpenAI model to use.
    func updateModel(_ newModel: Model) {
        self.openAIModel = newModel
    }
}
