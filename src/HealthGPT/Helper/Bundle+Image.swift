//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension Foundation.Bundle {
    /// Loads an image from the `Bundle` instance.
    /// - Parameters:
    ///   - name: The name of the image.
    ///   - fileExtension: The file extension of the image.
    /// - Returns: Returns the `UIImage` loaded from the `Bundle` instance.
    func image(withName name: String, fileExtension: String) -> UIImage {
        guard let resourceURL = self.url(forResource: name, withExtension: fileExtension) else {
            fatalError("Could not find the file \"\(name).\(fileExtension)\" in the bundle.")
        }

        guard let resourceData = try? Data(contentsOf: resourceURL),
              let image = UIImage(data: resourceData) else {
            fatalError("Decode the image named \"\(name).\(fileExtension)\"")
        }

        return image
    }
}
