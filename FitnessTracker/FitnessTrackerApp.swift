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
    
    // Obliczanie dystansu biegu w kilometrach
    var runningDistance: Double {
        (runningDuration / 60) * runningSpeed
    }
    
    // Obliczanie dystansu chodu w kilometrach
    var walkingDistance: Double {
        (walkingDuration / 60) * walkingSpeed
    }
    
    // Obliczanie całkowitego dystansu w kilometrach
    var totalDistance: Double {
        runningDistance + walkingDistance
    }
    
    // Szacowanie spalonych kalorii (przykładowy wzór)
    var caloriesBurned: Double {
        let runningCalories = runningDuration * 10 // 10 kalorii na minutę biegu
        let walkingCalories = walkingDuration * 5 // 5 kalorii na minutę chodu
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
