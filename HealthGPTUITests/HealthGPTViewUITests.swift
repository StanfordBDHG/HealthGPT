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
        app.launchArguments = ["--showOnboarding", "--resetKeychainStorage", "--mockMode"]
        app.deleteAndLaunch(withSpringboardAppName: "HealthGPT")
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func testChatView() throws {
        let app = XCUIApplication()
        try app.conductOnboardingIfNeeded()
        
        XCTAssert(app.buttons["Record Message"].waitForExistence(timeout: 2))
        
        try app.textFields["Message Input Textfield"].enter(value: "New Message!")
        
        XCTAssert(app.buttons["Send Message"].waitForExistence(timeout: 2))
        app.buttons["Send Message"].tap()
        
        sleep(3)
        
        XCTAssert(app.staticTexts["Mock Message from SpeziLLM!"].waitForExistence(timeout: 5))
    }
    
    func testSettingsView() throws {
        let app = XCUIApplication()
        try app.conductOnboardingIfNeeded()

        let settingsButton = app.buttons["settingsButton"]
        XCTAssert(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()
        
        XCTAssert(app.buttons["changeModelButton"].firstMatch.waitForExistence(timeout: 1))
        app.buttons["changeModelButton"].firstMatch.tap()
        XCTAssert(app.buttons["Save Choice"].firstMatch.waitForExistence(timeout: 1))
        app.buttons["Save Choice"].firstMatch.tap()
        XCTAssert(app.textFields["sk-123456789"].waitForExistence(timeout: 1))
        app.buttons["Next"].firstMatch.tap()
        XCTAssert(app.pickerWheels.firstMatch.waitForExistence(timeout: 1))
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: "gpt-4o")
        app.buttons["Save OpenAI Model"].firstMatch.tap()
        
        XCTAssert(app.staticTexts["HealthGPT"].waitForExistence(timeout: 2))
        settingsButton.tap()
        
        XCTAssert(app.switches["Enable Text to Speech"].waitForExistence(timeout: 1))
        app.buttons["resetButton"].firstMatch.tap()
        
        XCTAssert(app.staticTexts["HealthGPT"].waitForExistence(timeout: 2))
        
    }
    
    func testResetChat() throws {
        let app = XCUIApplication()
        try app.conductOnboardingIfNeeded()
        
        let resetChatButton = app.buttons["resetChatButton"]
        XCTAssertTrue(resetChatButton.waitForExistence(timeout: 5))
        resetChatButton.tap()
    }
}
