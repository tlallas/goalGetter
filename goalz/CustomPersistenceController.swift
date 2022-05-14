//
//  CustomPersistenceController.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/14/22.
//

import Foundation
import UIKit
import CoreData

class NSCustomPersistentContainer: NSPersistentCloudKitContainer {
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.goalzGroup")
        storeURL = storeURL?.appendingPathComponent("goalz.sqlite")
        return storeURL!
    }
}
