import Foundation
import SwiftData

@Model
final class UserProfile {
    var weight: Double // w kg
    var height: Double // w cm
    var gender: Gender
    var dailyStepsGoal: Int
    
    enum Gender: String, Codable {
        case male
        case female
        case other
    }
    
    init(weight: Double = 70, height: Double = 175, gender: Gender = .male, dailyStepsGoal: Int = 10000) {
        self.weight = weight
        self.height = height
        self.gender = gender
        self.dailyStepsGoal = dailyStepsGoal
    }
}

@Model
final class WeightMeasurement {
    var date: Date
    var weight: Double
    
    init(date: Date = Date(), weight: Double) {
        self.date = date
        self.weight = weight
    }
}

@Model
final class TreadmillWorkout {
    var date: Date
    var totalDuration: Double
    var walkingSpeed: Double
    var runningDuration: Double
    var runningSpeed: Double
    
    var walkingDuration: Double {
        return totalDuration - runningDuration
    }
    
    var runningDistance: Double {
        return (runningSpeed * runningDuration) / 60
    }
    
    var walkingDistance: Double {
        return (walkingSpeed * walkingDuration) / 60
    }
    
    var totalDistance: Double {
        return runningDistance + walkingDistance
    }
    
    var averageSpeed: Double {
        return totalDistance / (totalDuration / 60)
    }
    
    init(date: Date = Date(), totalDuration: Double, walkingSpeed: Double, runningDuration: Double, runningSpeed: Double) {
        self.date = date
        self.totalDuration = totalDuration
        self.walkingSpeed = walkingSpeed
        self.runningDuration = runningDuration
        self.runningSpeed = runningSpeed
    }
    
    func calculateCaloriesBurned(userProfile: UserProfile) -> Double {
        let walkingMET = calculateWalkingMET(speed: walkingSpeed)
        let runningMET = calculateRunningMET(speed: runningSpeed)
        
        let walkingCalories = (walkingMET * 3.5 * userProfile.weight * walkingDuration) / (200.0)
        let runningCalories = (runningMET * 3.5 * userProfile.weight * runningDuration) / (200.0)
        
        return walkingCalories + runningCalories
    }
    
    private func calculateWalkingMET(speed: Double) -> Double {
        switch speed {
        case 0..<3.2: return 2.0
        case 3.2..<4.0: return 2.5
        case 4.0..<4.8: return 3.0
        case 4.8..<5.6: return 3.5
        case 5.6..<6.4: return 4.0
        default: return 4.5
        }
    }
    
    private func calculateRunningMET(speed: Double) -> Double {
        switch speed {
        case 0..<8.0: return 8.0
        case 8.0..<8.4: return 9.0
        case 8.4..<9.7: return 10.0
        case 9.7..<10.8: return 11.0
        case 10.8..<11.3: return 11.5
        case 11.3..<12.1: return 12.5
        case 12.1..<12.9: return 13.5
        case 12.9..<13.8: return 14.0
        case 13.8..<14.5: return 15.0
        case 14.5..<16.1: return 16.0
        default: return 18.0
        }
    }
} 
