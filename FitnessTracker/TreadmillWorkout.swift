import Foundation

struct TreadmillWorkout: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var totalDuration: Double // w minutach
    var totalSpeed: Double // km/h
    var runningDuration: Double // w minutach
    var runningSpeed: Double // km/h
    
    var walkingDuration: Double {
        totalDuration - runningDuration
    }
} 