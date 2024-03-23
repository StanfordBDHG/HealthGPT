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
        app.launchArguments = ["--showOnboarding", "--resetKeychain", "--mockMode"]
        app.deleteAndLaunch(withSpringboardAppName: "HealthGPT")
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func testChatView() throws {
        let app = XCUIApplication()
        try app.conductOnboardingIfNeeded()
        
        XCTAssert(app.buttons["Record Message"].waitForExistence(timeout: 2))
        
        try app.textViews["Message Input Textfield"].enter(value: "New Message!", dismissKeyboard: false)
        
        XCTAssert(app.buttons["Send Message"].waitForExistence(timeout: 2))
        app.buttons["Send Message"].tap()
        
        sleep(3)
        
        XCTAssert(app.staticTexts["Mock Message from SpeziLLM!"].waitForExistence(timeout: 5))
    }
    
    func testSettingsView() throws {
        let app = XCUIApplication()
        try app.conductOnboardingIfNeeded()

        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()
        
        XCTAssert(app.staticTexts["Settings"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Done"].waitForExistence(timeout: 2))
        app.buttons["Done"].tap()
    }
}
