//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors & Project Contributors
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI


struct Disclaimer: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    
    
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
                onboardingNavigationPath.nextStep()
            }
        )
    }
}


#if DEBUG
struct Disclaimer_Previews: PreviewProvider {
    static var previews: some View {
        Disclaimer()
    }
}
#endif
