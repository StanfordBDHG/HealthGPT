//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziLLMOpenAI


struct GetAvailableMetricsFunction: LLMFunction {
    static let name = "get_available_metrics"
    static let description = """
        List the health metrics that can be queried or compared with the other health tools.
        """

    func execute() async -> String? {
        HealthMetric.allCases
            .map { "\($0.rawValue): \($0.displayName)" }
            .joined(separator: "\n")
    }
}
