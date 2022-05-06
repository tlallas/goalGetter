//
//  HealthKitManager.swift
//  goalz
//
//  Created by Taylor  Lallas on 5/2/22.
//

import Foundation
import HealthKit

class CKHealthKitManager : NSObject {
    static let shared = CKHealthKitManager()
    
        private let quantyTypes = [
            HKQuantityTypeIdentifier.basalEnergyBurned,//keep
    //        HKQuantityTypeIdentifier.bodyMassIndex,
    //        .bodyFatPercentage,
    //        .height,
    //        .bodyMass,
    //        .leanBodyMass,
    //        .waistCircumference,
            .stepCount,
            .distanceWalkingRunning,
    //        .distanceCycling,
    //        .distanceWheelchair,
    //        .basalEnergyBurned,
            .activeEnergyBurned, //keep
    //        .flightsClimbed,
    //        .nikeFuel,
            .appleExerciseTime, //keep
    //        .pushCount,
            .distanceSwimming,
    //        .swimmingStrokeCount,
            .vo2Max,
    //        .distanceDownhillSnowSports,
    //        .appleStandTime,
            .heartRate, //keep
    //        .bodyTemperature,
    //        .basalBodyTemperature,
    //        .bloodPressureSystolic,
    //        .bloodPressureDiastolic,
    //        .respiratoryRate,
//            .restingHeartRate,
    //        .walkingHeartRateAverage,
//            .heartRateVariabilitySDNN,
    //        .oxygenSaturation,
    //        .peripheralPerfusionIndex,
    //        .bloodGlucose,
    //        .numberOfTimesFallen,
    //        .electrodermalActivity,
    //        .inhalerUsage,
    //        .insulinDelivery,
    //        .bloodAlcoholContent,
    //        .forcedVitalCapacity,
    //        .forcedExpiratoryVolume1,
    //        .peakExpiratoryFlowRate,
        ]
    fileprivate var hkTypesToReadInBackground: Set<HKSampleType> = []
    
    override init() {
        for quantiType in quantyTypes{
            hkTypesToReadInBackground.insert(HKObjectType.quantityType(forIdentifier: quantiType)!)
        }
        hkTypesToReadInBackground.insert(HKWorkoutType.workoutType())
    }
    
    /// Query for HealthKit Authorization
    /// - Parameter completion: (success, error)
    func getHealthAuthorization(_ completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        
        /* **************************************************************
         * customize HealthKit data that will be collected
         * in the background. Choose from any HKQuantityType:
         * https://developer.apple.com/documentation/healthkit/hkquantitytypeidentifier
        **************************************************************/
        
        // handle authorization from the OS
//        CKActivityManager.shared.getHealthAuthorizaton(forTypes: hkTypesToReadInBackground) { [weak self] (success, error) in
//            if (success) {
////                let frequency = self?.config.read(query: "Background Read Frequency")
//                let frequency = "immediate"
//
//                if frequency == "daily" {
//                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .daily)
//                } else if frequency == "weekly" {
//                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .weekly)
//                } else if frequency == "hourly" {
//                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .hourly)
//                } else {
//                    CKActivityManager.shared.startHealthKitCollectionInBackground(withFrequency: .immediate)
//                }
//            }
//            completion(success, error)
//        }
//    }
    }
}
