//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2024 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum LLMSource: String, CaseIterable, Identifiable, Codable {
    case openai
    case fog
    case local

    var id: String {
        self.rawValue
    }
    
    var localizedDescription: LocalizedStringResource {
        switch self {
        case .openai:
            LocalizedStringResource("OPENAI_LLM_LABEL")
        case .fog:
            LocalizedStringResource("FOG_LLM_LABEL")
        case .local:
            LocalizedStringResource("LOCAL_LLM_LABEL")
        }
    }
}
