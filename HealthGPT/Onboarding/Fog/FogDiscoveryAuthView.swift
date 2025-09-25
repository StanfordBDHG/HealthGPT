//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziLLMFog
import SpeziViews
import SwiftUI


struct FogDiscoveryAuthView: View {
    @Environment(ManagedNavigationStack.Path.self) private var onboardingNavigationPath


    var body: some View {
        LLMFogDiscoveryAuthorizationView {
            self.onboardingNavigationPath.append(
                customView: FogResourceSelectionView()
            )
        }
    }
}
