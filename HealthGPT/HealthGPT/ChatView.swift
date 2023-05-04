//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var messageHandler: MessageHandler

    var body: some View {
        ScrollView {
            ScrollViewReader { value in
                ForEach(messageHandler.messages.indices, id: \.self) { message in
                    MessageView(message: messageHandler.messages[message]).id(message)
                }
                .onChange(of: messageHandler.messages.count) { newValue in
                    withAnimation {
                        value.scrollTo(newValue - 1)
                    }
                }
            }
        }
    }
}
