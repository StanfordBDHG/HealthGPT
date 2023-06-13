//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFHIR
import SpeziOnboarding
import SpeziSecureStorage
import SwiftUI


struct ApiKey: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @Binding private var onboardingSteps: [OnboardingFlow.Step]
    @EnvironmentObject var secureStorage: SecureStorage<FHIR>
    @State var enteredKey = ""

    private var apiKeyFromPlist: String {
        var result = ""

        if let filePath = Bundle.main.path(forResource: "OpenAI-Info", ofType: "plist"),
           let data = FileManager.default.contents(atPath: filePath) {
            do {
                if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
                   let value = plist["API_KEY"] as? String,
                   !value.starts(with: "_") {
                    result = value
                }
            } catch {
                print("Error: \(error)")
            }
        }
        
        return result
    }

    var body: some View {
        OnboardingView(
            titleView: {
                OnboardingTitleView(
                    title: "API_KEY_TITLE".moduleLocalized,
                    subtitle: "API_KEY_SUBTITLE".moduleLocalized
                )
            },
            contentView: {
                TextField("Enter API Key", text: $enteredKey)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onAppear {
                        enteredKey = apiKeyFromPlist
                    }
            },
            actionView: {
                OnboardingActionsView(
                    "Save API Key",
                    action: {
                        do {
                            let openAiCredentials = Credentials(
                                username: "openai-api-key",
                                password: self.enteredKey
                            )
                            try secureStorage.store(
                                credentials: openAiCredentials,
                                server: "openai.com",
                                storageScope: .keychain
                            )
                            onboardingSteps.append(.modelSelection)
                        } catch {
                            print("Error when storing API Key.")
                        }
                    }
                )
                .disabled(self.enteredKey.isEmpty)
            }
        )
    }

    init(onboardingSteps: Binding<[OnboardingFlow.Step]>) {
        self._onboardingSteps = onboardingSteps
        UITextField.appearance().clearButtonMode = .whileEditing
    }
}

#if DEBUG
struct ApiKey_Previews: PreviewProvider {
    @State private static var path: [OnboardingFlow.Step] = []


    static var previews: some View {
        ApiKey(onboardingSteps: $path)
    }
}
#endif
