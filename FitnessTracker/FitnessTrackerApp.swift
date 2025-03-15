//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by adrian on 15/03/2025.
//

import SwiftUI
import SwiftData

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

@main
struct FitnessTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
