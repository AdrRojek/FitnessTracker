import SwiftUI
import SwiftData
import HealthKit

@main
struct FitnessTrackerApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: TreadmillWorkout.self, UserProfile.self, WeightMeasurement.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
        
        // Dodaj uprawnienia HealthKit
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            let stepType = HKQuantityType(.stepCount)
            let typesToRead: Set<HKObjectType> = [stepType]
            
            healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
                if success {
                    print("HealthKit authorization granted")
                } else {
                    print("HealthKit authorization failed")
                }
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
