import Testing
import XCTestExtensions
import XCTHealthKit
import XCTest // Retain XCTest if extensions from XCTest (e.g. XCUIApplication) are needed

struct OnboardingUITests {
    let app: XCUIApplication

    // Async initializer performing setup.
    init() async throws {
        app = XCUIApplication()
        app.launchArguments = ["--showOnboarding", "--resetSecureStorage"]
        app.deleteAndLaunch(withSpringboardAppName: "HealthGPT")
    }
    
    @Test
    func onboardingFlow() throws {
        try app.navigateOnboardingFlow(assertThatHealthKitConsentIsShown: true)
    }
}

extension XCUIApplication {
    func conductOnboardingIfNeeded() throws {
        if self.staticTexts["HealthGPT"].waitForExistence(timeout: 10) {
            try self.navigateOnboardingFlow(assertThatHealthKitConsentIsShown: false)
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
        try #require(staticTexts["HealthGPT"].waitForExistence(timeout: 10), "HealthGPT static text not found in Welcome step")
        try #require(buttons["Continue"].waitForExistence(timeout: 10), "Continue button not found in Welcome step")
        buttons["Continue"].tap()
    }

    private func navigateOnboardingFlowDisclaimer() throws {
        try #require(staticTexts["Disclaimer"].waitForExistence(timeout: 10), "Disclaimer static text not found")
        for _ in 1..<4 {
            try #require(buttons["Next"].waitForExistence(timeout: 10), "Next button not found in Disclaimer step")
            buttons["Next"].tap()
        }
        try #require(buttons["I Agree"].waitForExistence(timeout: 10), "I Agree button not found in Disclaimer step")
        buttons["I Agree"].tap()
    }
    
    private func navigateOnboardingFlowLLMSourceSelection() throws {
        try #require(staticTexts["LLM Source Selection"].waitForExistence(timeout: 5), "LLM Source Selection static text not found")
        
        let picker = pickers["llmSourcePicker"]
        let optionToSelect = picker.pickerWheels.element(boundBy: 0)
        optionToSelect.adjust(toPickerWheelValue: "On-device LLM")
        
        try #require(buttons["Save Choice"].waitForExistence(timeout: 5), "Save Choice button not found during LLM Source Selection")
        buttons["Save Choice"].tap()
        
        try #require(staticTexts["LLM Download"].waitForExistence(timeout: 5), "LLM Download static text not found")
        try #require(buttons["Back"].waitForExistence(timeout: 2), "Back button not found during LLM Source Selection")
        buttons["Back"].tap()
        
        optionToSelect.adjust(toPickerWheelValue: "Open AI LLM")
        try #require(buttons["Save Choice"].waitForExistence(timeout: 5), "Save Choice button not found after switching to Open AI LLM")
        buttons["Save Choice"].tap()
    }

    private func navigateOnboardingFlowApiKey() throws {
        try textFields["OpenAI API Key"].enter(value: "sk-123456789")
        try #require(buttons["Next"].waitForExistence(timeout: 2), "Next button not found in API Key step")
        buttons["Next"].tap()
    }

    private func navigateOnboardingFlowModelSelection() throws {
        try #require(staticTexts["Select an OpenAI Model"].waitForExistence(timeout: 10), "Select an OpenAI Model static text not found")
        try #require(buttons["Save OpenAI Model"].waitForExistence(timeout: 10), "Save OpenAI Model button not found")
        let picker = pickers["modelPicker"]
        let optionToSelect = picker.pickerWheels.element(boundBy: 0)
        optionToSelect.adjust(toPickerWheelValue: "GPT 4")
        buttons["Save OpenAI Model"].tap()
    }

    private func navigateOnboardingFlowHealthKitAccess(assertThatHealthKitConsentIsShown: Bool = true) throws {
        try #require(staticTexts["HealthKit Access"].waitForExistence(timeout: 10), "HealthKit Access static text not found")
        try #require(buttons["Grant Access"].waitForExistence(timeout: 10), "Grant Access button not found")
        buttons["Grant Access"].tap()
        try handleHealthKitAuthorization()
    }
}