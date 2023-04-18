//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CardinalKitAccount
import class CardinalKitFHIR.FHIR
import CardinalKitFirebaseAccount
import CardinalKitViews
import Foundation
import SwiftUI


struct UserView: View {
    @EnvironmentObject var account: Account
    @EnvironmentObject var firebaseAccountConfiguration: FirebaseAccountConfiguration<FHIR>


    var body: some View {
        userInformation
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
                    .shadow(color: .gray, radius: 2)
            )
    }


    @ViewBuilder
    private var userInformation: some View {
        HStack(spacing: 16) {
            if account.signedIn,
               let user = firebaseAccountConfiguration.user,
               let displayName = user.displayName,
               let name = try? PersonNameComponents(displayName) {
                UserProfileView(name: name)
                    .frame(height: 30)
                VStack(alignment: .leading, spacing: 4) {
                    Text(name.formatted(.name(style: .medium)))
                    if let email = user.email {
                        Text(email)
                    }
                }
                Spacer()
            } else {
                Spacer()
                VStack(spacing: 16) {
                    ProgressView()
                    Text("USER_VIEW_LOADING")
                        .multilineTextAlignment(.center)
                }
                Spacer()
            }
        }
    }
}


#if DEBUG
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
            .padding()
            .environmentObject(FirebaseAccountConfiguration<FHIR>(emulatorSettings: (host: "localhost", port: 9099)))
    }
}
#endif
