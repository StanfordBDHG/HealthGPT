//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
@testable import HealthGPT
import Testing


struct HealthMetricTests {
    @Test
    func allCasesExist() {
        let cases = HealthMetric.allCases
        #expect(cases.count == 6)
        #expect(cases.contains(.steps))
        #expect(cases.contains(.activeEnergy))
        #expect(cases.contains(.exerciseMinutes))
        #expect(cases.contains(.bodyWeight))
        #expect(cases.contains(.restingHeartRate))
        #expect(cases.contains(.sleep))
    }

    @Test
    func rawValueRoundTrip() {
        for metric in HealthMetric.allCases {
            #expect(HealthMetric(rawValue: metric.rawValue) == metric)
        }
    }

    @Test
    func sleepHasNilIdentifierUnitAndOptions() {
        let sleep = HealthMetric.sleep
        #expect(sleep.identifier == nil)
        #expect(sleep.unit == nil)
        #expect(sleep.options == nil)
    }

    @Test
    func quantityMetricsHaveIdentifierUnitAndOptions() {
        let quantityMetrics: [HealthMetric] = [.steps, .activeEnergy, .exerciseMinutes, .bodyWeight, .restingHeartRate]
        for metric in quantityMetrics {
            #expect(metric.identifier != nil, "Expected identifier for \(metric.rawValue)")
            #expect(metric.unit != nil, "Expected unit for \(metric.rawValue)")
            #expect(metric.options != nil, "Expected options for \(metric.rawValue)")
        }
    }

    @Test
    func identifierMappingsAreCorrect() {
        #expect(HealthMetric.steps.identifier == .stepCount)
        #expect(HealthMetric.activeEnergy.identifier == .activeEnergyBurned)
        #expect(HealthMetric.exerciseMinutes.identifier == .appleExerciseTime)
        #expect(HealthMetric.bodyWeight.identifier == .bodyMass)
        #expect(HealthMetric.restingHeartRate.identifier == .restingHeartRate)
    }

    @Test
    func cumulativeSumMetrics() {
        let cumulativeMetrics: [HealthMetric] = [.steps, .activeEnergy, .exerciseMinutes]
        for metric in cumulativeMetrics {
            #expect(metric.options == [.cumulativeSum], "Expected cumulativeSum for \(metric.rawValue)")
        }
    }

    @Test
    func discreteAverageMetrics() {
        let averageMetrics: [HealthMetric] = [.bodyWeight, .restingHeartRate]
        for metric in averageMetrics {
            #expect(metric.options == [.discreteAverage], "Expected discreteAverage for \(metric.rawValue)")
        }
    }

    @Test
    func displayNamesAreNonEmpty() {
        for metric in HealthMetric.allCases {
            #expect(!metric.displayName.isEmpty, "Expected non-empty displayName for \(metric.rawValue)")
        }
    }

    @Test
    func descriptionsAreNonEmpty() {
        for metric in HealthMetric.allCases {
            #expect(!metric.description.isEmpty, "Expected non-empty description for \(metric.rawValue)")
        }
    }
}
