//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct MockUpload: Identifiable, Hashable {
    enum UploadType {
        case add
        case delete
    }
    
    
    let identifier: String
    let date = Date()
    let type: UploadType
    let path: String
    let body: String?
    
    
    var id: String {
        "\(type): \(path)/\(identifier) at \(date.debugDescription)"
    }
    
    
    init(id: String, type: UploadType, path: String, body: String? = nil) {
        self.identifier = id
        self.type = type
        self.path = path
        self.body = body
    }
}
