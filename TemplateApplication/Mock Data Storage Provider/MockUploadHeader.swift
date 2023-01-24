//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MockUploadHeader: View {
    let mockUpload: MockUpload
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 12) {
                switch mockUpload.type {
                case .add:
                    Image(systemName: "arrow.up.doc.fill")
                        .foregroundColor(.green)
                case .delete:
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                }
                Text("/\(mockUpload.path)/")
            }
                .font(.title3)
                .bold()
                .padding(.bottom, 12)
            Text("On \(format(mockUpload.date))")
                .font(.subheadline)
            Text("\(mockUpload.identifier)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
    
    
    private func format(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        return dateFormatter.string(from: date)
    }
}
