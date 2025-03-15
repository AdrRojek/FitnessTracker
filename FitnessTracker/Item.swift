//
//  Item.swift
//  FitnessTracker
//
//  Created by adrian on 15/03/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

struct TreadmillWorkout: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var totalDuration: TimeInterval // w minutach
    var totalSpeed: Double // km/h
    var runningDuration: TimeInterval // w minutach
    var runningSpeed: Double // km/h
    
    var walkingDuration: TimeInterval {
        totalDuration - runningDuration
    }
    
    var walkingSpeed: Double {
        let totalDistance = (totalDuration / 60) * totalSpeed
        let runningDistance = (runningDuration / 60) * runningSpeed
        let walkingDistance = totalDistance - runningDistance
        return walkingDistance / (walkingDuration / 60)
    }
}
