//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import CardinalKitOnboarding
import SwiftUI


struct Welcome: View {
    @Binding private var onboardingSteps: [OnboardingFlow.Step]


    var body: some View {
        OnboardingView(
            title: "WELCOME_TITLE".moduleLocalized,
            subtitle: "WELCOME_SUBTITLE".moduleLocalized,
            areas: [
                .init(
                    icon: Image(systemName: "apps.iphone"),
                    title: "WELCOME_AREA1_TITLE".moduleLocalized,
                    description: "WELCOME_AREA1_DESCRIPTION".moduleLocalized
                ),
                .init(
                    icon: Image(systemName: "shippingbox.fill"),
                    title: "WELCOME_AREA2_TITLE".moduleLocalized,
                    description: "WELCOME_AREA2_DESCRIPTION".moduleLocalized
                ),
                .init(
                    icon: Image(systemName: "list.bullet.clipboard.fill"),
                    title: "WELCOME_AREA3_TITLE".moduleLocalized,
                    description: "WELCOME_AREA3_DESCRIPTION".moduleLocalized
                )
            ],
            actionText: "WELCOME_BUTTON".moduleLocalized,
            action: {
                onboardingSteps.append(.disclaimer)
            }
        )
    }


    init(onboardingSteps: Binding<[OnboardingFlow.Step]>) {
        self._onboardingSteps = onboardingSteps
    }
}


#if DEBUG
struct Welcome_Previews: PreviewProvider {
    @State private static var path: [OnboardingFlow.Step] = []


    static var previews: some View {
        Welcome(onboardingSteps: $path)
    }
}
#endif
