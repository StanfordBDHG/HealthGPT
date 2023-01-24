//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension Array: RawRepresentable where Element: Codable {
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let rawValue = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return rawValue
    }
    
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data) else {
            return nil
        }
        self = result
    }
}
