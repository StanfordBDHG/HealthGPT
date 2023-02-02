//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTHealthKit


class HealthKitUploadTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--showOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "TemplateApplication")
    }
    
    
    func testHealthKitMockUpload() throws {
        let app = XCUIApplication()
        
        try app.conductOnboardingIfNeeded()
        
        try navigateToMockUpload()
        try assertObservationCellPresent(false)
        
        app.terminate()
        
        try exitAppAndOpenHealth(.steps)
        
        app.activate()
        
        try navigateToMockUpload()
        try assertObservationCellPresent(true, pressIfPresent: true)
        try assertObservationCellPresent(true, pressIfPresent: false)
    }
    
    
    private func navigateToMockUpload() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Mock Upload"].waitForExistence(timeout: 0.5))
        app.tabBars["Tab Bar"].buttons["Mock Upload"].tap()
    }
    
    private func assertObservationCellPresent(_ shouldBePresent: Bool, pressIfPresent: Bool = true) throws {
        let app = XCUIApplication()
        
        let observationText = "/Observation/"
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", observationText)
        
        if shouldBePresent {
            XCTAssertTrue(app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: 0.5))
            if pressIfPresent {
                app.staticTexts.containing(predicate).firstMatch.tap()
            }
        } else {
            XCTAssertFalse(app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: 0.5))
        }
    }
}
