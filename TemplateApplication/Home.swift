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


struct HomeView: View {
    enum Tabs: String {
        case contact
        case questionnaires
    }
    
    
    @AppStorage(StorageKeys.homeTabSelection) var selectedTab = Tabs.contact
    
    
    var body: some View {
        TabView(selection: $selectedTab) {
            QuestionnaireList()
                .tag(Tabs.questionnaires)
                .tabItem {
                    Label("QUESTIONNAIRES_TAB_TITLE", systemImage: "list.clipboard")
                }
            Contacts()
                .tag(Tabs.contact)
                .tabItem {
                    Label("CONTACTS_TAB_TITLE", systemImage: "person.fill")
                }
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
