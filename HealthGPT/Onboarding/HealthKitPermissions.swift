//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog
import SpeziHealthKit
import SpeziOnboarding
import SwiftUI


struct HealthKitPermissions: View {
    @Environment(HealthKit.self) var healthKitDataSource
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @State var healthKitProcessing = false
    let logger = Logger(subsystem: "HealthGPT", category: "Onboarding")


    var body: some View {
        OnboardingView(
            contentView: {
                VStack {
                    OnboardingTitleView(
                        title: "HEALTHKIT_PERMISSIONS_TITLE".moduleLocalized,
                        subtitle: "HEALTHKIT_PERMISSIONS_SUBTITLE".moduleLocalized
                    )
                    Spacer()
                    Image(systemName: "heart.text.square.fill")
                        .accessibilityHidden(true)
                        .font(.system(size: 150))
                        .foregroundColor(.accentColor)
                    Text("HEALTHKIT_PERMISSIONS_DESCRIPTION")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 16)
                    Spacer()
                }
            }, actionView: {
                OnboardingActionsView(
                    "HEALTHKIT_PERMISSIONS_BUTTON",
                    action: {
                        do {
                            healthKitProcessing = true
                            // HealthKit is not available in the preview simulator.
                            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                                try await _Concurrency.Task.sleep(for: .seconds(5))
                            } else {
                                try await healthKitDataSource.askForAuthorization()
                            }
                        } catch {
                            logger.error("Could not request HealthKit permissions: \(error.localizedDescription)")
                        }
                        onboardingNavigationPath.nextStep()
                        healthKitProcessing = false
                    }
                )
            }
        )
            .navigationBarBackButtonHidden(healthKitProcessing)
    }
}


#if DEBUG
struct HealthKitPermissions_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitPermissions()
    }
}
#endif
