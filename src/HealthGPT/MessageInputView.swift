//
//  MessageInputView.swift
//  HealthGPT
//
//  Created by Varun Shenoy on 4/17/23.
//

import SwiftUI
import OpenAI

struct MessageInputView: View {
    @Binding var userMessage: String
    @Binding var messages: [Message]
    
    @State private var isQuerying = false
    @State private var showingSheet = false

    @State private var showAlert = false
    @State private var alertText = ""

    private var apiKey: String? {
        get {
            guard let filePath = Bundle.main.path(forResource: "OpenAI-Info", ofType: "plist") else {
                alertText = "Couldn't find file 'OpenAI-Info.plist'."
                self.showAlert.toggle()
                return nil
            }

            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "API_KEY") as? String else {
                alertText = "Couldn't find key 'API_KEY' in 'OpenAI-Info.plist'."
                self.showAlert.toggle()
                return nil
            }

            if (value.starts(with: "_")) {
                alertText = "Please register for an OpenAI account and get an API Key. "
                self.showAlert.toggle()
                return nil
            }
            return value
        }
    }

    var body: some View {
        HStack {
            TextField(isQuerying ? "HealthGPT is thinking 🤔..." : "Type a message...", text: $userMessage)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .disabled(isQuerying == true)

            Button(action: {
                guard let apiKey else {
                    return
                }

                isQuerying = true
                let newMessage = Message(content: userMessage, isBot: false)
                messages.append(newMessage)
                let userMessageToQuery = userMessage
                userMessage = ""

                let openAI = OpenAI(apiToken: apiKey)
                
                Task {
                    let healthDataFetcher = HealthDataFetcher()
                    var healthData: [HealthData] = []
                    let calendar = Calendar.current
                    let today = Date()
                    
                    for day in 1...14 {
                        guard let endDate = calendar.date(byAdding: .day, value: -day, to: today) else { continue }
                        healthData.append(HealthData(date: DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .none)))
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
                                
                                var mainPrompt = "You are HealthGPT, an enthusaiastic, expert caretaker with a deep understanding in personal health. Given the context, provide a short response that could answer the user's question. Do NOT provide statistics. If numbers seem low, provide advice on how they can improve.\n\nSome health metrics over the past two weeks (14 days) to incorporate is given below. If a value is zero, the user has not inputted anything for that day. Today is \(DateFormatter.localizedString(from: today, dateStyle: .full, timeStyle: .none)). Note that you do not have data about the current day.\n\n"
                                
                                for day in 0...13 {
                                    let dayData = healthData[day]
                                    mainPrompt += "\(dayData.date): \(Int(dayData.steps!)) steps, \(Int(dayData.sleepHours!)) hours of sleep, \(Int(dayData.activeEnergy!) ) calories burned, \(Int(dayData.exerciseMinutes!) ) minutes of exercise, \(dayData.bodyWeight ?? 0.0) lbs of body weight\n"
                                }
                                print(mainPrompt)
                                
                                
                                Task {
                                    var currentChat: [Chat] = [.init(role: .system, content: mainPrompt)]
                                    for message in messages {
                                        currentChat.append(.init(role: message.isBot ? .assistant : .user, content: message.content))
                                    }
                                    currentChat.append(.init(role: .user, content: userMessageToQuery))
                                    
                                    // if you have access to GPT-4, you can change `model` to `.gpt4` below
                                    let query = ChatQuery(model: .gpt3_5Turbo, messages: currentChat)
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
                    .foregroundColor(userMessage.isEmpty ? Color(.systemGray6) : Color(red: 0.902, green: 0.404, blue: 0.404))
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


struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var messages: [Message]

    var body: some View {
        Button("Clear Current Thread") {
            messages = []
            dismiss()
        }
        .padding()
        .background(.white)
        .cornerRadius(20)
        .foregroundColor(.red)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.red, lineWidth: 1)
        )
        
        Text("HealthGPT is powered by the OpenAI API. Data submitted here is not used for training OpenAI's models according to their terms and conditions.\n\nCurrently, HealthGPT is accessing your step count, sleep analysis, exercise minutes, active calories burned, body weight, and heart rate, all from data stored in the Health app.\n\nRemember to log your data and wear your Apple Watch throughout the day for the most accurate results.")
            .foregroundColor(.gray)
            .padding(20)
            .font(.system(size: 15))
        
    }
}
