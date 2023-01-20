//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct HomeView: View {
    enum Tabs: String {
        case contact
    }
    
    
    @AppStorage(StorageKeys.homeTabSelection) var selectedTab = Tabs.contact
    
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Contacts()
                .tag(Tabs.contact)
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
