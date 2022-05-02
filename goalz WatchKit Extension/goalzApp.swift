//
//  goalzApp.swift
//  goalz WatchKit Extension
//
//  Created by Taylor  Lallas on 5/2/22.
//

import SwiftUI

@main
struct goalzApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
