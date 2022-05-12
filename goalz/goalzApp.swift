//
//  goalzApp.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/2/22.
//

import SwiftUI
import HealthKit
import Firebase

//collect participant id and send to firebase
//notification at time and when reach goal
//day 1 - 7 no goal adjustment; day 7 - 10 adjust
@main
struct goalzApp: App {
    let persistentController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    init () {
        FirebaseApp.configure()
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentController.container.viewContext)
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .background:
                UIApplication.shared.applicationIconBadgeNumber = 0
                print("Scene is in background")
                persistentController.save()
            case .inactive:
                UIApplication.shared.applicationIconBadgeNumber = 0
                print("Scene is inactive")
            case .active:
                UIApplication.shared.applicationIconBadgeNumber = 0
                print("Scene is active")
            @unknown default:
                UIApplication.shared.applicationIconBadgeNumber = 0
                print("Scene is default")
            }
        }
    }
}

