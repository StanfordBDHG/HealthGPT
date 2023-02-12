//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Scheduler
import SwiftUI


struct EventContextView: View {
    let eventContext: EventContext
    
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    if eventContext.event.complete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 30))
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(eventContext.task.title)
                            .font(.headline)
                        Text(format(eventDate: eventContext.event.scheduledAt))
                            .font(.subheadline)
                    }
                }
                Divider()
                Text(eventContext.task.description)
                    .font(.callout)
                if !eventContext.event.complete {
                    Text(eventContext.task.context.actionType)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 8)
                }
            }
        }
            .disabled(eventContext.event.complete)
            .contentShape(Rectangle())
    }
    
    
    private func format(eventDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: eventDate)
    }
}


#if DEBUG
struct EventContextView_Previews: PreviewProvider {
    // We use a force unwrap in the preview as we can not recover from an error here
    // and the code will never end up in a production environment.
    // swiftlint:disable:next force_unwrapping
    private static let task = TemplateApplicationScheduler().tasks.first!
    
    
    static var previews: some View {
        EventContextView(
            eventContext: EventContext(
                // We use a force unwrap in the preview as we can not recover from an error here
                // and the code will never end up in a production environment.
                // swiftlint:disable:next force_unwrapping
                event: task.events(from: .now.addingTimeInterval(-60 * 60 * 24)).first!,
                task: task
            )
        )
            .padding()
    }
}
#endif
