//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MockUploadDetailView: View {
    let mockUpload: MockUpload
    
    
    var body: some View {
        List {
            Section("MOCK_UPLOAD_DETAIL_HEADER") {
                MockUploadHeader(mockUpload: mockUpload)
            }
            Section("MOCK_UPLOAD_DETAIL_BODY") {
                LazyText(text: mockUpload.body ?? "")
            }
        }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
    }
}
