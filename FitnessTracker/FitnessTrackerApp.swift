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
    
    // Obliczanie przebytego dystansu w kilometrach
    var totalDistance: Double {
        (totalDuration / 60) * totalSpeed
    }
    
    // Obliczanie dystansu biegu w kilometrach
    var runningDistance: Double {
        (runningDuration / 60) * runningSpeed
    }
    
    // Obliczanie dystansu chodu w kilometrach
    var walkingDistance: Double {
        totalDistance - runningDistance
    }
    
    // Szacowanie spalonych kalorii (przykładowy wzór)
    var caloriesBurned: Double {
        let runningCalories = runningDuration * 10 // 10 kalorii na minutę biegu
        let walkingCalories = walkingDuration * 5 // 5 kalorii na minutę chodu
        return runningCalories + walkingCalories
    }
    
    // Obliczanie średniej prędkości biegu
    var averageRunningSpeed: Double {
        runningSpeed
    }
    
    // Obliczanie średniej prędkości chodu
    var walkingSpeed: Double {
        if walkingDuration > 0 {
            return (walkingDistance / (walkingDuration / 60))
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
