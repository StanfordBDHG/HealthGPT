//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import OpenAI
import SpeziFHIR
import SpeziSecureStorage
import SwiftUI

struct HealthGPTView: View {
    @AppStorage(StorageKeys.openAIModel) var openAIModel = Model.gpt3_5Turbo
    @EnvironmentObject var secureStorage: SecureStorage<FHIR>
    @State private var messages: [Message] = []

    @State private var showAlert = false
    @State private var alertText = ""

    @StateObject private var messageManager = MessageManager()

    var body: some View {
        NavigationView {
            VStack {
                ChatView()
                    .environmentObject(messageManager)
                    .gesture(
                        TapGesture().onEnded {
                            UIApplication.shared.hideKeyboard()
                        }
                    )
                MessageInputView()
                    .environmentObject(messageManager)
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
                updateApiKeyAndModel()
            }
        }
    }

    private func updateApiKeyAndModel() {
        guard let apiKey = try? secureStorage.retrieveCredentials(
            "openai-api-key",
            server: "openai.com"
        )?.password else {
            alertText = "Could not find a valid API key."
            self.showAlert.toggle()
            return
        }

        messageManager.updateAPIToken(apiKey)
        messageManager.updateOpenAIModel(openAIModel)
    }
}
