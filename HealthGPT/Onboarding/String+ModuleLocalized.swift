//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

extension String {
    var moduleLocalized: String {
        String(localized: LocalizationValue(self))
    }
}
