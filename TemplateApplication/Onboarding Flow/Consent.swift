//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Onboarding
import SwiftUI


struct Consent: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @Binding private var onboardingSteps: [OnboardingFlow.Step]
    
    
    private var consentDocument: Data {
        guard let data = NSDataAsset(name: "ConsentDocument")?.data else {
            return Data(String(localized: "CONSENT_LOADING_ERROR").utf8)
        }
        return data
    }
    
    var body: some View {
        ConsentView(
            header: {
                OnboardingTitleView(
                    title: "CONSENT_TITLE",
                    subtitle: "CONSENT_SUBTITLE"
                )
            },
            asyncMarkdown: {
                consentDocument
            },
            action: {
                completedOnboardingFlow = true
            }
        )
    }
    
    
    init(onboardingSteps: Binding<[OnboardingFlow.Step]>) {
        self._onboardingSteps = onboardingSteps
    }
}


struct Consent_Previews: PreviewProvider {
    @State private static var path: [OnboardingFlow.Step] = []
    
    
    static var previews: some View {
        Consent(onboardingSteps: $path)
    }
}
