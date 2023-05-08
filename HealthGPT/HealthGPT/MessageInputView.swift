//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OpenAI
import SwiftUI


struct MessageInputView: View {
    @EnvironmentObject var messageManager: MessageManager
    @State private var showingSheet = false
    @State private var userMessage = ""

    var body: some View {
        HStack {
            TextField(
                messageManager.isQuerying ? "HealthGPT is thinking 🤔..." : "Type a message...",
                text: $userMessage,
                axis: .vertical
            )
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .lineLimit(1...5)
                .disabled(messageManager.isQuerying)

            Button(action: {
                _Concurrency.Task {
                    let userMessageToQuery = userMessage
                    userMessage = ""
                    await messageManager.processUserMessage(userMessageToQuery)
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .padding(.horizontal, 10)
                    .foregroundColor(
                        userMessage.isEmpty ? Color(.systemGray6) : Color(red: 0.902, green: 0.404, blue: 0.404)
                    )
            }
            .disabled(userMessage.isEmpty)

            Button(action: {
                showingSheet.toggle()
            }) {
                Image(systemName: "gearshape.fill")
                    .padding(.horizontal, 10)
            }
            .sheet(isPresented: $showingSheet) {
                SettingsView()
            }
        }
        .padding(10)
    }
}
