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
    @Published var goal = 30.0
    @Published var pct = 0.0
}

func calcRingFill(_ progress: UserProgress) {
    let exerciseType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!
    let anchor = createAnchorDate()
    let daily = DateComponents(day: 1)
    
    let query = HKStatisticsCollectionQuery(quantityType: exerciseType, quantitySamplePredicate: createLastWeekPredicate(), options: .cumulativeSum, anchorDate: anchor, intervalComponents: daily)
    
    // Set the results handler
    query.initialResultsHandler = { query, results, error in
        if let statsCollection = results {
            updateUIFromStatistics(statsCollection, progress)
        }
    }
    HealthData.healthStore.execute(query)
}

func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection, _ progress: UserProgress) {
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
        progress.pct = progress.minutes/progress.goal * 100
    }
}

struct GoalView: View {
    @StateObject var progress = UserProgress()
    
    var body: some View {
        VStack {
            Text("Daily Exercise Goal")
                .font(.headline)
            
            RingView(ringWidth: 15, percent: progress.pct == 0.0 ? 0.1 : progress.pct,
                     backgroundColor: Color.black.opacity(0.2),
                     foregroundColors: [Color.pink])
            .frame(width: 200, height: 200)
            
            HStack (alignment: .firstTextBaseline) {
                Text(String(progress.minutes))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.pink)
                Text("min")
            }
            if progress.pct < 100.0 {
                Text(String(progress.goal - progress.minutes) + " min to reach your goal for today!")
                    .font(.footnote)
                    .foregroundColor(Color.black.opacity(0.4))
            } else {
                Text("GOAL ACHIEVED!")
                    .font(.footnote)
                    .foregroundColor(Color.black.opacity(0.4))
            }
            Divider().padding()
        }.padding(.top, 70)
            .ignoresSafeArea()
            .onAppear {
                calcRingFill(progress)
                print(progress.minutes)
            }
    }
}

struct GoalView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView()
    }
}


