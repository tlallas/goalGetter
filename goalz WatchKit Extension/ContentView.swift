//
//  ContentView.swift
//  goalz WatchKit Extension
//
//  Created by Taylor  Lallas on 5/2/22.
//

import SwiftUI


struct ContentView: View {
//    @FetchRequest(entity: User.entity(),sortDescriptors:[])
//    var user: FetchedResults<User>
    @State var goal : Double = 0
    @State var pct : Double = 0
    
    var body: some View {
        Text("Hello")
//        RingView(ringWidth: 15, percent: pct == 0.0 ? 0.1 : pct,
//                 backgroundColor: Color.black.opacity(0.2),
//                 foregroundColors: [Color.purple], goal: goal)
//        .frame(width: 50, height: 50)
//        .onAppear(perform: {
//            if !user.isEmpty {
//                goal = user[0].minutesGoal
//                pct = user[0].progressPct
//            }
//        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
