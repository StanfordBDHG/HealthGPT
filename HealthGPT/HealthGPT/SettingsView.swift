//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog
import SpeziChat
import SpeziLLMOpenAI
import SwiftUI
import SafariServices

let appointmentReminderFHIRTestData = readJSONFile(fileName: "AppointmentReminderFHIRBundle")
let careAnomalyFHIRTestData = readJSONFile(fileName: "CareAnomalyFHIRBundle")

struct SettingsView: View {
    private enum SettingsDestinations {
        case openAIKey
        case openAIModelSelection
        case testDataViewer
    }
    
    @State private var path = NavigationPath()
    @State private var testDataInputText: String = ""
    @State private var isSafariViewPresented: Bool = false
    @State private var isNavigatingToTestDataViewer: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(HealthDataInterpreter.self) private var healthDataInterpreter
    @AppStorage(StorageKeys.enableTextToSpeech) private var enableTextToSpeech = StorageKeys.Defaults.enableTextToSpeech
    @AppStorage(StorageKeys.llmSource) private var llmSource = StorageKeys.Defaults.llmSource
    @AppStorage(StorageKeys.openAIModel) private var openAIModel = LLMOpenAIModelType.gpt4
    let logger = Logger(subsystem: "HealthGPT", category: "Settings")
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !FeatureFlags.localLLM && !(llmSource == .local) {
                    openAISettings
                }

                chatSettings
                speechSettings
                testData
                disclaimer
            }
            .navigationTitle("SETTINGS_TITLE")
            .navigationDestination(for: SettingsDestinations.self) { destination in
                navigate(to: destination)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("SETTINGS_DONE") {
                        dismiss()
                    }
                }
            }
                .accessibilityIdentifier("settingsList")
        }
    }
    
    private var openAISettings: some View {
        Section("SETTINGS_OPENAI") {
            NavigationLink(value: SettingsDestinations.openAIKey) {
                Text("SETTINGS_OPENAI_KEY")
            }
                .accessibilityIdentifier("openAIKey")
            NavigationLink(value: SettingsDestinations.openAIModelSelection) {
                Text("SETTINGS_OPENAI_MODEL")
            }
                .accessibilityIdentifier("openAIModel")
        }
    }
    
    private var chatSettings: some View {
        Section("SETTINGS_CHAT") {
            Button("SETTINGS_CHAT_RESET") {
                Task {
                    await healthDataInterpreter.resetChat()
                    dismiss()
                }
            }
                .buttonStyle(PlainButtonStyle())
                .accessibilityIdentifier("resetButton")
        }
    }
    
    private var speechSettings: some View {
        Section("SETTINGS_SPEECH") {
            Toggle(isOn: $enableTextToSpeech) {
                Text("SETTINGS_SPEECH_TEXT_TO_SPEECH")
            }
        }
    }
    
    private var testData: some View {
        Section("SETTINGS_TESTDATA") {
            NavigationLink(destination: navigate(to: .testDataViewer)
                .onAppear {
                    testDataInputText = appointmentReminderFHIRTestData ?? ""
                }) {
                Text("SETTINGS_TESTDATA_APPOINTMENT")
            }
            .accessibilityIdentifier("testdataButton")
            
            NavigationLink(destination: navigate(to: .testDataViewer)
                .onAppear {
                    testDataInputText = careAnomalyFHIRTestData ?? ""
                }) {
                Text("SETTINGS_TESTDATA_ANOMALY")
            }
            .accessibilityIdentifier("testdataButton")
            
            NavigationLink(destination: navigate(to: .testDataViewer)
                .onAppear {
                    testDataInputText = ""
                }) {
                Text("SETTINGS_TESTDATA_CUSTOM")
            }
            .accessibilityIdentifier("testdataButton")
            
            Button(action: {
                isSafariViewPresented = true
            }) {
                Text("SETTINGS_TESTDATA_CUSTOM_WEB")
            }
            .accessibilityIdentifier("testdataButton")
            .sheet(isPresented: $isSafariViewPresented) {
                if let url = URL(string: "https://smemas-data-generator.streamlit.app/") {
                    SafariView(url: url) { copiedText in
                        testDataInputText = copiedText
                        isNavigatingToTestDataViewer = true
                    }
                }
            }
            .background(
                NavigationLink(destination: navigate(to: .testDataViewer), isActive: $isNavigatingToTestDataViewer) {
                    EmptyView()
                }
            )
        }
    }
    
    private var disclaimer: some View {
        Section("SETTINGS_DISCLAIMER_TITLE") {
            Text("SETTINGS_DISCLAIMER_TEXT")
        }
    }
    
    private func navigate(to destination: SettingsDestinations) -> some View {
        Group {
            switch destination {
            case .testDataViewer:
                VStack {
                    TextEditor(text: $testDataInputText)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    HStack {
                        Button(action: {
                            testDataInputText = ""
                        }) {
                            Text("Clear")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }

                        Spacer()

                        Button(action: {
                            Task {
                                await healthDataInterpreter.generateTestData(testdata: testDataInputText)
                                dismiss()
                            }
                        }) {
                            Text("SETTINGS_POPULATE_TESTDATA")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .padding()
            case .openAIKey:
                LLMOpenAIAPITokenOnboardingStep(actionText: "OPEN_AI_KEY_SAVE_ACTION") {
                    path.removeLast()
                }
            case .openAIModelSelection:
                LLMOpenAIModelOnboardingStep(
                    actionText: "OPEN_AI_MODEL_SAVE_ACTION",
                    models: [.gpt3_5Turbo, .gpt4, .gpt4_o]
                ) { model in
                    Task {
                        openAIModel = model
                        try? await healthDataInterpreter.prepareLLM(with: LLMOpenAISchema(parameters: .init(modelType: model)))
                        path.removeLast()
                    }
                }
            }
        }
    }
}

private func readJSONFile(fileName: String) -> String? {
    // Locate the JSON file in the app bundle
    guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("JSON file not found")
        return nil
    }
    
    do {
        // Read the file content
        let data = try Data(contentsOf: fileURL)
        
        // Convert the data to a string
        if let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        } else {
            print("Unable to convert data to string")
            return nil
        }
    } catch {
        print("Error reading file: \(error.localizedDescription)")
        return nil
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    var onDismiss: (String) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.delegate = context.coordinator
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        var parent: SafariView
        
        init(_ parent: SafariView) {
            self.parent = parent
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            parent.onDismiss(fetchTextFromClipboard())
        }
        
        private func fetchTextFromClipboard() -> String {
            return UIPasteboard.general.string ?? ""
        }
    }
}



#Preview {
    SettingsView()
}
