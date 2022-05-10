//
//  DailyAssessmentView.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/2/22.
//

import SwiftUI
import UIKit
import HealthKit

func calculateGoal(wellLevel: Double) -> Double {
    // minutes = -1(x - 6.5)^2 + 0.5x^2 + z
    // x = wellbeing level, z = baseline exercise goal
    let baseline : Double = 30.0
    let minutes :  Double = 0.5*(Double(wellLevel*wellLevel)) - Double((wellLevel - 6.5)*(wellLevel - 6.5)) + baseline
    return minutes
}

struct DailyAssessmentView: View {
    @Binding var tabSelection: Int
    @Binding var minutesGoal : Double
    @State private var selected = 1
    @State var wellbeing = 0
    @State var logged : Bool = false
    
    var body: some View {
        VStack {
            VStack {
            HStack {
                Spacer()
                Text("How are you feeling today?")
                    .font(.headline)
                    .padding(.bottom, 30)
                Spacer()
            }
                

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
                
                WellbeingBlurb(wellbeing: $wellbeing).padding(.bottom, 20)
                
                if wellbeing > 0 {
                    HStack {
                        Button {
                            tabSelection = 1
                            minutesGoal = calculateGoal(wellLevel: Double(wellbeing))
                            print(minutesGoal)
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
            }
    }
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



//class RadioButton: UIButton {
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.initButton()
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.initButton()
//    }
//
//    func initButton(){
//        self.backgroundColor = .clear
//        self.tintColor = .clear
//        self.setTitle("", for: .normal)
//        self.setImage(UIImage(named: "radio_button_unchecked")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        self.setImage(UIImage(named: "radio_button_checked")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
//        self.setImage(UIImage(named: "radio_button_checked")?.withRenderingMode(.alwaysOriginal), for: .selected)
//
//    }
//}
