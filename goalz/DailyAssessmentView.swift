//
//  DailyAssessmentView.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/2/22.
//

import SwiftUI
import UIKit
import HealthKit

struct DailyAssessmentView: View {
    @State private var selected = 1
    
    var body: some View {
        VStack {
            Text("How are you feeling today?")
                .font(.headline)
            
                    }.padding(.top, 70)
            .ignoresSafeArea()
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

struct DailyAssessmentView_Previews: PreviewProvider {
    static var previews: some View {
        DailyAssessmentView()
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
