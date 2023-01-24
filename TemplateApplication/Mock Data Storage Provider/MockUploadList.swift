//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MockUploadList: View {
    @EnvironmentObject var mockDataStorageProvider: MockDataStorageProvider
    
    
    var body: some View {
        NavigationStack {
            List(mockDataStorageProvider.mockUploads) { mockUpload in
                NavigationLink(value: mockUpload) {
                    MockUploadHeader(mockUpload: mockUpload)
                }
            }
                .navigationDestination(for: MockUpload.self) { mockUpload in
                    MockUploadDetailView(mockUpload: mockUpload)
                }
                .navigationTitle("MOCK_UPLOAD_LIST_TITLE")
        }
    }
    
    
    private func format(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        return dateFormatter.string(from: date)
    }
}


struct MockUploadsList_Previews: PreviewProvider {
    static var previews: some View {
        MockUploadList()
            .environmentObject(MockDataStorageProvider())
    }
}
