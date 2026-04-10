//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
@testable import HealthGPT
import HealthKit
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
    func sleepHasNilSampleTypeAndAggregation() {
        let sleep = HealthMetric.sleep
        #expect(sleep.sampleType == nil)
        #expect(sleep.aggregation == nil)
    }

    @Test
    func quantityMetricsHaveSampleTypeAndAggregation() {
        let quantityMetrics: [HealthMetric] = [.steps, .activeEnergy, .exerciseMinutes, .bodyWeight, .restingHeartRate]
        for metric in quantityMetrics {
            #expect(metric.sampleType != nil, "Expected sampleType for \(metric.rawValue)")
            #expect(metric.aggregation != nil, "Expected aggregation for \(metric.rawValue)")
        }
    }

    @Test
    func sumAggregationMetrics() {
        let sumMetrics: [HealthMetric] = [.steps, .activeEnergy, .exerciseMinutes]
        for metric in sumMetrics {
            #expect(metric.aggregation == .sum, "Expected .sum aggregation for \(metric.rawValue)")
        }
    }

    @Test
    func averageAggregationMetrics() {
        let averageMetrics: [HealthMetric] = [.bodyWeight, .restingHeartRate]
        for metric in averageMetrics {
            #expect(metric.aggregation == .average, "Expected .average aggregation for \(metric.rawValue)")
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
