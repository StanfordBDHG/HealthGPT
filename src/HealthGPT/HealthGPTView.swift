//
//  HealthDataQuestionView.swift
//  TemplateApplication
//
//  Created by Varun Shenoy on 4/13/23.
//

import SwiftUI
import OpenAI
import HealthKit

struct Message: Identifiable {
    var id = UUID()
    var content: String
    var isBot: Bool
}

struct HealthGPTView: View {
    @State private var userMessage: String = ""
    @State private var messages: [Message] = []

    var body: some View {
        NavigationView {
            VStack {
                ChatView(messages: $messages)
                    .gesture(
                        TapGesture().onEnded {
                            UIApplication.shared.hideKeyboard()
                        }
                    )
                MessageInputView(userMessage: $userMessage, messages: $messages)
            }
            .navigationBarTitle("HealthGPT")
        }
        
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ChatView: View {
    @Binding var messages: [Message]

    var body: some View {
        ScrollView {
            ScrollViewReader { value in
                
                ForEach(messages.indices, id: \.self) { message in
                    MessageView(message: messages[message]).id(message)
                }
                .onChange(of: messages.count) { newValue in
                    withAnimation {
                        value.scrollTo(newValue - 1)
                    }
                }
                
            }
        }
    }
}

struct MessageView: View {
    var message: Message

    var body: some View {
        HStack {
            Spacer()
                .frame(width: message.isBot ? 10 : 30)
            Text(message.content)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .foregroundColor(Color.black)
                        .background(message.isBot ?
                                    Color(red: 1, green: 0.824, blue: 0.788) : Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(message.isBot ? Color(red: 0.965, green: 0.592, blue: 0.518) : Color(red: 0.906, green: 0.898, blue: 0.894), lineWidth: 1)
                        )
            Spacer()
                .frame(width: message.isBot ? 30 : 10)
        }
    }
}

