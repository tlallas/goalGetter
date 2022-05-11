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
    
    var body: some View {
        VStack {
            if !inOnboarding {
                TabBarView()
            } else {
                OnboardingView(inOnboarding: $inOnboarding)
            }
        }.onAppear(perform: {
            if user.isEmpty  {
                inOnboarding = true
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
