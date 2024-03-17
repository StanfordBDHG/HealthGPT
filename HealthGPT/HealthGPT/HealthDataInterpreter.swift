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
import SpeziLLMOpenAI
import SpeziSpeechSynthesizer


@Observable
class HealthDataInterpreter: DefaultInitializable, Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency private var llmRunner: LLMRunner
    
    var llm: (any LLMSession)?
    
    required init() { }
    
    func generateSystemPrompt() async throws -> String {
        let healthDataFetcher = HealthDataFetcher()
        let healthData = try await healthDataFetcher.fetchAndProcessHealthData()
        return PromptGenerator(with: healthData).buildMainPrompt()
    }
    
    @MainActor
    func prepareLLM(with model: LLMOpenAIModelType) async throws {
        guard llm == nil else {
            return
        }
        
        let llmSchema = LLMOpenAISchema(parameters: .init(modelType: model))
        let llm = llmRunner(with: llmSchema)
        
        let systemPrompt = try await self.generateSystemPrompt()
        llm.context.append(systemMessage: systemPrompt)
        self.llm = llm
    }
    
    @MainActor
    func queryLLM() async throws {
        guard let llm,
              llm.context.last?.role == .user || !(llm.context.contains(where: { $0.role == .assistant }) ) else {
            return
        }
        
        let stream = try await llm.generate()
        
        for try await token in stream {
            llm.context.append(assistantOutput: token)
        }
    }
}
