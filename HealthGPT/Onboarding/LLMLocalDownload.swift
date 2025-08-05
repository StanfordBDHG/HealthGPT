//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2024 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziLLMLocalDownload
import SpeziViews
import SwiftUI

struct LLMLocalDownload: View {
    @Environment(ManagedNavigationStack.Path.self) private var onboardingNavigationPath


    var body: some View {
        LLMLocalDownloadView(
            model: .llama3_8B_4bit,
            downloadDescription: "LLAMA3_DOWNLOAD_DESCRIPTION"
        ) {
            onboardingNavigationPath.nextStep()
        }
    }
}

#Preview {
    LLMLocalDownload()
}
