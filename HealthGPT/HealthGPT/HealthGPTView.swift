//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import CardinalKitFHIR
import CardinalKitSecureStorage
import HealthKit
import OpenAI
import SwiftUI


struct HealthGPTView: View {
    @AppStorage(StorageKeys.openAIModel) var openAIModel = Model.gpt3_5Turbo
    @EnvironmentObject var secureStorage: SecureStorage<FHIR>
    @State private var messages: [Message] = []

    @State private var showAlert = false
    @State private var alertText = ""

    @StateObject private var messageHandler = MessageHandler()

    var body: some View {
        NavigationView {
            VStack {
                ChatView()
                    .environmentObject(messageHandler)
                    .gesture(
                        TapGesture().onEnded {
                            UIApplication.shared.hideKeyboard()
                        }
                    )
                MessageInputView()
                    .environmentObject(messageHandler)
            }
            .navigationBarTitle("HealthGPT")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Alert"),
                    message: Text(alertText),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                // Look for an stored API key
                var apiKey = ""
                if let storedApiKey = try? secureStorage.retrieveCredentials("openai-api-key", server: "openai.com") {
                    apiKey = storedApiKey.password
                } else {
                    alertText = "Could not find a valid API key."
                    self.showAlert.toggle()
                    return
                }

                // Assign the api key to the message handler
                messageHandler.updateAPIToken(apiKey)

                // Set the OpenAI model in the message handler
                messageHandler.updateOpenAIModel(openAIModel)
            }
        }
    }
}
