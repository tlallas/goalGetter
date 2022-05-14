//
//  DailyAssessmentView.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/2/22.
//

import SwiftUI
import UIKit
import HealthKit
import Firebase

func calculateGoal(wellLevel: Double, baseline: Double) -> Double {
    // minutes = -1(x - 6.5)^2 + 0.5x^2 + z
    // x = wellbeing level, z = baseline exercise goal
    let minutes :  Double = 0.5*(Double(wellLevel*wellLevel)) - Double((wellLevel - 6.5)*(wellLevel - 6.5)) + baseline
    return minutes
}

struct DailyAssessmentView: View {
    
    @Binding var tabSelection: Int
    @Binding var minutesGoal : Double
    @State private var selected = 1
    @State var wellbeing : Int = 0
    @Binding var logged : Bool
    
    let db = Firestore.firestore()
    let persistentController = PersistenceController.shared
    @FetchRequest(entity: User.entity(),sortDescriptors:[])
    var user: FetchedResults<User>
    
    var body: some View {
        VStack {
            if !logged {
                Text("Please complete your daily wellbeing check!")
                    .font(.title)
                    .padding(.bottom)
            } else {
                Text("Daily check complete!")
                    .font(.title)
                    .padding(.bottom)
            }
            VStack {
   
                if !logged {
                Text("How are you feeling today?")
                    .font(.headline)
                    .padding(.top)
                    .padding(.bottom, 30)
            

                HStack (spacing: 18){
   
                RadioButtonField(
                                   id: 1,
                                   label: "1",
                                   topLabel: "Worst",
                                   color:.black,
                                   bgColor: .purple,
                                   isMarked: $wellbeing.wrappedValue == 1 ? true : false,
                                   callback: { selected in
                                       self.wellbeing = selected
                                       print("Selected Wellbeing is: \(selected)")
                                   }
                               )
                RadioButtonField(
                                   id: 2,
                                   label: "",
                                   topLabel: " ",
                                   color:.black,
                                   bgColor: .purple,
                                   isMarked: $wellbeing.wrappedValue == 2 ? true : false,
                                   callback: { selected in
                                       self.wellbeing = selected
                                       print("Selected Wellbeing is: \(selected)")
                                   }
                               )
                RadioButtonField(
                                   id: 3,
                                   label: "",
                                   topLabel: " ",
                                   color:.black,
                                   bgColor: .purple,
                                   isMarked: $wellbeing.wrappedValue == 3 ? true : false,
                                   callback: { selected in
                                       self.wellbeing = selected
                                       print("Selected Wellbeing is: \(selected)")
                                   }
                               )
                RadioButtonField(
                                   id: 4,
                                   label: "4",
                                   topLabel: "Avg",
                                   color:.black,
                                   bgColor: .purple,
                                   isMarked: $wellbeing.wrappedValue == 4 ? true : false,
                                   callback: { selected in
                                       self.wellbeing = selected
                                       print("Selected Wellbeing is: \(selected)")
                                   }
                               )
                RadioButtonField(
                                   id: 5,
                                   label: "",
                                   topLabel: " ",
                                   color:.black,
                                   bgColor: .purple,
                                   isMarked: $wellbeing.wrappedValue == 5 ? true : false,
                                   callback: { selected in
                                       self.wellbeing = selected
                                       print("Selected Wellbeing is: \(selected)")
                                   }
                               )
                RadioButtonField(
                                   id: 6,
                                   label: "",
                                   topLabel: " ",
                                   color:.black,
                                   bgColor: .purple,
                                   isMarked: $wellbeing.wrappedValue == 6 ? true : false,
                                   callback: { selected in
                                       self.wellbeing = selected
                                       print("Selected Wellbeing is: \(selected)")
                                   }
                               )
                RadioButtonField(
                                   id: 7,
                                   label: "7",
                                   topLabel: "Best",
                                   color:.black,
                                   bgColor: .purple,
                                   isMarked: $wellbeing.wrappedValue == 7 ? true : false,
                                   callback: { selected in
                                       self.wellbeing = selected
                                       print("Selected Wellbeing is: \(selected)")
                                   }
                               )
                }.frame(width: 300, height: 100)
                        .padding(.bottom)
                }
                
                WellbeingBlurb(wellbeing: $wellbeing).padding(.bottom, 20)
                
                if wellbeing > 0 && !logged {
                    HStack {
                        Button {
                            tabSelection = 1
                            minutesGoal = calculateGoal(wellLevel: Double(wellbeing), baseline: user[0].baselineGoal)
                            logged = true
                            user[0].lastLogged = Date()
                            user[0].wellbeingLevel = Int32(wellbeing)
                            user[0].minutesGoal = minutesGoal
                            user[0].achieveNotified = false
                            user[0].currDayId = UUID()
                            PersistenceController.shared.save()
                            
                            if let userid = user[0].uuid?.uuidString {
                                if let dayId = user[0].currDayId?.uuidString {
                                    let pathStr = "participants/" + userid + "/days"
                                    db.collection(pathStr).document(dayId).setData([
                                        "date" : Date(),
                                        "adjustedGoal" : minutesGoal,
                                        "wellbeing" : wellbeing,
                                        "achieved" : false,
                                        "exerciseMinutes": 0,
                                    ])
                                }
                            }
                            
      
                        } label: {
                            Text("Log Wellbeing")
                                .padding()
                                .frame(minWidth:300)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
                }
                    }
            .onAppear {
                    let exerciseType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!
                    HealthData.healthStore.requestAuthorization(toShare: [], read: [exerciseType]) { (success, error) in
                        if success {
                            
                        } else {
                            //they can't do study lol 
                        }
                    }
                    
                wellbeing = Int(user[0].wellbeingLevel)
                if let last = user[0].lastLogged {
                    logged = getLogged(last: last)
                }
                requestNotificationAuthorization()
                scheduleMorningNotification()
            }
    }
}
    
    func getLogged(last: Date) -> Bool {
        if Calendar.current.isDateInToday(last) { //already logged today
            return true
        }
        return false
    }

struct WellbeingBlurb : View {
    @Binding var wellbeing : Int
    
    var body : some View {
        if wellbeing > 0 {
            VStack (alignment: .leading){
                    HStack {
                        Text("Your wellbeing is at a")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(String(wellbeing))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.purple)
                        Text("today")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                
                if wellbeing < 4 && wellbeing > 1 { Text("You might be feeling worse than normal, but you can still hit your exercise goals!") }
                if wellbeing == 1 { Text("You're not feeling good today, but you should still get some movement in if you can!") }
                if wellbeing == 4 {
                    Text("You're feeling pretty normal today! Get after it :)")
                }
                if wellbeing > 4 && wellbeing < 7 {
                    Text("You're feeling even better than normal today. Try to do a little extra movement today!")
                }
                if wellbeing == 7 {
                    Text("You're feeling your best! You can do anything today!")
                }
                Spacer()
            }.padding([.top, .leading])
                .frame(width: 300, height: 110)
                .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
        }
    }
    }
    
}

func requestNotificationAuthorization() {
    let userNotificationCenter = UNUserNotificationCenter.current()
    let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
    
    userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
        if let error = error {
            print("Error: ", error)
        }
    }
}

func scheduleMorningNotification() {
    let userNotificationCenter = UNUserNotificationCenter.current()
    let notificationContent = UNMutableNotificationContent()
    notificationContent.title = "Time for a wellbeing check-in!"
    notificationContent.body = "Open GoalGetter to log how you're feeling"
    
//    if let url = Bundle.main.url(forResource: "dune",
//                                withExtension: "png") {
//        if let attachment = try? UNNotificationAttachment(identifier: "dune",
//                                                        url: url,
//                                                        options: nil) {
//            notificationContent.attachments = [attachment]
//        }
//    }
    
    var datComp = DateComponents()
    datComp.hour = 9
    datComp.minute = 0
    let trigger = UNCalendarNotificationTrigger(dateMatching: datComp, repeats: true)
    let request = UNNotificationRequest(identifier: "dailycheck", content: notificationContent, trigger: trigger)
                    userNotificationCenter.add(request) { (error : Error?) in
                        if let theError = error {
                            print(theError.localizedDescription)
                        }
                    }
}
