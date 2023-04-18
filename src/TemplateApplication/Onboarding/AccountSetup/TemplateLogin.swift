//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CardinalKitAccount
import CardinalKitOnboarding
import SwiftUI


struct TemplateLogin: View {
    var body: some View {
        Login {
            IconView()
                .padding(.top, 32)
            Text("LOGIN_SUBTITLE")
                .multilineTextAlignment(.center)
                .padding()
                .padding()
            Spacer(minLength: 0)
        }
            .navigationBarTitleDisplayMode(.large)
    }
}


#if DEBUG
struct TemplateLogin_Previews: PreviewProvider {
    static var previews: some View {
        TemplateLogin()
            .environmentObject(Account(accountServices: []))
    }
}
#endif
