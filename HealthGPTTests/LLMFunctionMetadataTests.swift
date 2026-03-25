//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
@testable import HealthGPT
import Testing


struct LLMFunctionMetadataTests {
    @Test
    func getHealthMetricFunctionMetadata() {
        #expect(GetHealthMetricFunction.name == "get_health_metric")
        #expect(!GetHealthMetricFunction.description.isEmpty)
        #expect(GetHealthMetricFunction.description.contains("health metric"))
    }

    @Test
    func comparePeriodsMetadata() {
        #expect(ComparePeriodsFunction.name == "compare_periods")
        #expect(!ComparePeriodsFunction.description.isEmpty)
        #expect(ComparePeriodsFunction.description.contains("Compare"))
    }

    @Test
    func getHealthMetricMetricTypeCasesMatchHealthMetric() {
        let metricTypeCases = GetHealthMetricFunction.MetricType.allCases.map(\.rawValue).sorted()
        let healthMetricCases = HealthMetric.allCases.map(\.rawValue).sorted()
        #expect(metricTypeCases == healthMetricCases)
    }

    @Test
    func comparePeriodsMetricTypeCasesMatchHealthMetric() {
        let metricTypeCases = ComparePeriodsFunction.MetricType.allCases.map(\.rawValue).sorted()
        let healthMetricCases = HealthMetric.allCases.map(\.rawValue).sorted()
        #expect(metricTypeCases == healthMetricCases)
    }

    @Test
    func allFunctionNamesAreUnique() {
        let names = [
            GetHealthMetricFunction.name,
            GetAvailableMetricsFunction.name,
            ComparePeriodsFunction.name
        ]
        #expect(Set(names).count == names.count)
    }

    @Test
    func toolUsePromptReferencesAllFunctionNames() {
        let prompt = PromptGenerator.buildToolUsePrompt()
        #expect(prompt.contains(GetHealthMetricFunction.name))
        #expect(prompt.contains(GetAvailableMetricsFunction.name))
        #expect(prompt.contains(ComparePeriodsFunction.name))
    }
}
