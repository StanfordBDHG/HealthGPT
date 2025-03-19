//  HealthDataGenerator.swift
//  HealthGPT
//
//  Created by Tim Schwirtlich on 6/26/24.
//

import Foundation
import HealthKit
import Spezi

@Observable
class HealthDataGenerator: DefaultInitializable, Module, EnvironmentAccessible {
    @ObservationIgnored private let healthStore = HKHealthStore()
    
    required init() { }
    
    func requestHealthKitAuthorization() {
        // Define the clinical types you want to write
        let recordTypesToWrite: Set<HKSampleType> = [
            HKQuantityType(.bodyMass),
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
            //HKQuantityType(.appleExerciseTime),
            HKQuantityType(.bodyMass),
            HKQuantityType(.heartRate),
            HKCategoryType(.sleepAnalysis),
            //HKObjectType.clinicalType(forIdentifier: .allergyRecord)!,
            //HKObjectType.clinicalType(forIdentifier: .clinicalNoteRecord)!,
            /*HKObjectType.clinicalType(forIdentifier: .conditionRecord)!,
            HKObjectType.clinicalType(forIdentifier: .coverageRecord)!,
            HKObjectType.clinicalType(forIdentifier: .immunizationRecord)!,
            HKObjectType.clinicalType(forIdentifier: .labResultRecord)!,
            HKObjectType.clinicalType(forIdentifier: .medicationRecord)!,
            HKObjectType.clinicalType(forIdentifier: .procedureRecord)!,
            HKObjectType.clinicalType(forIdentifier: .vitalSignRecord)!,*/
        ]
        
        healthStore.requestAuthorization(toShare: recordTypesToWrite, read: []) { success, error in
            if let error = error {
                // Handle the error here.
                print("Error requesting HealthKit authorization: \(error.localizedDescription)")
            } else {
                // Authorization successful.
                print("HealthKit authorization successful: \(success)")
            }
        }
    }
    
    func createTestDataHealthRecords() {
        requestHealthKitAuthorization()
        saveBodyWeightRecord(weightInKg: 77.3)
    }
    
    func deleteTestDataHealthRecords() {
        fetchBodyWeightRecord { sample in
            guard let sample = sample else {
                print("No body weight record found to delete")
                return
            }

            self.healthStore.delete(sample) { success, error in
                if let error = error {
                    print("Error deleting body weight record: \(error.localizedDescription)")
                } else {
                    print("Body weight record deleted successfully: \(success)")
                }
            }
        }
    }
    
    func saveBodyWeightRecord(weightInKg: Double) {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("Body Mass type is no longer available in HealthKit")
        }

        let bodyWeightQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weightInKg)
        let bodyWeightSample = HKQuantitySample(type: bodyMassType, quantity: bodyWeightQuantity, start: Date(), end: Date())

        healthStore.save(bodyWeightSample) { success, error in
            if let error = error {
                print("Error saving body weight record: \(error.localizedDescription)")
            } else {
                print("Body weight record saved successfully: \(success)")
            }
        }
    }

    
    func saveClinicalRecord() {
        guard let allergyType = HKObjectType.clinicalType(forIdentifier: .allergyRecord) else {
            fatalError("Allergy record type is no longer available in HealthKit")
        }

        // Assuming you have a valid FHIR resource URL and identifier
        let fhirResourceURL = URL(string: "https://example.com/fhir/AllergyIntolerance/12345")!
        let resourceIdentifier = "12345"

        /*let allergyRecord = HKClinicalRecord(
            type: allergyType,
            start: Date(),
            end: Date(),
            fhirResource: fhirResourceURL,
            fhirResourceType: .allergyIntolerance
        )

        healthStore.save(allergyRecord) { success, error in
            if let error = error {
                // Handle the error here.
                print("Error saving allergy record: \(error.localizedDescription)")
            } else {
                // Record saved successfully.
                print("Allergy record saved successfully: \(success)")
            }
        }*/
    }
    
    
    func fetchBodyWeightRecord(completion: @escaping (HKQuantitySample?) -> Void) {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            fatalError("Body Mass type is no longer available in HealthKit")
        }

        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: bodyMassType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
            guard let samples = samples as? [HKQuantitySample], let sample = samples.first else {
                completion(nil)
                return
            }
            completion(sample)
        }
        
        healthStore.execute(query)
    }

    
}
