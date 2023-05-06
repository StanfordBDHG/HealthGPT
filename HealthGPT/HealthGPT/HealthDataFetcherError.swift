//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum HealthDataFetcherError: Error {
    case healthDataNotAvailable
    case invalidObjectType
    case resultsNotFound
    case authorizationFailed
}
