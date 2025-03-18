import SwiftUI
import SwiftData
import HealthKit

@main
struct FitnessTrackerApp: App {
    let container: ModelContainer
    
    init() {
        do {
            // Initialize the ModelContainer with your models
            container = try ModelContainer(for: UserProfile.self, WeightMeasurement.self, TreadmillWorkout.self)
        } catch {
            // Print the error for debugging
            fatalError("Could not initialize ModelContainer: \(error)")
        }
        
        // Request HealthKit authorization
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            let stepType = HKQuantityType(.stepCount)
            let typesToRead: Set<HKObjectType> = [stepType]
            
            healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
                if success {
                    print("HealthKit authorization granted")
                } else if let error = error {
                    print("HealthKit authorization failed: \(error.localizedDescription)")
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
