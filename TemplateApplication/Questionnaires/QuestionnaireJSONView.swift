//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FHIRQuestionnaires
import ModelsR4
import SwiftUI


struct QuestionnaireJSONView: View {
    private let questionnaire: Questionnaire
    
    
    var body: some View {
        NavigationStack {
            JSONView(json: String(jsonFrom: questionnaire) ?? String(localized: "QUESTIONNAIRES_ERROR_MESSAGE"))
                .navigationTitle(questionnaire.title?.value?.string ?? String(localized: "QUESTIONNAIRES_DEFAULT_TITLE"))
        }
            .navigationBarTitleDisplayMode(.inline)
    }
    
    
    init(questionnaire: Questionnaire) {
        self.questionnaire = questionnaire
    }
}


struct QuestionnaireJSONView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireJSONView(questionnaire: .textValidationExample)
    }
}
