//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct JSONView: View {
    @Environment(\.dismiss) private var dismiss
    private let json: String
    @State private var lines: [(linenumber: Int, text: String)] = []
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(lines, id: \.linenumber) { line in
                        Text(line.text)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    var lineNumber = 0
                    json.enumerateLines { line, _ in
                        lines.append((lineNumber, line))
                        lineNumber += 1
                    }
                }
        }
    }
    
    
    init(json: String) {
        self.json = json
    }
}


struct JSONView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            JSONView(json: "{}")
                .navigationTitle("JSON View")
        }
    }
}
