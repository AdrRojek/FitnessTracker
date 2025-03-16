import SwiftUI
import SwiftData

struct TreadmillWorkout: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var totalDuration: Double // w minutach
    var walkingSpeed: Double // km/h
    var runningDuration: Double // w minutach
    var runningSpeed: Double // km/h
    
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
    
    // Obliczanie średniej prędkości całkowitej
    var averageSpeed: Double {
        if totalDuration > 0 {
            return totalDistance / (totalDuration / 60)
        }
        return 0
    }
    
    // Obliczanie spalonych kalorii na podstawie danych użytkownika
    func calculateCaloriesBurned(userProfile: UserProfile) -> Double {
        // Współczynnik MET (Metabolic Equivalent of Task)
        let runningMET = calculateRunningMET(speed: runningSpeed)
        let walkingMET = calculateWalkingMET(speed: walkingSpeed)
        
        // Obliczanie kalorii dla biegu
        let runningCalories = (runningMET * userProfile.weight * runningDuration) / 60
        
        // Obliczanie kalorii dla chodu
        let walkingCalories = (walkingMET * userProfile.weight * walkingDuration) / 60
        
        return runningCalories + walkingCalories
    }
    
    // Obliczanie współczynnika MET dla biegu
    private func calculateRunningMET(speed: Double) -> Double {
        // Wzór przybliżony na podstawie badań
        return 0.2 * speed + 1.8
    }
    
    // Obliczanie współczynnika MET dla chodu
    private func calculateWalkingMET(speed: Double) -> Double {
        // Wzór przybliżony na podstawie badań
        return 0.1 * speed + 2.0
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
