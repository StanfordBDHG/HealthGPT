//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FHIRQuestionnaires
import Questionnaires
import SwiftUI


struct QuestionnaireSection: Hashable {
    var questionnaires: [Questionnaire]
    var header: String
}


struct QuestionnaireList: View {
    @State private var presentQuestionnaire: Questionnaire?
    @State private var presentQuestionnaireJSON: Questionnaire?
    @State private var presentQuestionnaireResponses: Questionnaire?
    
    
    private var questionnaireSections: [QuestionnaireSection] = [
        QuestionnaireSection(
            questionnaires: Questionnaire.exampleQuestionnaires,
            header: String(localized: "QUESTIONNAIRES_LIST_EXAMPLES_HEADER")
        ),
        QuestionnaireSection(
            questionnaires: Questionnaire.researchQuestionnaires,
            header: String(localized: "QUESTIONNAIRES_LIST_RESEARCH_EXAMPLES_HEADER")
        )
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(questionnaireSections, id: \.self) { section in
                    Section {
                        ForEach(section.questionnaires, id: \.self) { questionnaire in
                            questionnaireButton(questionnaire)
                        }
                    } header: {
                        Text(section.header)
                    }
                }
            }
            .navigationTitle("QUESTIONNAIRES_LIST_TITLE")
        }
            .sheet(item: $presentQuestionnaire) { presentQuestionnaire in
                QuestionnaireView(questionnaire: presentQuestionnaire)
                    .interactiveDismissDisabled(true)
            }
            .sheet(item: $presentQuestionnaireJSON) { presentQuestionnaireJSON in
                QuestionnaireJSONView(questionnaire: presentQuestionnaireJSON)
            }
            .sheet(item: $presentQuestionnaireResponses) { presentQuestionnaireResponses in
                QuestionnaireResponsesView(questionnaire: presentQuestionnaireResponses)
            }
    }
    
    
    @ViewBuilder
    private func questionnaireButton(_ questionnaire: Questionnaire) -> some View {
        Button(questionnaire.title?.value?.string ?? String(localized: "QUESTIONNAIRES_LIST_BUTTON_DEFAULT_TITLE")) {
            presentQuestionnaire = questionnaire
        }
            .contextMenu {
                Button {
                    presentQuestionnaireJSON = questionnaire
                } label: {
                    Label(
                        String(localized: "QUESTIONNAIRES_LIST_VIEW_JSON"),
                        systemImage: "doc.badge.gearshape"
                    )
                }
                Button {
                    presentQuestionnaireResponses = questionnaire
                } label: {
                    Label(
                        String(localized: "QUESTIONNAIRES_LIST_VIEW_RESPONSES"),
                        systemImage: "arrow.right.doc.on.clipboard"
                    )
                }
            }
    }
}


struct QuestionnaireListView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireList()
    }
}
