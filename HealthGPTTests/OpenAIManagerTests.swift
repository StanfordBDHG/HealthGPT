//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import HealthGPT
import OpenAI
import XCTest


final class OpenAIManagerTests: XCTestCase {
    var openAIManager: OpenAIManager?

    override func setUp() {
        super.setUp()
        let apiToken = "test-token"
        let model = Model.gpt3_5Turbo
        openAIManager = OpenAIManager(apiToken: apiToken, openAIModel: model)
    }

    override func tearDown() {
        openAIManager = nil
        super.tearDown()
    }

    func testInitialization() {
        guard let openAIManager = openAIManager else {
            XCTFail("OpenAIManager initialization failed.")
            return
        }
        XCTAssertNotNil(
            openAIManager,
            "OpenAIManager initialization failed."
        )
        XCTAssertEqual(
            openAIManager.apiToken,
            "test-token",
            "API token is not set correctly."
        )
        XCTAssertEqual(
            openAIManager.openAIModel,
            Model.gpt3_5Turbo,
            "OpenAI model is not set correctly."
        )
    }

    func testUpdateAPIToken() {
        guard let openAIManager = openAIManager else {
             XCTFail("OpenAIManager is not initialized.")
             return
         }
        openAIManager.updateAPIToken("new-token")
        XCTAssertEqual(
            openAIManager.apiToken,
            "new-token",
            "API token was not updated correctly."
        )
    }

    func testUpdateModel() {
        guard let openAIManager = openAIManager else {
            XCTFail("OpenAIManager is not initialized.")
            return
        }
        openAIManager.updateModel(.gpt4)
        XCTAssertEqual(
            openAIManager.openAIModel,
            Model.gpt4,
            "OpenAI model was not updated correctly."
        )
    }

    func testNoAPITokenError() async {
        guard let openAIManager = openAIManager else {
            XCTFail("OpenAIManager is not initialized.")
            return
        }
        openAIManager.updateAPIToken("")
        do {
            _ = try await openAIManager.queryAPI(mainPrompt: "Test prompt", messages: [])
            XCTFail("No error was thrown when an empty API token was set.")
        } catch {
            XCTAssertEqual(error as? OpenAIAPIError, OpenAIAPIError.noAPIToken, "Unexpected error was thrown.")
        }
    }
}
