//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Testing

struct HealthGPTViewUITests {
    let app: XCUIApplication

    init() async throws {
        app = XCUIApplication()
        app.launchArguments = ["--showOnboarding", "--resetSecureStorage", "--mockMode"]
        app.deleteAndLaunch(withSpringboardAppName: "HealthGPT")
    }
    
    @Test
    func chatView() throws {
        try app.conductOnboardingIfNeeded()
        try #require(app.buttons["Record Message"].waitForExistence(timeout: 2), "Record Message button not found")
        try app.textFields["Message Input Textfield"].enter(value: "New Message!")
        try #require(app.buttons["Send Message"].waitForExistence(timeout: 2), "Send Message button not found")
        app.buttons["Send Message"].tap()
        sleep(3)
        try #require(app.staticTexts["Mock Message from SpeziLLM!"].waitForExistence(timeout: 5), "Mock message not found")
    }
    
    @Test
    func settingsView() throws {
        try app.conductOnboardingIfNeeded()
        let settingsButton = app.buttons["settingsButton"]
        try #require(settingsButton.waitForExistence(timeout: 5), "Settings button not found")
        settingsButton.tap()
        
        try #require(app.staticTexts["Settings"].waitForExistence(timeout: 2), "Settings static text not found")
        
        #expect(app.buttons["Open AI API Key"].exists, "Open AI API Key button should exist")
        app.buttons["Open AI API Key"].tap()
        app.navigationBars.buttons["Settings"].tap()
        
        #expect(app.buttons["Open AI Model"].exists, "Open AI Model button should exist")
        app.buttons["Open AI Model"].tap()
        
        let picker = app.pickers["modelPicker"]
        let optionToSelect = picker.pickerWheels.element(boundBy: 0)
        optionToSelect.adjust(toPickerWheelValue: "GPT 4")
        
        app.buttons["Save OpenAI Model"].tap()
        
        #expect(app.staticTexts["Enable Text to Speech"].exists, "Enable Text to Speech text should exist")
        
        #expect(app.buttons["Done"].exists, "Done button should exist")
        app.buttons["Done"].tap()
        
        settingsButton.tap()
        #expect(app.buttons["Reset Chat"].exists, "Reset Chat button should exist")
        app.buttons["Reset Chat"].tap()
        
        try #require(app.staticTexts["HealthGPT"].waitForExistence(timeout: 2), "HealthGPT static text not found after resetting chat")
    }
    
    @Test
    func resetChat() throws {
        try app.conductOnboardingIfNeeded()
        let resetChatButton = app.buttons["resetChatButton"]
        try #require(resetChatButton.waitForExistence(timeout: 5), "Reset Chat button not found")
        resetChatButton.tap()
    }
}
