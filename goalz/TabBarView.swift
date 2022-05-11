//
//  TabBarView.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/2/22.
//

import SwiftUI

struct TabBarView: View {
    @State private var tabSelection = 0
    @State var minutesGoal : Double = 30.0
    @State var logged : Bool = false
    
    var body: some View {
        TabView(selection: $tabSelection) {
            NavigationView {
                VStack{
                    DailyAssessmentView(tabSelection: $tabSelection, minutesGoal: $minutesGoal, logged: $logged)
                    Spacer()
                    Divider()
                }
            }
            .tag(0)
            .tabItem {
                Image(systemName: "heart.text.square")
                    .resizable()
                Text("Wellbeing Check")
            }

            NavigationView {
                VStack {
                    GoalView(minutesGoal: $minutesGoal, logged: $logged)
                    Spacer()
                    Divider()
                }
            }
            .tag(1)
            .tabItem {
                Image(systemName: "figure.walk")
                Text("Exercise Goal")
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
