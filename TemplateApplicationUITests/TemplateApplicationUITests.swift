//
// This source file is part of the StanfordBDHG Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest


class TemplateApplicationUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }
    
    func testGreeting() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
