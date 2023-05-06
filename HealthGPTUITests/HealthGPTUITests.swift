//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions
import XCTHealthKit


final class HealthGPTUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        try disablePasswordAutofill()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding", "--resetKeychain"]
        app.deleteAndLaunch(withSpringboardAppName: "HealthGPT")
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testOnboardingFlow() throws {
        let app = XCUIApplication()

        try app.navigateOnboardingFlow(assertThatHealthKitConsentIsShown: true)
        XCTAssertTrue(app.staticTexts["HealthGPT"].waitForExistence(timeout: 10))
    }
}

extension XCUIApplication {
    func conductOnboardingIfNeeded() throws {
        if self.staticTexts["HealthGPT"].waitForExistence(timeout: 10) {
            try navigateOnboardingFlow(assertThatHealthKitConsentIsShown: false)
        }
    }

    func navigateOnboardingFlow(assertThatHealthKitConsentIsShown: Bool = true) throws {
        try navigateOnboardingFlowWelcome()
        try navigateOnboardingFlowDisclaimer()
        try navigateOnboardingFlowApiKey()
        try navigateOnboardingFlowModelSelection()
        try navigateOnboardingFlowHealthKitAccess(assertThatHealthKitConsentIsShown: assertThatHealthKitConsentIsShown)
    }

    private func navigateOnboardingFlowWelcome() throws {
        XCTAssertTrue(staticTexts["HealthGPT"].waitForExistence(timeout: 10))

        XCTAssertTrue(buttons["Continue"].waitForExistence(timeout: 10))
        buttons["Continue"].tap()
    }

    private func navigateOnboardingFlowDisclaimer() throws {
        XCTAssertTrue(staticTexts["Disclaimer"].waitForExistence(timeout: 10))

        for _ in 1..<4 {
            XCTAssertTrue(buttons["Next"].waitForExistence(timeout: 10))
            buttons["Next"].tap()
        }

        XCTAssertTrue(buttons["I Agree"].waitForExistence(timeout: 10))
        buttons["I Agree"].tap()
    }

    private func navigateOnboardingFlowApiKey() throws {
        XCTAssertTrue(staticTexts["OpenAI API Key"].waitForExistence(timeout: 10))
        XCTAssertTrue(buttons["Save API Key"].waitForExistence(timeout: 10))
        XCTAssertFalse(buttons["Save API Key"].isEnabled, "The button should be disabled as no text has been entered.")

        try textFields["Enter API Key"].enter(value: "C3JF8sDa4XwirsvG1Nfi3ZgtB3bkFIDM9duFfItNtAnD3k4XwiM2")

        XCTAssertTrue(buttons["Save API Key"].isEnabled, "The button should be enabled if text has been entered.")
        buttons["Save API Key"].tap()
    }

    private func navigateOnboardingFlowModelSelection() throws {
        XCTAssertTrue(staticTexts["Select an OpenAI Model"].waitForExistence(timeout: 10))
        XCTAssertTrue(buttons["Save"].waitForExistence(timeout: 10))

        let picker = pickers["modelPicker"]
        let optionToSelect = picker.pickerWheels.element(boundBy: 0)
        optionToSelect.adjust(toPickerWheelValue: "GPT 4")

        buttons["Save"].tap()
    }

    private func navigateOnboardingFlowHealthKitAccess(assertThatHealthKitConsentIsShown: Bool = true) throws {
        XCTAssertTrue(staticTexts["HealthKit Access"].waitForExistence(timeout: 10))

        XCTAssertTrue(buttons["Grant Access"].waitForExistence(timeout: 10))
        buttons["Grant Access"].tap()

        try handleHealthKitAuthorization()
    }
}
