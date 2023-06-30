//
//  HealthDataInterpreter.swift
//  HealthGPT
//
//  Created by Rhea Malhotra on 6/29/23.
//

import Foundation
import Spezi
import SpeziOpenAI
import SpeziLocalStorage

class HealthDataInterpreter: DefaultInitializable {
//    //@Dependency private var openAIComponent = OpenAIComponent()
//    //@Dependency private var localStorage: LocalStorage
//
//    @Published var messages: [Chat] = []
//
    required init() {}
//
//    func configure() {
//        if let cachedMessages: [Chat] = try? localStorage.read(storageKey: "HealthDataInterpreter.Messages") {
//            self.messages = cachedMessages
//        }
//    }
//
//    func processUserMessage(_ message: String) async throws {
//        let chat = Chat(role: .user, content: message)
//        messages.append(chat)
//
//        let prompt = generatePrompt()
//        let fullPrompt = [prompt] + messages
//
//        let chatStreamResults = try await openAIComponent.queryAPI(withChat: fullPrompt)
//
//        for try await chatStreamResult in chatStreamResults {
//            for choice in chatStreamResult.choices {
//                let assistantMessage = Chat(role: .assistant, content: choice.text ?? "")
//                messages.append(assistantMessage)
//            }
//        }
//
//        try await saveMessages()
//    }
//
//    private func generatePrompt() -> Chat {
//        Chat(role: .system, content: "Replace this with your prompt generation logic")
//    }
//
//    private func saveMessages() async throws {
//        try await localStorage.store(messages, storageKey: "HealthDataInterpreter.Messages")
//    }
}
