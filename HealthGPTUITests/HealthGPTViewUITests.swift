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

    func testTextToSpeechToggle() throws {
        let app = XCUIApplication()
        try app.conductOnboardingIfNeeded()

        let ttsButton = app.buttons["textToSpeechButton"]
        XCTAssertTrue(ttsButton.waitForExistence(timeout: 5))

        XCTAssertEqual(ttsButton.label, "Text to speech is disabled, press to enable text to speech.")
        ttsButton.tap()
        XCTAssertEqual(ttsButton.label, "Text to speech is enabled, press to disable text to speech.")
    }

    func testSettingsView() throws {
        let app = XCUIApplication()
        try app.conductOnboardingIfNeeded()

        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let clearThreadButton = app.buttons["clearThreadButton"]
        XCTAssertTrue(clearThreadButton.waitForExistence(timeout: 5))
        clearThreadButton.tap()
    }
}
