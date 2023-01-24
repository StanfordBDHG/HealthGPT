//
// This source file is part of the Stanford CardinalKit Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


import Questionnaires
import Scheduler
import SwiftUI


struct EventContext: Comparable, Identifiable {
    let event: Event
    let task: Task<TemplateApplicationTaskContext>
    
    
    var id: Event.ID {
        event.id
    }
    
    
    static func < (lhs: EventContext, rhs: EventContext) -> Bool {
        lhs.event.scheduledAt < rhs.event.scheduledAt
    }
}


struct EventContextView: View {
    let eventContext: EventContext
    
    
    var body: some View {
        HStack {
            VStack {
                Text(eventContext.task.title)
                    .font(.title2)
                Text(eventContext.task.description)
                    .foregroundColor(.secondary)
            }
            Group {
                if eventContext.event.complete {
                    Image(systemName: "checkmark.circle.fill")
                } else {
                    Image(systemName: "circle")
                }
            }
                .font(.largeTitle.weight(.regular))
                .foregroundColor(.gray)
                .padding(.leading, 4)
        }
            .disabled(eventContext.event.complete)
            .contentShape(Rectangle())
    }
}


struct SchedulerView: View {
    @EnvironmentObject var scheduler: TemplateApplicationScheduler
    @State var eventContextsByDate: [Date: [EventContext]] = [:]
    @State var presentedContext: EventContext?
    
    
    var startOfDays: [Date] {
        Array(eventContextsByDate.keys)
    }
    
    
    var body: some View {
        NavigationStack {
            List(startOfDays, id: \.timeIntervalSinceNow) { startOfDay in
                Section(format(startOfDay: startOfDay)) {
                    ForEach(eventContextsByDate[startOfDay] ?? [], id: \.event) { eventContext in
                        EventContextView(eventContext: eventContext)
                            .onTapGesture {
                                if !eventContext.event.complete {
                                    presentedContext = eventContext
                                }
                            }
                    }
                }
            }
                .onChange(of: scheduler) { _ in
                    calculateEventContextsByDate()
                }
                .task {
                    calculateEventContextsByDate()
                }
                .sheet(item: $presentedContext) { presentedContext in
                    destination(withContext: presentedContext)
                }
                .navigationTitle("SCHEDULER_LIST_TITLE")
        }
    }
    
    
    private func destination(withContext eventContext: EventContext) -> some View {
        @ViewBuilder
        var destination: some View {
            switch eventContext.task.context {
            case let .questionnaire(questionnaire):
                QuestionnaireView(questionnaire: questionnaire) { _ in
                    _Concurrency.Task {
                        await eventContext.event.complete(true)
                    }
                }
            }
        }
        return destination
    }
    
    
    private func format(startOfDay: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: startOfDay)
    }
    
    private func calculateEventContextsByDate() {
        let eventContexts = scheduler.tasks.flatMap { task in
            task
                .events(
                    from: Calendar.current.startOfDay(for: .now),
                    to: .numberOfEventsOrEndDate(100, .now)
                )
                .map { event in
                    EventContext(event: event, task: task)
                }
        }
            .sorted()
        
        let newEventContextsByDate = Dictionary(grouping: eventContexts) { eventContext in
            Calendar.current.startOfDay(for: eventContext.event.scheduledAt)
        }
        
        if newEventContextsByDate != eventContextsByDate {
            eventContextsByDate = newEventContextsByDate
        }
    }
}


struct SchedulerView_Previews: PreviewProvider {
    static var previews: some View {
        SchedulerView()
            .environmentObject(TemplateApplicationScheduler())
    }
}
