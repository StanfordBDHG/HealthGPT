//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Onboarding
import SwiftUI


struct InterestingModules: View {
    @Binding private var onboardingSteps: [OnboardingFlow.Step]
    
    
    var body: some View {
        SequentialOnboardingView(
            title: "INTERESTING_MODULES_TITLE".moduleLocalized,
            subtitle: "INTERESTING_MODULES_SUBTITLE".moduleLocalized,
            content: [
                .init(
                    title: "INTERESTING_MODULES_AREA1_TITLE".moduleLocalized,
                    description: "INTERESTING_MODULES_AREA1_DESCRIPTION".moduleLocalized
                ),
                .init(
                    title: "INTERESTING_MODULES_AREA2_TITLE".moduleLocalized,
                    description: "INTERESTING_MODULES_AREA2_DESCRIPTION".moduleLocalized
                ),
                .init(
                    title: "INTERESTING_MODULES_AREA3_TITLE".moduleLocalized,
                    description: "INTERESTING_MODULES_AREA3_DESCRIPTION".moduleLocalized
                ),
                .init(
                    title: "INTERESTING_MODULES_AREA4_TITLE".moduleLocalized,
                    description: "INTERESTING_MODULES_AREA4_DESCRIPTION".moduleLocalized
                )
            ],
            actionText: "INTERESTING_MODULES_BUTTON".moduleLocalized,
            action: {
                #if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
                print("PKCanvas view-related views are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
                onboardingSteps.append(.healthKitPermissions)
                #else
                onboardingSteps.append(.consent)
                #endif
            }
        )
    }
    
    
    init(onboardingSteps: Binding<[OnboardingFlow.Step]>) {
        self._onboardingSteps = onboardingSteps
    }
}


struct ThingsToKnow_Previews: PreviewProvider {
    @State private static var path: [OnboardingFlow.Step] = []
    
    
    static var previews: some View {
        InterestingModules(onboardingSteps: $path)
    }
}
