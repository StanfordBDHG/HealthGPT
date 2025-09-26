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
import SpeziViews
import SwiftUI

struct SettingsView: View {
    @Environment(HealthDataInterpreter.self) private var healthDataInterpreter
    @Environment(\.dismiss) private var dismiss

    @AppStorage(StorageKeys.enableTextToSpeech) private var enableTextToSpeech = StorageKeys.Defaults.enableTextToSpeech

    @State private var path = ManagedNavigationStack.Path()
    @State private var didComplete = false
    @Binding var modelSettingRefreshId: UUID

    
    var body: some View {
        ManagedNavigationStack(didComplete: self.$didComplete, path: self.path) {
            List {
                self.changeModelSettings
                self.chatSettings
                self.speechSettings
                self.disclaimer
            }
            .navigationTitle("SETTINGS_TITLE")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("SETTINGS_DONE") {
                        dismiss()
                    }
                }
            }
            .accessibilityIdentifier("settingsList")
        }
            .onChange(of: self.didComplete) { _, newValue in
                if newValue {
                    self.modelSettingRefreshId = UUID()      // fresh refresh main view
                    dismiss()
                }
            }
    }
    
    private var changeModelSettings: some View {
        Section("LLM Settings") {
            Button("Select Execution Type & Model") {
                self.path.append(customView: LLMSourceSelection())
            }
                .accessibilityIdentifier("changeModelButton")
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
    
    private var disclaimer: some View {
        Section("SETTINGS_DISCLAIMER_TITLE") {
            Text("SETTINGS_DISCLAIMER_TEXT")
        }
    }
}


#if DEBUG
#Preview {
    SettingsView(modelSettingRefreshId: .constant(UUID()))
}
#endif
