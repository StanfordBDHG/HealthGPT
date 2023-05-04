//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import Foundation
import OpenAI


@MainActor
class MessageHandler: ObservableObject {
    @Published private(set) var messages: [Message]
    @Published private(set) var isQuerying: Bool = false
    private let openAIAPIHandler: OpenAIAPIHandler
    private let healthDataFetcher = HealthDataFetcher()

    init(apiToken: String = "", openAIModel: Model = .gpt3_5Turbo) {
        self.messages = []
        self.openAIAPIHandler = OpenAIAPIHandler(apiToken: apiToken, openAIModel: openAIModel)
    }

    func updateAPIToken(_ newToken: String) {
        self.openAIAPIHandler.updateAPIToken(newToken)
    }

    func processUserMessage(_ userMessage: String) async {
        let newMessage = Message(content: userMessage, isBot: false)

        self.messages.append(newMessage)

        do {
            let healthData = try await healthDataFetcher.fetchAndProcessHealthData()
            let mainPrompt = self.buildMainPrompt(with: healthData)

            Task {
                isQuerying = true
                do {
                    let botMessageContent = try await self.openAIAPIHandler.queryAPI(
                        mainPrompt: mainPrompt,
                        messages: self.messages
                    )
                    let botMessage = Message(content: botMessageContent, isBot: true)
                    self.messages.append(botMessage)
                    isQuerying = false
                } catch {
                    print("Error querying OpenAI API: \(error)")
                    isQuerying = false
                }
            }
        } catch {
            print("Error fetching and processing health data: \(error)")
        }
    }

    func clearMessages() {
        messages = []
    }

    private func buildMainPrompt(with healthData: [HealthData]) -> String {
        let today = Date()
        var mainPrompt = "You are HealthGPT, an enthusiastic, expert caretaker with a deep understanding in personal health. Given the context, provide a short response that could answer the user's question. Do NOT provide statistics. If numbers seem low, provide advice on how they can improve.\n\nSome health metrics over the past two weeks (14 days) to incorporate is given below. If a value is zero, the user has not inputted anything for that day. Today is \(DateFormatter.localizedString(from: today, dateStyle: .full, timeStyle: .none)). Note that you do not have data about the current day.\n\n"

        for day in 0...13 {
            let dayData = healthData[day]
            var mainText = ""

            if let steps = dayData.steps {
                mainText += "\(Int(steps)) steps,"
            }
            if let sleepHours = dayData.sleepHours {
                mainText += " \(Int(sleepHours)) hours of sleep,"
            }
            if let activeEnergy = dayData.activeEnergy {
                mainText += " \(Int(activeEnergy)) calories burned,"
            }
            if let exerciseMinutes = dayData.exerciseMinutes {
                mainText += " \(Int(exerciseMinutes)) minutes of exercise,"
            }
            if let bodyWeight = dayData.bodyWeight {
                mainText += " \(bodyWeight) lbs of body weight,"
            }

            mainPrompt += "\(dayData.date): \(mainText.dropLast()) \n"
        }

        return mainPrompt
    }
}

