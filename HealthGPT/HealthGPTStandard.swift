//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziHealthKit


actor HealthGPTStandard: Standard, ObservableObject, ObservableObjectProvider, HealthKitConstraint {
    func add(sample: HKSample) async { }
    func remove(sample: HKDeletedObject) async { }
}
