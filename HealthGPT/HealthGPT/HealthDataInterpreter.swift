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
    
    var llmSchema: LLMOpenAISchema {
        .init(
            parameters: .init(
                modelType: .gpt4_turbo_preview
            )
        )
    }

    required init() { }
    
    func generateSystemPrompt() async throws -> String {
        let healthDataFetcher = HealthDataFetcher()
        let healthData = try await healthDataFetcher.fetchAndProcessHealthData()
        let generator = PromptGenerator(with: healthData)
        let mainPrompt = generator.buildMainPrompt()
        return mainPrompt
    }
    
    @MainActor
    func prepareLLM() async {
        guard llm == nil else {
            return
        }
        
        let llm = llmRunner(with: llmSchema)
        
        guard let systemPrompt = try? await self.generateSystemPrompt() else {
            return
        }
        
        llm.context.append(systemMessage: systemPrompt)
        self.llm = llm
    }
    
    @MainActor
    func queryLLM() async throws {
        guard let llm,
              llm.context.last?.role == .user || !(llm.context.contains(where: { $0.role == .assistant }) ) else {
            return
        }
        
        guard let stream = try? await llm.generate() else {
            return
        }
        
        for try await token in stream {
            llm.context.append(assistantOutput: token)
        }
    }
}
