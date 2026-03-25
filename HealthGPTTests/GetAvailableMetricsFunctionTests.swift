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


struct GetAvailableMetricsFunctionTests {
    @Test
    func executeReturnsAllMetrics() async throws {
        let function = GetAvailableMetricsFunction()
        let result = try await function.execute()

        #expect(result != nil)

        let output = try #require(result)
        #expect(output.contains("Available health metrics:"))

        for metric in HealthMetric.allCases {
            #expect(output.contains(metric.rawValue), "Expected output to contain \(metric.rawValue)")
            #expect(output.contains(metric.description), "Expected output to contain description for \(metric.rawValue)")
        }
    }

    @Test
    func functionMetadata() {
        #expect(GetAvailableMetricsFunction.name == "get_available_metrics")
        #expect(!GetAvailableMetricsFunction.description.isEmpty)
    }
}
