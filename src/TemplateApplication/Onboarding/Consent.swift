//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CardinalKitOnboarding
import SwiftUI


struct Consent: View {
    @Binding private var onboardingSteps: [OnboardingFlow.Step]


    private var consentDocument: Data {
        guard let path = Bundle.main.url(forResource: "ConsentDocument", withExtension: "md"),
              let data = try? Data(contentsOf: path) else {
            return Data("CONSENT_LOADING_ERROR".moduleLocalized.utf8)
        }
        return data
    }

    var body: some View {
        ConsentView(
            header: {
                OnboardingTitleView(
                    title: "CONSENT_TITLE".moduleLocalized,
                    subtitle: "CONSENT_SUBTITLE".moduleLocalized
                )
            },
            asyncMarkdown: {
                consentDocument
            },
            action: {
                if !FeatureFlags.disableFirebase {
                    onboardingSteps.append(.accountSetup)
                } else {
                    onboardingSteps.append(.healthKitPermissions)
                }
            }
        )
    }


    init(onboardingSteps: Binding<[OnboardingFlow.Step]>) {
        self._onboardingSteps = onboardingSteps
    }
}


#if DEBUG
struct Consent_Previews: PreviewProvider {
    @State private static var path: [OnboardingFlow.Step] = []


    static var previews: some View {
        Consent(onboardingSteps: $path)
    }
}
#endif
