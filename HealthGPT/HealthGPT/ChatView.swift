//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
// SPDX-FileCopyrightText: Created by Varun Shenoy on 4/13/23.
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
