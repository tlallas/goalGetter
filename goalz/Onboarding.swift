//
//  OnboardingView.swift
//  App Onboarding
//
//  Created by Taylor  Lallas on 4/23/22.
//

import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    let persistentController = PersistenceController.shared
    @FetchRequest(entity: User.entity(),sortDescriptors:[])
    var user: FetchedResults<User>
    @State private var name: String = ""
    @State private var id: String = ""
    @State private var goal: String = ""
    @Binding var inOnboarding : Bool
    
    var titles = ["welcome to", "Enter your first name & participant id", "How many minutes do you try to exercise each day?"]
    
    var headlines =  ["wellbeing-based workout goals", "", ""]
    
    var subheadlines = ["", "", ""]
    
    
    @State var currentPageIndex = 0
    let exampleColor : Color = Color(red: 147/255, green: 174/255, blue: 212/255)
    
    var body: some View {
        ZStack { // 1
        
            VStack {
      
           
                VStack {
                    Text(titles[currentPageIndex])
                        .font(.headline)
                        .padding(.bottom)
                    if self.currentPageIndex == 0 {
                        Text("GoalGetter")
                            .font(.system(size: 60.0))
                            .fontWeight(.bold)
                            .padding(.bottom)
                    }
                }


            if (self.currentPageIndex == 1) {
                VStack {
                    TextField("First name", text: $name)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(5)
                    
                    TextField("Participant ID", text: $id)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(5)
                }.padding([.trailing, .leading], 15)
                
            }
                
            if (self.currentPageIndex == 2) {
                VStack {
                    HStack {
                    Text("Help us establish your target goals!")
                        .font(.subheadline)
                        .fontWeight(.light)
                        Spacer()
                    }.padding([.leading, .bottom])
                    
                    TextField("Daily exercise (in minutes)", text: $goal)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(5)
                        
                }.padding([.trailing, .leading],15)
                
            }
      
            
            VStack {
                Text(headlines[currentPageIndex])
                    .font(.headline)
                    .padding(.top)
                
                Text(subheadlines[currentPageIndex])
                    .font(.subheadline)
                    .fontWeight(.light)
            }.padding(.bottom, 80)
           
            PageControl(numberOfPages: titles.count, currentPageIndex: $currentPageIndex)
            
            HStack {
                Button(action: {
                    if self.currentPageIndex > 0 {
                        self.currentPageIndex = self.currentPageIndex - 1
                    }
                }) {
                    if (self.currentPageIndex > 0) {
                        ButtonLeftContent()
                    }
                }
                if self.currentPageIndex > 0 {
                    Spacer()
                }
                Button(action: {
                    if self.currentPageIndex == 2 {
                        let newUser = User(context: persistentController.container.viewContext)
                        newUser.isOnboard = true
                        newUser.id = id
                        newUser.name = name
                        newUser.baselineGoal = Double(goal) ?? 30.0
                        newUser.firstUse = true
                        PersistenceController.shared.save()
                        inOnboarding = false
                    } else if self.currentPageIndex == 1 {
                        if name != "" && id != "" {
                            self.currentPageIndex += 1
                        }
                    } else if self.currentPageIndex == 0{
                        self.currentPageIndex += 1
                    }
                }) {
                    if (self.currentPageIndex == 0) {
                            ButtonStartContent()
                 
                    } else {
                        if (self.currentPageIndex == 1) {
                            if (name == "" || id == "") {
                                ButtonRightContent(buttonColor: Color.gray.opacity(0.2))
                            } else {
                                ButtonRightContent(buttonColor: Color.purple)
                            }
                        } else if (self.currentPageIndex == 2) {
                            if (goal == "") {
                                ButtonFinishContent(buttonColor: Color.gray.opacity(0.2))
                            } else {
                                ButtonFinishContent(buttonColor: Color.purple)
                            }
                        } else {
                            ButtonRightContent(buttonColor: Color.purple)
                        }
                    }
                }
            }.padding(.top)
                .padding(.trailing, 25)
                .padding(.leading, 25)
                .padding(.bottom, 75)
        }}
    }
}

func retrieveTodaysFlic() {
    if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
        PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus) -> Void in ()
        })
    }}

struct ButtonRightContent: View {
    var buttonColor : Color
    
    var body: some View {
        
        HStack {
            Text("Next").foregroundColor(Color.white)
            Image(systemName: "chevron.right")
            .resizable()
            .foregroundColor(Color.white)
            .frame(width: 10, height: 20)
            .cornerRadius(30)
        }.padding()
            .background(buttonColor
                .cornerRadius(40))
    }
}

struct ButtonLeftContent: View {
    var body: some View {
        HStack {
            Image(systemName: "chevron.left")
            .resizable()
            .foregroundColor(Color.white)
            .frame(width: 10, height: 20)
            .cornerRadius(30)
            Text("Prev").foregroundColor(Color.white)
        }.padding()
            .background(Color.purple)
            .cornerRadius(40)
    }
}

struct ButtonStartContent: View {
    var body: some View {
        HStack {
            HStack {
                Text("Get Started").foregroundColor(Color.white)
                    .padding(.leading)
                    .padding(.trailing)
                Image(systemName: "chevron.right")
                .resizable()
                .foregroundColor(Color.white)
                .frame(width: 10, height: 20)
                .cornerRadius(30)
            }.padding()
                .background(Color.purple
                    .cornerRadius(40))
        }
    }
}

struct ButtonFinishContent: View {
    var buttonColor : Color
    var body: some View {
        HStack {
            Text("Finish").foregroundColor(Color.white)
            Image(systemName: "chevron.right")
            .resizable()
            .foregroundColor(Color.white)
            .frame(width: 10, height: 20)
            .cornerRadius(30)
        }.padding()
            .background(buttonColor
                .cornerRadius(40))
    }
}


