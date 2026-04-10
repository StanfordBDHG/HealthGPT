//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziChat
import SpeziLLM
import SpeziLLMFog
import SpeziLLMLocal
import SpeziSpeechSynthesizer


@Observable
class HealthDataInterpreter: DefaultInitializable, Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency(LLMRunner.self) private var llmRunner
    @ObservationIgnored @Dependency(HealthDataFetcher.self) private var healthDataFetcher
    
    var llm: (any LLMSession)?
    @ObservationIgnored private var systemPrompt = ""
    @ObservationIgnored private var usesToolBasedPrompt = false

    required init() { }


    /// Creates an `LLMRunner`, from an `LLMSchema` and injects the system prompt
    /// into the context, and assigns the resulting `LLMSession` to the `llm` property. For more
    /// information, please refer to the [`SpeziLLM`](https://swiftpackageindex.com/StanfordSpezi/SpeziLLM/documentation/spezillm) documentation.
    ///
    /// - Parameters:
    ///   - schema: The LLMSchema to use.
    ///   - useToolPrompt: Whether to use the tool-use prompt (for sessions with function calling).
    @MainActor
    func prepareLLM(with schema: any LLMSchema, useToolPrompt: Bool = false) async throws {
        let llm = self.llmRunner(with: schema)
        self.usesToolBasedPrompt = useToolPrompt
        self.systemPrompt = await buildSystemPrompt(usesTools: useToolPrompt)

        llm.context.append(systemMessage: self.systemPrompt)
        self.llm = llm
    }
    
    /// Queries the LLM using the current session in the `llm` property and adds the output to the context.
    @MainActor
    func queryLLM() async throws {
        guard let llm,
              llm.context.last?.role == .user || !(llm.context.contains(where: { $0.role == .assistant() }) ) else {
            return
        }
        
        let stream = try await llm.generate()
        
        for try await token in stream {
            llm.context.append(assistantOutput: token)
        }
    }
    
    /// Resets the LLM context and re-injects the system prompt.
    @MainActor
    func resetChat() async {
        self.systemPrompt = await buildSystemPrompt(usesTools: usesToolBasedPrompt)
        self.llm?.context.reset()
        self.llm?.context.append(systemMessage: self.systemPrompt)
    }

    private func buildSystemPrompt(usesTools: Bool) async -> String {
        let healthData = usesTools ? [] : await self.healthDataFetcher.fetchAndProcessHealthData()
        return PromptGenerator(with: healthData).buildPrompt(usesTools: usesTools)
    }
}
