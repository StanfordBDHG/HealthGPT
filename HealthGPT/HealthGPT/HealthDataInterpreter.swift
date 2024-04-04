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
import SpeziLLMLocal
import SpeziLLMOpenAI
import SpeziSpeechSynthesizer


@Observable
class HealthDataInterpreter: DefaultInitializable, Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency private var llmRunner: LLMRunner
    @ObservationIgnored @Dependency private var healthDataFetcher: HealthDataFetcher
    
    var llm: (any LLMSession)?
    @ObservationIgnored private var systemPrompt = ""
    
    required init() { }
    
    
    /// Creates an `LLMRunner`, from an `LLMSchema` and injects the system prompt
    /// into the context, and assigns the resulting `LLMSession` to the `llm` property. For more
    /// information, please refer to the [`SpeziLLM`](https://swiftpackageindex.com/StanfordSpezi/SpeziLLM/documentation/spezillm) documentation.
    ///
    /// - Parameter schema: the LLMSchema to use
    @MainActor
    func prepareLLM(with schema: any LLMSchema) async {
        let llm = llmRunner(with: schema)
        systemPrompt = await generateSystemPrompt()
        llm.context.append(systemMessage: systemPrompt)
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
        systemPrompt = await generateSystemPrompt()
        llm?.context.reset()
        llm?.context.append(systemMessage: systemPrompt)
    }
    
    /// Fetches updated health data using the `HealthDataFetcher`
    /// and passes it to the `PromptGenerator` to create the system prompt.
    private func generateSystemPrompt() async -> String {
        let healthData = await healthDataFetcher.fetchAndProcessHealthData()
        return PromptGenerator(with: healthData).buildMainPrompt()
    }
}
