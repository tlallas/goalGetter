//
//  GoalRingView.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/2/22.
//

import SwiftUI
import HealthKit

var minutesDataArray: [HealthDataTypeValue] = []

class UserProgress : ObservableObject {
    @Published var minutes = 0.0
    @Published var pct = 0.0
}

func calcRingFill(_ progress: UserProgress, goal: Double) {
    let exerciseType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!
    let anchor = createAnchorDate()
    let daily = DateComponents(day: 1)
    
    let query = HKStatisticsCollectionQuery(quantityType: exerciseType, quantitySamplePredicate: createLastWeekPredicate(), options: .cumulativeSum, anchorDate: anchor, intervalComponents: daily)
    
    // Set the results handler
    query.initialResultsHandler =  { query, results, error in
        if let statsCollection = results {
            updateUIFromStatistics(statsCollection, progress, goal: goal)
        }
    }
    HealthData.healthStore.execute(query)
}

func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection, _ progress: UserProgress, goal: Double) {
    minutesDataArray = []
    let now = Date()
    let startDate = getLastWeekStartDate()
    let endDate = now
    
    statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
        var dataValue = HealthDataTypeValue(startDate: statistics.startDate,
                                            endDate: statistics.endDate,
                                            value: 0)
        
        if let quantity = getStatisticsQuantity(for: statistics, with: .cumulativeSum) {
            dataValue.value = quantity.doubleValue(for: .minute())
        }
        minutesDataArray.append(dataValue)
    }
    DispatchQueue.main.async {
        progress.minutes = minutesDataArray[6].value
        progress.pct = progress.minutes/goal * 100
    }
}

struct GoalView: View {
    @Binding var minutesGoal : Double
    @StateObject var progress = UserProgress()
    
    var body: some View {
        VStack {
            Text("Daily Exercise Goal")
                .font(.headline)
                .padding(.bottom)
            
            RingView(ringWidth: 15, percent: progress.pct == 0.0 ? 0.1 : progress.pct,
                     backgroundColor: Color.black.opacity(0.2),
                     foregroundColors: [Color.purple])
            .frame(width: 200, height: 200)
            
            HStack (alignment: .firstTextBaseline) {
                Text(String(Int(minutesGoal)))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.purple)
                Text("min")
            }
            if progress.pct < 100.0 {
                Text(String(Int(minutesGoal - progress.minutes)) + " min to reach your goal for today!")
                    .font(.footnote)
                    .foregroundColor(Color.black.opacity(0.4))
            } else {
                Text("GOAL ACHIEVED!")
                    .font(.footnote)
                    .foregroundColor(Color.black.opacity(0.4))
            }
            Divider().padding()
        }.onAppear {
            calcRingFill(progress, goal: minutesGoal)
                print(progress.minutes)
            }
    }
}




