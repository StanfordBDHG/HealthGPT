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
import SpeziLLMOpenAI
import SpeziSpeechSynthesizer


@Observable
class HealthDataInterpreter: DefaultInitializable, Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency(LLMRunner.self) private var llmRunner
    @ObservationIgnored @Dependency(HealthDataFetcher.self) private var healthDataFetcher
    
    var llm: (any LLMSession)?
    @ObservationIgnored private var systemPrompt = ""
    
    required init() { }
    
    
    /// Creates an `LLMRunner`, from an `LLMSchema` and injects the system prompt
    /// into the context, and assigns the resulting `LLMSession` to the `llm` property. For more
    /// information, please refer to the [`SpeziLLM`](https://swiftpackageindex.com/StanfordSpezi/SpeziLLM/documentation/spezillm) documentation.
    ///
    /// - Parameter schema: The LLMSchema to use.
    @MainActor
    func prepareLLM(with schema: any LLMSchema) async throws {
        let llm = self.llmRunner(with: schema)
        self.systemPrompt = await generateSystemPrompt()

        llm.context.append(systemMessage: self.systemPrompt)
        self.llm = llm
    }

    /// Creates an LLM session with tool-use prompt (no pre-fetched data).
    /// Used for OpenAI sessions that support function calling.
    ///
    /// - Parameter schema: The LLMOpenAISchema configured with LLM functions.
    @MainActor
    func prepareLLMWithTools(with schema: LLMOpenAISchema) {
        let llm = self.llmRunner(with: schema)
        self.systemPrompt = PromptGenerator.buildToolUsePrompt()

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
    /// For OpenAI sessions with tools, uses the static tool-use prompt.
    /// For legacy sessions (Fog, Local, Mock), re-fetches health data.
    @MainActor
    func resetChat() async {
        if llm is LLMOpenAISession {
            self.systemPrompt = PromptGenerator.buildToolUsePrompt()
        } else {
            self.systemPrompt = await self.generateSystemPrompt()
        }
        self.llm?.context.reset()
        self.llm?.context.append(systemMessage: self.systemPrompt)
    }
    
    /// Fetches updated health data using the `HealthDataFetcher`
    /// and passes it to the `PromptGenerator` to create the system prompt.
    private func generateSystemPrompt() async -> String {
        let healthData = await self.healthDataFetcher.fetchAndProcessHealthData()
        return PromptGenerator(with: healthData).buildMainPrompt()
    }
}
