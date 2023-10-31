//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI


struct Welcome: View {
    @EnvironmentObject private var onboardingNavigationPath: OnboardingNavigationPath


    var body: some View {
        OnboardingView(
            title: "WELCOME_TITLE".moduleLocalized,
            subtitle: "WELCOME_SUBTITLE".moduleLocalized,
            areas: [
                .init(
                    icon: Image(systemName: "shippingbox.fill"), // swiftlint:disable:this accessibility_label_for_image
                    title: "WELCOME_AREA1_TITLE".moduleLocalized,
                    description: "WELCOME_AREA1_DESCRIPTION".moduleLocalized
                ),
                .init(
                    icon: Image(systemName: "applewatch.side.right"), // swiftlint:disable:this accessibility_label_for_image
                    title: "WELCOME_AREA2_TITLE".moduleLocalized,
                    description: "WELCOME_AREA2_DESCRIPTION".moduleLocalized
                ),
                .init(
                    icon: Image(systemName: "list.bullet.clipboard.fill"), // swiftlint:disable:this accessibility_label_for_image
                    title: "WELCOME_AREA3_TITLE".moduleLocalized,
                    description: "WELCOME_AREA3_DESCRIPTION".moduleLocalized
                )
            ],
            actionText: "WELCOME_BUTTON".moduleLocalized,
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
    }
}


#if DEBUG
struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome()
    }
}
#endif
