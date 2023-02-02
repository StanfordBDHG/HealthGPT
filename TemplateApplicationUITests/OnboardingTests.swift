//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTHealthKit


class OnboardingTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "TemplateApplication")
    }
    
    
    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        
        try app.navigateOnboardingFlow(assertThatHealthKitConsentIsShown: true)
        
        let tabBar = app.tabBars["Tab Bar"]
        XCTAssertTrue(tabBar.buttons["Schedule"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(tabBar.buttons["Contacts"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(tabBar.buttons["Mock Upload"].waitForExistence(timeout: 0.5))
    }
}


extension XCUIApplication {
    func conductOnboardingIfNeeded() throws {
        if self.staticTexts["CardinalKit\nTemplate Application"].waitForExistence(timeout: 0.5) {
            try navigateOnboardingFlow(assertThatHealthKitConsentIsShown: false)
        }
    }
    
    func navigateOnboardingFlow(assertThatHealthKitConsentIsShown: Bool = true) throws {
        try navigateOnboardingFlowWelcome()
        try navigateOnboardingFlowInterestingModules()
        if staticTexts["Consent Example"].waitForExistence(timeout: 0.5) {
            try navigateOnboardingFlowConsent()
        }
        try navigateOnboardingFlowHealthKitAccess(assertThatHealthKitConsentIsShown: assertThatHealthKitConsentIsShown)
    }
    
    private func navigateOnboardingFlowWelcome() throws {
        XCTAssertTrue(staticTexts["CardinalKit\nTemplate Application"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["This application demonstrates several CardinalKit features & modules."]
                .waitForExistence(timeout: 0.5)
        )
        
        XCTAssertTrue(staticTexts["The CardinalKit Framework"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["The CardinalKit Framework builds the foundation of this template application."]
                .waitForExistence(timeout: 0.5)
        )
        
        XCTAssertTrue(staticTexts["Swift Package Manager"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["CardinalKit uses the Swift Package Manager to import it as a dependency."]
                .waitForExistence(timeout: 0.5)
        )
        
        XCTAssertTrue(staticTexts["CardinalKit Modules"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["CardinalKit offers several modules including HealthKit integration, questionnaires, and more ..."]
                .waitForExistence(timeout: 0.5)
        )
        
        XCTAssertTrue(buttons["Learn More"].waitForExistence(timeout: 0.5))
        buttons["Learn More"].tap()
    }
    
    private func navigateOnboardingFlowInterestingModules() throws {
        XCTAssertTrue(staticTexts["Interesting Modules"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["Here are a few CardinalKit modules that are interesting to know about ..."]
                .waitForExistence(timeout: 0.5)
        )
        
        XCTAssertTrue(staticTexts["Onboarding"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["The onboarding module allows you to build an onboarding flow like this one."]
                .waitForExistence(timeout: 0.5)
        )
        XCTAssertTrue(buttons["Next"].waitForExistence(timeout: 0.5))
        buttons["Next"].tap()
        
        XCTAssertTrue(staticTexts["FHIR"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["The FHIR module provides a CardinalKit standard that can be used as a communication standard between modules."]
                .waitForExistence(timeout: 0.5)
        )
        XCTAssertTrue(buttons["Next"].waitForExistence(timeout: 0.5))
        buttons["Next"].tap()
        
        XCTAssertTrue(staticTexts["Contact"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["The contact module allows you to display contact information in your application."]
                .waitForExistence(timeout: 0.5)
        )
        XCTAssertTrue(buttons["Next"].waitForExistence(timeout: 0.5))
        buttons["Next"].tap()
        
        XCTAssertTrue(staticTexts["HealthKit Data Source"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["The HealthKit data source module allows you to fetch data from HealthKit and e.g. transform it to FHIR resources."]
                .waitForExistence(timeout: 0.5)
        )
        
        XCTAssertTrue(buttons["Next"].waitForExistence(timeout: 0.5))
        buttons["Next"].tap()
    }
    
    private func navigateOnboardingFlowConsent() throws {
        XCTAssertTrue(staticTexts["Consent Example"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["CardinalKit can collect consent from a user. You can provide the consent document using a markdown file."]
                .waitForExistence(timeout: 0.5)
        )
        XCTAssertTrue(
            staticTexts["CardinalKit can render consent documents in the markdown format: This is a markdown example.\n"]
                .waitForExistence(timeout: 0.5)
        )
        
        XCTAssertTrue(staticTexts["Given Name"].waitForExistence(timeout: 0.5))
        staticTexts["Given Name"].tap()
        textFields["Enter your given name ..."].typeText("Leland")
        
        XCTAssertTrue(staticTexts["Family Name"].waitForExistence(timeout: 0.5))
        staticTexts["Family Name"].tap()
        textFields["Enter your family name ..."].typeText("Stanford")
        
        staticTexts["Given Name"].swipeUp()
        
        XCTAssertTrue(staticTexts["Leland Stanford"].waitForExistence(timeout: 0.5))
        staticTexts["Leland Stanford"].firstMatch.swipeUp()
        
        XCTAssertTrue(buttons["I Consent"].waitForExistence(timeout: 0.5))
        buttons["I Consent"].tap()
    }
    
    private func navigateOnboardingFlowHealthKitAccess(assertThatHealthKitConsentIsShown: Bool = true) throws {
        XCTAssertTrue(staticTexts["HealthKit Access"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(
            staticTexts["CardinalKit can access data from HealthKit using the HealthKitDataSource module."].waitForExistence(timeout: 0.5)
        )
        XCTAssertTrue(images["heart.text.square.fill"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(buttons["Grant Access"].waitForExistence(timeout: 0.5))
        
        buttons["Grant Access"].tap()
        
        if self.navigationBars["Health Access"].waitForExistence(timeout: 30) {
            self.tables.staticTexts["Turn On All"].tap()
            self.navigationBars["Health Access"].buttons["Allow"].tap()
        } else if assertThatHealthKitConsentIsShown {
            XCTFail("Did not display the HealthKit Consent Screen")
        }
    }
}
