//
//  goalzWidget.swift
//  goalzWidget
//
//  Created by Taylor  Lallas on 5/14/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), goal: 30.0, pct: 45.0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), goal: 30.0, pct: 45.0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let userDefaults = UserDefaults(suiteName: "group.goalzGroup")
        let goal = userDefaults?.value(forKey: "goal") as? Double ?? 30.0
        let pct = userDefaults?.value(forKey: "pct") as? Double ?? 0.1
        
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, goal: goal, pct: pct)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let goal : Double
    let pct : Double
}

struct goalzWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        
        RingView(ringWidth: 15, percent: entry.pct, backgroundColor: Color.black.opacity(0.2), foregroundColors: [Color.purple], goal: entry.goal)
        

    }
}

@main
struct goalzWidget: Widget {
    let kind: String = "goalzWidget"
    let persistentController = PersistenceController.shared
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            goalzWidgetEntryView(entry: entry)
                .environment(\.managedObjectContext, persistentController.container.viewContext)
        }
        .configurationDisplayName("GoalGetter Ring")
        .description("View your progress towards your daily goal.")
    }
}

struct goalzWidget_Previews: PreviewProvider {
    static var previews: some View {
        goalzWidgetEntryView(entry: SimpleEntry(date: Date(), goal: 30.0, pct: 45.0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
