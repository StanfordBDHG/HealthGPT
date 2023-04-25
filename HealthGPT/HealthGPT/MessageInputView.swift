//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors
//

import CardinalKitFHIR
import CardinalKitSecureStorage
import OpenAI
import SwiftUI

struct MessageInputView: View {
    @Binding var userMessage: String
    @Binding var messages: [Message]
    @EnvironmentObject var secureStorage: SecureStorage<FHIR>
    @AppStorage(StorageKeys.openAIModel) var openAIModel = Model.gpt3_5Turbo

    @State private var isQuerying = false
    @State private var showingSheet = false

    @State private var showAlert = false
    @State private var alertText = ""

    var body: some View {
        // This code is to be refactored, will temporarily disable.
        // swiftlint:disable closure_body_length
        HStack {
            TextField(
                isQuerying ? "HealthGPT is thinking 🤔..." : "Type a message...",
                text: $userMessage,
                axis: .vertical
            )
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .lineLimit(1...5)
                .disabled(isQuerying == true)

            Button(action: {
                isQuerying = true
                let newMessage = Message(content: userMessage, isBot: false)
                messages.append(newMessage)
                let userMessageToQuery = userMessage
                userMessage = ""

                var apiKey = ""
                if let storedApiKey = try? secureStorage.retrieveCredentials("openai-api-key", server: "openai.com") {
                    apiKey = storedApiKey.password
                } else {
                    alertText = "Could not find a valid API key."
                    self.showAlert.toggle()
                    return
                }

                let openAI = OpenAI(apiToken: apiKey)

                _Concurrency.Task {
                    let healthDataFetcher = HealthDataFetcher()
                    var healthData: [HealthData] = []
                    let calendar = Calendar.current
                    let today = Date()

                    for day in 1...14 {
                        guard let endDate = calendar.date(byAdding: .day, value: -day, to: today) else { continue }
                        healthData.append(
                            HealthData(
                                date: DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .none)
                            )
                        )
                    }

                    healthData = healthData.reversed()

                    healthDataFetcher.requestAuthorization { success in
                        if success {
                            let group = DispatchGroup()

                            // Fetch step count and enter the group
                            group.enter()
                            healthDataFetcher.fetchLastTwoWeeksStepCount { stepCounts in
                                for day in 0...13 {
                                    healthData[day].steps = stepCounts[day]
                                }
                                print("Daily Step Count:", stepCounts)
                                group.leave()
                            }

                            // Fetch sleep minutes and enter the group
                            group.enter()
                            healthDataFetcher.fetchLastTwoWeeksSleep { sleepHours in
                                for day in 0...13 {
                                    healthData[day].sleepHours = sleepHours[day]
                                }
                                print("Daily Sleep in Hours:", sleepHours)
                                group.leave()
                            }

                            // Fetch sleep minutes and enter the group
                            group.enter()
                            healthDataFetcher.fetchLastTwoWeeksActiveEnergy { caloriesBurned in
                                print(caloriesBurned)
                                for day in 0...13 {
                                    healthData[day].activeEnergy = caloriesBurned[day]
                                }
                                print("Calories Burned", caloriesBurned)
                                group.leave()
                            }

                            group.enter()
                            healthDataFetcher.fetchLastTwoWeeksExerciseTime { exerciseTime in
                                for day in 0...13 {
                                    healthData[day].exerciseMinutes = exerciseTime[day]
                                }
                                print("Exercise Time", exerciseTime)
                                group.leave()
                            }

                            group.enter()
                            healthDataFetcher.fetchLastTwoWeeksBodyWeight { bodyMass in
                                print(bodyMass)
                                for day in 0...13 {
                                    healthData[day].bodyWeight = bodyMass[day]
                                }
                                print("Body Mass", bodyMass)
                                group.leave()
                            }

                            // Wait for both async calls to finish
                            group.notify(queue: .main) {
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
                                print(mainPrompt)

                                _Concurrency.Task {
                                    var currentChat: [Chat] = [.init(role: .system, content: mainPrompt)]
                                    for message in messages {
                                        currentChat.append(
                                            .init(
                                                role: message.isBot ? .assistant : .user,
                                                content: message.content
                                            )
                                        )
                                    }
                                    currentChat.append(.init(role: .user, content: userMessageToQuery))

                                    let query = ChatQuery(model: openAIModel, messages: currentChat)
                                    let botMessageContent = try await openAI.chats(query: query).choices[0].message.content

                                    messages.append(Message(content: botMessageContent, isBot: true))
                                    isQuerying = false
                                }
                            }
                        } else {
                            print("Authorization failed.")
                            isQuerying = false
                        }
                    }
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .padding(.horizontal, 10)
                    .foregroundColor(
                        userMessage.isEmpty ? Color(.systemGray6) : Color(red: 0.902, green: 0.404, blue: 0.404)
                    )
            }
            .disabled(userMessage.isEmpty)

            Button(action: {
                showingSheet.toggle()
            }) {
                Image(systemName: "gearshape.fill")
                    .padding(.horizontal, 10)
            }
            .sheet(isPresented: $showingSheet) {
                SettingsView(messages: $messages)
            }
        }
        .padding(10)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Alert"),
                message: Text(alertText),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
