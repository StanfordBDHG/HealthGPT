//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziHealthKit
import SwiftUI


actor HealthGPTStandard: Standard, HealthKitConstraint {
    func handleNewSamples<Sample>(
        _ addedSamples: some Collection,
        ofType sampleType: SpeziHealthKit.SampleType<Sample>
    ) async where Sample: SpeziHealthKit._HKSampleWithSampleType {
        // Not implemented
    }
    
    func handleDeletedObjects<Sample>(
        _ deletedObjects: some Collection<HKDeletedObject>,
        ofType sampleType: SpeziHealthKit.SampleType<Sample>
    ) async where Sample: SpeziHealthKit._HKSampleWithSampleType {
        // Not implemented
    }
}
