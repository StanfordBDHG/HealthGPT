//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import HealthKit
import OpenAI
import SwiftUI


struct HealthGPTView: View {
    @State private var userMessage: String = ""
    @State private var messages: [Message] = []

    var body: some View {
        NavigationView {
            VStack {
                ChatView(messages: $messages)
                    .gesture(
                        TapGesture().onEnded {
                            UIApplication.shared.hideKeyboard()
                        }
                    )
                MessageInputView(userMessage: $userMessage, messages: $messages)
            }
            .navigationBarTitle("HealthGPT")
        }
    }
}
