//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SpeziViews
import SwiftUI


struct FogInformationView: View {
    @Environment(ManagedNavigationStack.Path.self) private var onboardingNavigationPath


    var body: some View {
        OnboardingView(
            title: "LLM Fog Mode".moduleLocalized,
            subtitle: "Run LLMs locally. Keep data inside your network.".moduleLocalized,
            areas: [
                .init(
                    iconSymbol: "network.badge.shield.half.filled",
                    title: "Private by Design".moduleLocalized,
                    description: "All LLM inference happens directly within your network - nothing is sent to remote servers.".moduleLocalized
                ),
                .init(
                    iconSymbol: "server.rack",
                    title: "Local Fog Nodes".moduleLocalized,
                    description: "Computation is performed on so-called fog nodes, running directly inside your own network.".moduleLocalized
                ),
                .init(
                    iconSymbol: "exclamationmark.circle.fill",
                    title: "Setup Required".moduleLocalized,
                    description: """
                    A fog node must be configured in your local network. Please consult the HealthGPT docs for setup instructions.
                    """.moduleLocalized
                )
            ],
            actionText: "Start Client Setup".moduleLocalized,
            action: {
                self.onboardingNavigationPath.append(
                    customView: FogDiscoveryAuthView()
                )
            }
        )
    }
}


#if DEBUG
#Preview {
    FogInformationView()
}
#endif
