//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct LazyText: View {
    private let text: String
    @State private var lines: [(linenumber: Int, text: String)] = []
    
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(lines, id: \.linenumber) { line in
                Text(line.text)
                    .multilineTextAlignment(.leading)
            }
        }
            .onAppear {
                var lineNumber = 0
                text.enumerateLines { line, _ in
                    lines.append((lineNumber, line))
                    lineNumber += 1
                }
            }
    }
    
    
    init(text: String) {
        self.text = text
    }
}
