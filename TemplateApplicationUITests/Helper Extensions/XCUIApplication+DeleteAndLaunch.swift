//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    func deleteAndLaunch(withSpringboardAppName appName: String) {
        self.terminate()
        
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        springboard.activate()
        
        if springboard.icons[appName].waitForExistence(timeout: 10.0) {
            if !springboard.icons[appName].isHittable {
                springboard.swipeLeft()
            }
            
            XCTAssertTrue(springboard.icons[appName].isHittable)
            springboard.icons[appName].press(forDuration: 1.5)
            
            XCTAssertTrue(springboard.collectionViews.buttons["Remove App"].waitForExistence(timeout: 0.5))
            springboard.collectionViews.buttons["Remove App"].tap()
            XCTAssertTrue(springboard.alerts["Remove “\(appName)”?"].scrollViews.otherElements.buttons["Delete App"].waitForExistence(timeout: 0.5))
            springboard.alerts["Remove “\(appName)”?"].scrollViews.otherElements.buttons["Delete App"].tap()
            XCTAssertTrue(springboard.alerts["Delete “\(appName)”?"].scrollViews.otherElements.buttons["Delete"].waitForExistence(timeout: 0.5))
            springboard.alerts["Delete “\(appName)”?"].scrollViews.otherElements.buttons["Delete"].tap()
        }
        
        self.launch()
    }
}
