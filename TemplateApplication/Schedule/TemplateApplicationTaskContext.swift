//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ModelsR4


enum TemplateApplicationTaskContext: Codable, Identifiable {
    case questionnaire(Questionnaire)
    
    
    var id: Questionnaire.ID {
        switch self {
        case let .questionnaire(questionnaire):
            return questionnaire.id
        }
    }
    
    var actionType: String {
        switch self {
        case .questionnaire:
            return String(localized: "TASK_CONTEXT_ACTION_QUESTIONNAIRE")
        }
    }
}
