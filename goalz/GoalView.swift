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
    query.statisticsUpdateHandler = {
        query, statistics, statisticsCollection, error in
        if let statsCollection = statisticsCollection {
            updateUIFromStatistics(statsCollection, progress, goal: goal)
        }
        print(query)
        print(statistics)
        print(statisticsCollection)
        print(error)
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
        
        //check for goal completion to send notification!
        if (progress.pct >= 100) {
            sendAchievementNotification()
        }
    }
}

struct GoalView: View {
    @Binding var minutesGoal : Double
    @Binding var logged : Bool
    @StateObject var progress = UserProgress()
    
    var body: some View {
        if logged {
            VStack {
                Text("Daily Exercise Goal")
                    .font(.title)
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
        } else {
            Text("Fill out your daily wellbeing check to get your exercise goal!")
                .font(.title)
                .padding([.leading, .trailing])
        }
    }
}

func sendAchievementNotification() {
    let userNotificationCenter = UNUserNotificationCenter.current()
    let notificationContent = UNMutableNotificationContent()
    notificationContent.title = "Exercise goal achieved!"
    notificationContent.body = "Way to be a goalgetter :)"
    notificationContent.badge = NSNumber(value: 3)
    
//    if let url = Bundle.main.url(forResource: "dune",
//                                withExtension: "png") {
//        if let attachment = try? UNNotificationAttachment(identifier: "dune",
//                                                        url: url,
//                                                        options: nil) {
//            notificationContent.attachments = [attachment]
//        }
//    }
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                    repeats: false)
    let request = UNNotificationRequest(identifier: "goal achieved",
                                        content: notificationContent,
                                        trigger: trigger)
    
    userNotificationCenter.add(request) { (error) in
        if let error = error {
            print("Notification Error: ", error)
        }
    }
}




//CODE TO OBSERVE WORKOUTS IN BACKGROUND
//func startObservingNewWorkouts() {
//
//    let sampleType =  HKObjectType.workoutType()
//
//    //1. Enable background delivery for workouts
//    HealthData.healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { (success, error) in
//        if let unwrappedError = error {
//            print("could not enable background delivery: \(unwrappedError)")
//        }
//        if success {
//            print("background delivery enabled")
//        }
//    }
//
//    //2.  open observer query
//    let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { (query, completionHandler, error) in
//
//        updateWorkouts() {
//            completionHandler()
//        }
//
//
//    }
//    HealthData.healthStore.execute(query)
//
//}
//
//func updateWorkouts(completionHandler: @escaping () -> Void) {
//
//    var anchor: HKQueryAnchor?
//
//    let sampleType =  HKObjectType.workoutType()
//
//    let anchoredQuery = HKAnchoredObjectQuery(type: sampleType, predicate: nil, anchor: anchor, limit: HKObjectQueryNoLimit) { query, newSamples, deletedSamples, newAnchor, error in
//
//        handleNewWorkouts(new: newSamples!, deleted: deletedSamples!)
//
//        anchor = newAnchor
//
//        completionHandler()
//    }
//    HealthData.healthStore.execute(anchoredQuery)
//
//
//}
//
//func handleNewWorkouts(new: [HKSample], deleted: [HKDeletedObject]) {
//    // var progress = UserProgress()
////    calcRingFill(progress, goal: minutesGoal)
////        print(progress.minutes)
//    
//    print("new sample added = \(new.last.startTime!)")
//}
