//
//  ContentView.swift
//  FitnessTracker
//
//  Created by adrian on 15/03/2025.
//

import SwiftUI
import SwiftData

// Funkcja pomocnicza do formatowania minut w formacie xx:xx
func formatMinutes(_ minutes: Double) -> String {
    let hours = Int(minutes) / 60
    let mins = Int(minutes) % 60
    return String(format: "%02d:%02d", hours, mins)
}

struct ContentView: View {
    @State private var workouts: [TreadmillWorkout] = [
        TreadmillWorkout(
            date: Date(),
            totalDuration: 45,
            walkingSpeed: 5.0,
            runningDuration: 15,
            runningSpeed: 10.0
        )
    ]
    @State private var showingAddWorkout = false
    @State private var selectedWorkout: TreadmillWorkout?
    @State private var showingDetailsSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(workouts.sorted(by: { $0.date > $1.date })) { workout in
                    WorkoutRow(workout: workout)
                        .onTapGesture {
                            selectedWorkout = workout
                            showingDetailsSheet = true
                        }
                }
            }
            .navigationTitle("Treadmill Workouts")
            .toolbar {
                Button(action: {
                    showingAddWorkout = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddWorkout) {
                WorkoutForm(workouts: $workouts)
            }
            .sheet(isPresented: $showingDetailsSheet) {
                if let workout = selectedWorkout {
                    WorkoutDetails(workout: workout)
                }
            }
        }
    }
}

struct WorkoutRow: View {
    let workout: TreadmillWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                .font(.headline)
            HStack {
                Text("Total: \(formatMinutes(workout.totalDuration))")
                Spacer()
                Text(String(format: "%.1f km/h", workout.averageSpeed))
            }
            HStack {
                Text("Running: \(formatMinutes(workout.runningDuration))")
                Spacer()
                Text(String(format: "%.1f km/h", workout.runningSpeed))
            }
            HStack {
                Text("Walking: \(formatMinutes(workout.walkingDuration))")
            }
        }
        .padding(.vertical, 8)
    }
}

struct WorkoutDetails: View {
    let workout: TreadmillWorkout
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Date")) {
                    Text(workout.date.formatted(date: .long, time: .shortened))
                }
                
                Section(header: Text("Duration")) {
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(formatMinutes(workout.totalDuration))
                    }
                    HStack {
                        Text("Running")
                        Spacer()
                        Text(formatMinutes(workout.runningDuration))
                    }
                    HStack {
                        Text("Walking")
                        Spacer()
                        Text(formatMinutes(workout.walkingDuration))
                    }
                }
                
                Section(header: Text("Distance")) {
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(String(format: "%.2f km", workout.totalDistance))
                    }
                    HStack {
                        Text("Running")
                        Spacer()
                        Text(String(format: "%.2f km", workout.runningDistance))
                    }
                    HStack {
                        Text("Walking")
                        Spacer()
                        Text(String(format: "%.2f km", workout.walkingDistance))
                    }
                }
                
                Section(header: Text("Speed")) {
                    HStack {
                        Text("Average")
                        Spacer()
                        Text(String(format: "%.1f km/h", workout.averageSpeed))
                    }
                    HStack {
                        Text("Running")
                        Spacer()
                        Text(String(format: "%.1f km/h", workout.runningSpeed))
                    }
                    HStack {
                        Text("Walking")
                        Spacer()
                        Text(String(format: "%.1f km/h", workout.walkingSpeed))
                    }
                }
                
                Section(header: Text("Calories")) {
                    HStack {
                        Text("Burned")
                        Spacer()
                        Text(String(format: "%.0f kcal", workout.caloriesBurned))
                    }
                }
            }
            .navigationTitle("Workout Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WorkoutForm: View {
    @Binding var workouts: [TreadmillWorkout]
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDate = Date()
    @State private var totalDuration: Double = 0
    @State private var walkingSpeed: Double = 0
    @State private var runningDuration: Double = 0
    @State private var runningSpeed: Double = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date")) {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Total Workout")) {
                    HStack {
                        Text("Duration (minutes)")
                        Spacer()
                        TextField("Duration", value: $totalDuration, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
                
                Section(header: Text("Walking")) {
                    HStack {
                        Text("Speed (km/h)")
                        Spacer()
                        TextField("Speed", value: $walkingSpeed, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
                
                Section(header: Text("Running")) {
                    HStack {
                        Text("Duration (minutes)")
                        Spacer()
                        TextField("Duration", value: $runningDuration, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    HStack {
                        Text("Speed (km/h)")
                        Spacer()
                        TextField("Speed", value: $runningSpeed, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }
                
                Section {
                    Button(action: {
                        let workout = TreadmillWorkout(
                            date: selectedDate,
                            totalDuration: totalDuration,
                            walkingSpeed: walkingSpeed,
                            runningDuration: runningDuration,
                            runningSpeed: runningSpeed
                        )
                        workouts.append(workout)
                        dismiss()
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("New Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
