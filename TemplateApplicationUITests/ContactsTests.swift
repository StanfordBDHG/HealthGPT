//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


class ContactsTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.launch()
    }
    
    
    func testContacts() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Contacts"].waitForExistence(timeout: 0.5))
        app.tabBars["Tab Bar"].buttons["Contacts"].tap()
        
        XCTAssertTrue(app.staticTexts["Leland Stanford"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["University Founder"].waitForExistence(timeout: 0.5))
        XCTAssertTrue(app.staticTexts["Stanford University"].waitForExistence(timeout: 0.5))
        
        XCTAssertTrue(app.buttons["Call"].waitForExistence(timeout: 0.5))
        app.buttons["Call"].tap()
        app.alerts["Call"].scrollViews.otherElements.buttons["Ok"].tap()
        
        XCTAssertTrue(app.buttons["Text"].waitForExistence(timeout: 0.5))
        app.buttons["Text"].tap()
        app.alerts["Text"].scrollViews.otherElements.buttons["Ok"].tap()
        
        XCTAssertTrue(app.buttons["Email"].waitForExistence(timeout: 0.5))
        app.buttons["Email"].tap()
        app.alerts["Email"].scrollViews.otherElements.buttons["Ok"].tap()
        
        XCTAssertTrue(app.buttons["Website"].waitForExistence(timeout: 0.5))
        app.buttons["Website"].tap()
        
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        XCTAssert(safari.wait(for: .runningForeground, timeout: 5.0))
        app.activate()
        
        XCTAssertTrue(app.buttons["Address, 450 Serra Mall\nStanford CA 94305\nUSA"].waitForExistence(timeout: 0.5))
        app.buttons["Address, 450 Serra Mall\nStanford CA 94305\nUSA"].tap()
        
        let maps = XCUIApplication(bundleIdentifier: "com.apple.Maps")
        XCTAssert(maps.wait(for: .runningForeground, timeout: 5.0))
    }
}
