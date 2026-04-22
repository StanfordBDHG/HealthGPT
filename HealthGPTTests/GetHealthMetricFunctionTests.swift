//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import HealthGPT
import Testing

@Suite("Get Health Metric Function Tests")
struct GetHealthMetricFunctionTests {
    @Test(arguments: [1, 30, 90])
    func resolveDaysAcceptsValuesInSupportedRange(days: Int) throws {
        let result = GetHealthMetricFunction.resolveDays(days)

        #expect(result.days == days)
        #expect(result.error == nil)
    }

    @Test
    func executeRequiresDaysParameter() async throws {
        let function = GetHealthMetricFunction(healthDataFetcher: HealthDataFetcher())

        let result = try await function.execute()

        #expect(result?.contains("`days` is required") == true)
    }

    @Test(arguments: [0, 91])
    func resolveDaysRejectsValuesOutsideSupportedRange(days: Int) {
        let result = GetHealthMetricFunction.resolveDays(days)

        #expect(result.days == nil)
        #expect(result.error?.contains("`days` must be between 1 and 90") == true)
        #expect(result.error?.contains("received \(days)") == true)
    }
}
