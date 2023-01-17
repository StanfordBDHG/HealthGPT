//
// This source file is part of the Stanforf CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


@main
struct TemplateApplication: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                Image(systemName: "hand.wave.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.accentColor)
                    .padding()
                Text("Welcome to the Template Application!")
                    .bold()
            }
        }
    }
}
