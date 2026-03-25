//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziLLMOpenAI


struct GetAvailableMetricsFunction: LLMFunction {
    static let name: String = "get_available_metrics"
    static let description: String = "List all available health metrics that can be queried. Call this if unsure which metrics are available."

    func execute() async throws -> String? {
        let metrics = HealthMetric.allCases.map { "- \($0.rawValue): \($0.description)" }
        return "Available health metrics:\n" + metrics.joined(separator: "\n")
    }
}
