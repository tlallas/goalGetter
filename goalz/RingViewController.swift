//
//  RingViewController.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/5/22.
//

import Foundation
import UIKit
import HealthKit

class RingViewController {
    var dataValues: [HealthDataTypeValue] = []
    
    
    func calcRingFill() {
        let exerciseType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleExerciseTime)!
        let anchor = createAnchorDate()
        let daily = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(quantityType: exerciseType, quantitySamplePredicate: createLastWeekPredicate(), options: .cumulativeSum, anchorDate: anchor, intervalComponents: daily)
        
        // Set the results handler
        query.initialResultsHandler = { query, results, error in
            if let statsCollection = results {
                self.updateUIFromStatistics(statsCollection)
            }
        }
        HealthData.healthStore.execute(query)
    }
    
    func updateUIFromStatistics(_ statisticsCollection: HKStatisticsCollection) {
        self.dataValues = []
        
        let now = Date()
        let startDate = getLastWeekStartDate()
        let endDate = now
        
        statisticsCollection.enumerateStatistics(from: startDate, to: endDate) { [weak self] (statistics, stop) in
            var dataValue = HealthDataTypeValue(startDate: statistics.startDate,
                                                endDate: statistics.endDate,
                                                value: 0)
            
            if let quantity = getStatisticsQuantity(for: statistics, with: .cumulativeSum) {
                dataValue.value = quantity.doubleValue(for: .minute())
            }
            
            self?.dataValues.append(dataValue)
        }
        
    }
}
