//
// This source file is part of the Stanford HealthGPT project
//
// SPDX-FileCopyrightText: 2023 Stanford University & Project Contributors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// A banner view that displays rotating sample query suggestions.
/// Tapping a suggestion triggers the `onSuggestionTapped` callback.
/// The suggestion automatically cycles every 10 seconds with a fade animation.
struct SuggestionBannerView: View {
    /// Callback invoked when the user taps a suggestion. Passes the query string.
    let onSuggestionTapped: (String) -> Void

    /// The currently displayed suggestion text.
    @State private var currentSuggestion: String = SampleQueries.random()

    /// Controls the opacity for the fade-in/fade-out cycling animation.
    @State private var opacity: Double = 1.0

    var body: some View {
        VStack(spacing: 8) {
            // "Try asking:" label
            Text("SUGGESTION_PREFIX")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // The tappable suggestion pill/card
            Button {
                onSuggestionTapped(currentSuggestion)
            } label: {
                Text(currentSuggestion)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("suggestionBanner")
            .accessibilityHint(Text("SUGGESTION_ACCESSIBILITY_HINT"))
        }
        .opacity(opacity)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .task {
            // Cycle suggestions every 10 seconds with fade animation
            await cycleSuggestions()
        }
    }

    /// Continuously cycles through suggestions with a fade-out → swap → fade-in animation.
    /// This async function runs for the lifetime of the view and auto-cancels on disappear.
    @MainActor
    private func cycleSuggestions() async {
        while !Task.isCancelled {
            // Wait 10 seconds before cycling
            try? await Task.sleep(for: .seconds(7))

            guard !Task.isCancelled else {
                return
            }

            // Phase 1: Fade out (0.4s)
            withAnimation(.easeInOut(duration: 0.6)) {
                opacity = 0.0
            }

            // Wait for fade-out to complete
            try? await Task.sleep(for: .milliseconds(600))

            guard !Task.isCancelled else {
                return
            }

            // Phase 2: Swap the text (while invisible)
            currentSuggestion = SampleQueries.random(excluding: currentSuggestion)

            // Phase 3: Fade in (0.4s)
            withAnimation(.easeInOut(duration: 0.6)) {
                opacity = 1.0
            }
        }
    }
}
