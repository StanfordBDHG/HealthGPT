//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class HealthGPTViewUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding", "--resetKeychain"]
        app.deleteAndLaunch(withSpringboardAppName: "HealthGPT")
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
}
