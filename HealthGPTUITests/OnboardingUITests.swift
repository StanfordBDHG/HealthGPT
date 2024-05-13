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


final class OnboardingUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding", "--resetSecureStorage"]
        app.deleteAndLaunch(withSpringboardAppName: "HealthGPT")
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testOnboardingFlow() throws {
        let app = XCUIApplication()

        try app.navigateOnboardingFlow(assertThatHealthKitConsentIsShown: true)
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
        try navigateOnboardingFlowLLMSourceSelection()
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
    
    private func navigateOnboardingFlowLLMSourceSelection() throws {
        XCTAssertTrue(staticTexts["LLM Source Selection"].waitForExistence(timeout: 5))
        
        let picker = pickers["llmSourcePicker"]
        let optionToSelect = picker.pickerWheels.element(boundBy: 0)
        optionToSelect.adjust(toPickerWheelValue: "On-device LLM")
        
        XCTAssertTrue(buttons["Save Choice"].waitForExistence(timeout: 5))
        buttons["Save Choice"].tap()
        
        XCTAssertTrue(staticTexts["LLM Download"].waitForExistence(timeout: 5))
        XCTAssertTrue(buttons["Back"].waitForExistence(timeout: 2))
        buttons["Back"].tap()
        
        optionToSelect.adjust(toPickerWheelValue: "Open AI LLM")
        XCTAssertTrue(buttons["Save Choice"].waitForExistence(timeout: 5))
        buttons["Save Choice"].tap()
    }

    private func navigateOnboardingFlowApiKey() throws {
        try textFields["OpenAI API Key"].enter(value: "sk-123456789")
        
        XCTAssertTrue(buttons["Next"].waitForExistence(timeout: 2))
        buttons["Next"].tap()
    }

    private func navigateOnboardingFlowModelSelection() throws {
        XCTAssertTrue(staticTexts["Select an OpenAI Model"].waitForExistence(timeout: 10))
        XCTAssertTrue(buttons["Save OpenAI Model"].waitForExistence(timeout: 10))

        let picker = pickers["modelPicker"]
        let optionToSelect = picker.pickerWheels.element(boundBy: 0)
        optionToSelect.adjust(toPickerWheelValue: "GPT 4")

        buttons["Save OpenAI Model"].tap()
    }

    private func navigateOnboardingFlowHealthKitAccess(assertThatHealthKitConsentIsShown: Bool = true) throws {
        XCTAssertTrue(staticTexts["HealthKit Access"].waitForExistence(timeout: 10))

        XCTAssertTrue(buttons["Grant Access"].waitForExistence(timeout: 10))
        buttons["Grant Access"].tap()

        try handleHealthKitAuthorization()
    }
}
