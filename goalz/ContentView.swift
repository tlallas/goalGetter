//
//  ContentView.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/2/22.
//

import SwiftUI

struct ContentView: View {
    let persistentController = PersistenceController.shared
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: User.entity(),sortDescriptors:[])
    var user: FetchedResults<User>
    
    @State var inOnboarding : Bool = false
    @State var logged : Bool = false
    @State var minutesGoal : Double = 30.0
    
    var body: some View {
        VStack {
            if !inOnboarding {
                TabBarView(logged: $logged, minutesGoal: $minutesGoal)
            } else {
                OnboardingView(inOnboarding: $inOnboarding)
            }
        }.onAppear(perform: {
            if user.isEmpty  {
                inOnboarding = true
            } else {
                if let lastLogDate = user[0].lastLogged {
                    let now = Date()
                    if checkLoggedToday(last: lastLogDate, today: now) {
                        logged = true
                        minutesGoal = user[0].minutesGoal
                    }
                }
            }
        })
    }
}

func checkLoggedToday(last: Date, today: Date) -> Bool {
    print("in check logged today")
    let diff = Calendar.current.dateComponents([.day], from: last, to: today)
        if diff.day == 0 { //same day
            return true
        } else {
            return false
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
