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
import CardinalKitOnboarding
import FirebaseAuth
import SwiftUI


struct AccountSetup: View {
    @Binding private var onboardingSteps: [OnboardingFlow.Step]
    @EnvironmentObject var account: Account


    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "ACCOUNT_TITLE".moduleLocalized,
                        subtitle: "ACCOUNT_SUBTITLE".moduleLocalized
                    )
                    Spacer(minLength: 0)
                    accountImage
                    accountDescription
                    Spacer(minLength: 0)
                }
            }, actionView: {
                actionView
            }
        )
            .onReceive(account.objectWillChange) {
                if account.signedIn {
                    onboardingSteps.append(.healthKitPermissions)
                    // Unfortunately, SwiftUI currently animates changes in the navigation path that do not change
                    // the current top view. Therefore we need to do the following async procedure to remove the
                    // `.login` and `.signUp` steps while disabling the animations before and re-enabling them
                    // after the elements have been changed.
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(1.0))
                        UIView.setAnimationsEnabled(false)
                        onboardingSteps.removeAll(where: { $0 == .login || $0 == .signUp })
                        try? await Task.sleep(for: .seconds(1.0))
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
    }

    @ViewBuilder
    private var accountImage: some View {
        Group {
            if account.signedIn {
                Image(systemName: "person.badge.shield.checkmark.fill")
            } else {
                Image(systemName: "person.fill.badge.plus")
            }
        }
            .font(.system(size: 150))
            .foregroundColor(.accentColor)
    }

    @ViewBuilder
    private var accountDescription: some View {
        VStack {
            Group {
                if account.signedIn {
                    Text("ACCOUNT_SIGNED_IN_DESCRIPTION")
                } else {
                    Text("ACCOUNT_SETUP_DESCRIPTION")
                }
            }
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)
            if account.signedIn {
                UserView()
                    .padding()
                Button("Logout", role: .destructive) {
                    try? Auth.auth().signOut()
                }
            }
        }
    }

    @ViewBuilder
    private var actionView: some View {
        if account.signedIn {
            OnboardingActionsView(
                "ACCOUNT_NEXT".moduleLocalized,
                action: {
                    onboardingSteps.append(.healthKitPermissions)
                }
            )
        } else {
            OnboardingActionsView(
                primaryText: "ACCOUNT_SIGN_UP".moduleLocalized,
                primaryAction: {
                    onboardingSteps.append(.signUp)
                },
                secondaryText: "ACCOUNT_LOGIN".moduleLocalized,
                secondaryAction: {
                    onboardingSteps.append(.login)
                }
            )
        }
    }


    init(onboardingSteps: Binding<[OnboardingFlow.Step]>) {
        self._onboardingSteps = onboardingSteps
    }
}


#if DEBUG
struct AccountSetup_Previews: PreviewProvider {
    @State private static var path: [OnboardingFlow.Step] = []


    static var previews: some View {
        AccountSetup(onboardingSteps: $path)
            .environmentObject(Account(accountServices: []))
            .environmentObject(FirebaseAccountConfiguration<FHIR>(emulatorSettings: (host: "localhost", port: 9099)))
    }
}
#endif
