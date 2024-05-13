//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2024 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziLLMLocalDownload
import SpeziOnboarding
import SwiftUI

struct LLMLocalDownload: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath


    var body: some View {
        LLMLocalDownloadView(
            downloadDescription: "LLAMA3_DOWNLOAD_DESCRIPTION",
            llmDownloadUrl: LLMLocalDownloadManager.LLMUrlDefaults.llama3InstructModelUrl,
            llmStorageUrl: .cachesDirectory.appending(path: "llm.gguf")
        ) {
            onboardingNavigationPath.nextStep()
        }
    }
}

#Preview {
    LLMLocalDownload()
}
