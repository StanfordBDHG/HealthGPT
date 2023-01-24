//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension String {
    init?<T: Encodable>(jsonFrom element: T) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        
        guard let data = try? encoder.encode(element) else {
            return nil
        }
        
        self = String(decoding: data, as: UTF8.self)
    }
}
