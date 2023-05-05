//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ChatView: View {
    @Binding var messages: [Message]

    var body: some View {
        ScrollView {
            ScrollViewReader { value in
                ForEach(messages.indices, id: \.self) { message in
                    MessageView(message: messages[message]).id(message)
                }
                .onChange(of: messages.count) { newValue in
                    withAnimation {
                        value.scrollTo(newValue - 1)
                    }
                }
            }
        }
    }
}
