//
//  HealthKitSetupAssist.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/24/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant {
    
    private enum HealthkitSetupError: Error {
      case notAvailableOnDevice
      case dataTypeNotAvailable
    }
    
    
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        //1. Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
          completion(false, HealthkitSetupError.notAvailableOnDevice)
          return
        }
        
        //2. Prepare the data types that will interact with HealthKit
        guard   let stepCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount),
                let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
                
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }
        
        //3. Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [
                                                        activeEnergy,
                                                        HKObjectType.workoutType()]
            
        let healthKitTypesToRead: Set<HKObjectType> = [
                                                       stepCount,
                                                       activeEnergy,
                                                       HKObjectType.workoutType()]
        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
        
        
    }
}

