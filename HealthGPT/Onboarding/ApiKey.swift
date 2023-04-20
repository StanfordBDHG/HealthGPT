//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import CardinalKitFHIR
import CardinalKitOnboarding
import CardinalKitSecureStorage
import SwiftUI


struct ApiKey: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @Binding private var onboardingSteps: [OnboardingFlow.Step]
    @EnvironmentObject var secureStorage: SecureStorage<FHIR>
    @State var enteredKey = ""

    private var apiKeyFromPlist: String? {
        guard let filePath = Bundle.main.path(forResource: "OpenAI-Info", ofType: "plist"),
              let data = FileManager.default.contents(atPath: filePath) else {
            return nil
        }

        do {
            guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
                  let value = plist["API_KEY"] as? String else {
                return nil
            }

            if value.starts(with: "_") {
                return nil
            }
            return value
        } catch {
            return nil
        }
    }

    func goToNextSection() {
        onboardingSteps.append(.healthKitPermissions)
    }

    var body: some View {
        OnboardingView(
            titleView: {
                OnboardingTitleView(
                    title: "Enter your OpenAI API Key",
                    subtitle: "Please obtain an API key from the OpenAI website and enter it below."
                )
            },
            contentView: {
                TextField("Enter API Key", text: $enteredKey)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            },
            actionView: {
                OnboardingActionsView(
                    "Save Key",
                    action: {
                        do {
                            let openAiCredentials = Credentials(
                                username: "openai-api-key",
                                password: enteredKey
                            )
                            try secureStorage.store(
                                credentials: openAiCredentials,
                                server: "openai.org",
                                storageScope: .keychain
                            )
                            goToNextSection()
                        } catch {
                            print("Error when storing API Key.")
                        }
                    }
                )
            }).onAppear {
                // If an OpenAI API Key already exists in SecureStorage, skip this section
                if (try? secureStorage.retrieveCredentials(
                    "openai-api-key",
                    server: "openai.org"
                )) != nil {
                    goToNextSection()
                }

                // If an API Key is present in the OpenAI-Info.plist file, store it into SecureStorage
                // and skip this section.
                if let apiKeyFromPlist {
                    do {
                        let openAiCredentials = Credentials(
                            username: "openai-api-key",
                            password: apiKeyFromPlist
                        )
                        try secureStorage.store(
                            credentials: openAiCredentials,
                            server: "openai.org",
                            storageScope: .keychain
                        )
                        goToNextSection()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
    }


    init(onboardingSteps: Binding<[OnboardingFlow.Step]>) {
        self._onboardingSteps = onboardingSteps
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
