//
//  GoalRingView.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/2/22.
//

import SwiftUI
import HealthKit
import Firebase
import WidgetKit

var minutesDataArray: [HealthDataTypeValue] = []


func calcRingFill(_ progress: UserProgress, goal: Double, achieveNotified: Bool, docPath: String) {
    let exerciseType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!
    let anchor = createAnchorDate()
    let daily = DateComponents(day: 1)
    
    let query = HKStatisticsCollectionQuery(quantityType: exerciseType, quantitySamplePredicate: createLastWeekPredicate(), options: .cumulativeSum, anchorDate: anchor, intervalComponents: daily)
    
    // Set the results handler
    query.initialResultsHandler =  { query, results, error in
        if let statsCollection = results {
            updateUIFromStatistics(statsCollection, progress, goal: goal, achieveNotified: achieveNotified, docPath: docPath)
        }
    }
    query.statisticsUpdateHandler = {
        query, statistics, statisticsCollection, error in
        if let statsCollection = statisticsCollection {
            updateUIFromStatistics(statsCollection, progress, goal: goal, achieveNotified: achieveNotified, docPath: docPath)
            
            let userDefaults = UserDefaults(suiteName: "group.goalzGroup")
            userDefaults?.setValue(goal, forKey: "goal")
            userDefaults?.setValue(progress.pct, forKey: "pct")
            WidgetCenter.shared.reloadAllTimelines()
        }


    }
    HealthData.healthStore.execute(query)
}

func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection, _ progress: UserProgress, goal: Double, achieveNotified: Bool, docPath: String) {
    minutesDataArray = []
    let now = Date()
    let startDate = getLastWeekStartDate()
    let endDate = now
    let db = Firestore.firestore()
    
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
        if minutesDataArray.count >= 7 {
        progress.minutes = minutesDataArray[6].value //PROBLEM
        progress.pct = progress.minutes/goal * 100
        
        let docRef = db.document(docPath)
        var alreadyAchieved = false
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                alreadyAchieved = document.get("achieved") as! Bool
                print("Document data: \(alreadyAchieved)")
            } else {
                print("Document does not exist")
            }}
        
        //check for goal completion to send notification!
        if (progress.pct >= 100 && !alreadyAchieved) {
            sendAchievementNotification()
            
            //update goal achieved in firebase
            docRef.updateData([
                    "achieved": true,
                    "exerciseMinutes": progress.minutes
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
        }
        //Regular update in firebase
        docRef.updateData([ "exerciseMinutes": progress.minutes])
        }
    }
}

struct GoalView: View {
    @Binding var minutesGoal : Double
    @Binding var logged : Bool
    @StateObject var progress = UserProgress()
    @Binding var achieveNotified : Bool
    @FetchRequest(entity: User.entity(),sortDescriptors:[])
    var user: FetchedResults<User>
    let persistentController = PersistenceController.shared
    
    var body: some View {
        if logged {
            VStack {
                Text("Daily Exercise Goal")
                    .font(.title)
                    .padding(.bottom)
                
                RingView(ringWidth: 15, percent: progress.pct == 0.0 ? 0.1 : progress.pct,
                         backgroundColor: Color.black.opacity(0.2),
                         foregroundColors: [Color.purple], goal: minutesGoal)
                .frame(width: 200, height: 200)
                
                HStack (alignment: .firstTextBaseline) {
                    Text(String(Int(progress.minutes)))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.purple)
                    Text("/")
                    Text(String(Int(minutesGoal)))
                        .fontWeight(.regular)
                        .foregroundColor(Color.black)
                    Text("min")
                }
                if progress.pct < 100.0 {
                    Text(String(Int(minutesGoal - progress.minutes)) + " more min to reach your goal for today!")
                        .font(.footnote)
                        .foregroundColor(Color.black.opacity(0.4))
                } else {
                    Text("GOAL ACHIEVED!")
                        .font(.footnote)
                        .foregroundColor(Color.black.opacity(0.4))
                }
                Divider().padding()
                
            }.onAppear {
                if !user.isEmpty {
                    let userId = user[0].uuid?.uuidString ?? ""
                    let dayId = user[0].currDayId?.uuidString ?? ""
                    if (userId != "" && dayId != "") {
                    let path = "participants/" + userId + "/days/" + dayId
                        calcRingFill(progress, goal: minutesGoal, achieveNotified: achieveNotified, docPath: path)
                        user[0].progressPct = progress.pct
                        persistentController.save()
                    }
                    
                }
                let userDefaults = UserDefaults(suiteName: "group.goalzGroup")
                userDefaults?.setValue(minutesGoal, forKey: "goal")
                userDefaults?.setValue(progress.pct, forKey: "pct")
                WidgetCenter.shared.reloadAllTimelines()
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
    notificationContent.title = "Exercise goal achieved"
    notificationContent.body = "Way to be a goalgetter!"
    notificationContent.sound = .default
   
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
