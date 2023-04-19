//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import Foundation

struct Message: Identifiable {
    var id = UUID()
    var content: String
    var isBot: Bool
}
