import SwiftUI
import SwiftData

struct TreadmillWorkout: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var totalDuration: Double 
    var walkingSpeed: Double 
    var runningDuration: Double 
    var runningSpeed: Double 
    
    var walkingDuration: Double {
        totalDuration - runningDuration
    }
    
    var runningDistance: Double {
        (runningDuration / 60) * runningSpeed
    }
    
    var walkingDistance: Double {
        (walkingDuration / 60) * walkingSpeed
    }
    
    var totalDistance: Double {
        runningDistance + walkingDistance
    }
    
    var caloriesBurned: Double {
        let runningCalories = runningDuration * 10 
        let walkingCalories = walkingDuration * 5 
        return runningCalories + walkingCalories
    }
    
    // Obliczanie średniej prędkości całkowitej
    var averageSpeed: Double {
        if totalDuration > 0 {
            return totalDistance / (totalDuration / 60)
        }
        return 0
    }
}

@main
struct FitnessTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
