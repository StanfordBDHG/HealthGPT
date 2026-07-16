//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum HealthDataFetcherError: LocalizedError {
    case invalidObjectType
    case unsupportedMetric
    case invalidDateRange

    var errorDescription: String? {
        switch self {
        case .invalidObjectType:
            "The requested HealthKit type isn't available."
        case .unsupportedMetric:
            "This metric isn't supported by this tool."
        case .invalidDateRange:
            "The requested date range is invalid."
        }
    }
}
