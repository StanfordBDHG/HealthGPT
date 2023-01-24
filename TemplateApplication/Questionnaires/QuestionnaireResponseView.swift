//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FHIR
import FHIRQuestionnaires
import ModelsR4
import SwiftUI


struct QuestionnaireResponsesView: View {
    @EnvironmentObject private var standard: FHIR
    private let questionnaire: Questionnaire
    @State private var selection: QuestionnaireResponse?
    @State private var responses: [QuestionnaireResponse] = []
    
    
    var body: some View {
        NavigationSplitView {
            Group {
                if responses.isEmpty {
                    Text("QUESTIONNAIRES_RESPONSES_LIST_NO_RESPONSES")
                } else {
                    List(responses, id: \.self, selection: $selection) { response in
                        NavigationLink(description(for: response), value: response)
                    }
                }
            }
                .navigationTitle("QUESTIONNAIRES_RESPONSES_LIST_TITLE")
        } detail: {
            if let response = selection {
                JSONView(json: String(jsonFrom: response) ?? "QUESTIONNAIRE_RESPONSES_ERROR")
                    .navigationTitle(description(for: response))
            } else {
                Text("QUESTIONNAIRES_RESPONSES_LIST_NO_SELECTION")
            }
        }
            .navigationTitle("QUESTIONNAIRES_RESPONSES_LIST_TITLE")
            .task {
                self.responses = await standard
                    .resources(resourceType: QuestionnaireResponse.self)
                    .filter { questionnaireResponse in
                        questionnaireResponse.questionnaire?.value?.url == questionnaire.url?.value?.url
                    }
            }
    }
    
    
    init(questionnaire: Questionnaire) {
        self.questionnaire = questionnaire
    }
    
    
    private func description(for response: QuestionnaireResponse) -> String {
        guard let date = try? response.authored?.value?.asNSDate() else {
            return String(localized: "QUESTIONNAIRES_RESPONSES_DATE_ERROR_MESSAGE")
        }
        return RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
    }
}
