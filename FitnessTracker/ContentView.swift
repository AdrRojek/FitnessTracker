//
//  ContentView.swift
//  FitnessTracker
//
//  Created by adrian on 15/03/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var workouts: [TreadmillWorkout] = []
    @State private var showingAddWorkout = false
    @State private var selectedWorkout: TreadmillWorkout?
    @State private var showingEditSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(workouts.sorted(by: { $0.date > $1.date })) { workout in
                    WorkoutRow(workout: workout)
                        .onTapGesture {
                            selectedWorkout = workout
                            showingEditSheet = true
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
            .sheet(isPresented: $showingEditSheet) {
                if let workout = selectedWorkout {
                    WorkoutForm(workouts: $workouts, editingWorkout: workout)
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
                Text("Total: \(Int(workout.totalDuration))min")
                Spacer()
                Text(String(format: "%.1f km/h", workout.totalSpeed))
            }
            HStack {
                Text("Running: \(Int(workout.runningDuration))min")
                Spacer()
                Text(String(format: "%.1f km/h", workout.runningSpeed))
            }
            HStack {
                Text("Walking: \(Int(workout.walkingDuration))min")
                Spacer()
                Text(String(format: "%.1f km/h", workout.walkingSpeed))
            }
        }
        .padding(.vertical, 8)
    }
}

struct WorkoutForm: View {
    @Binding var workouts: [TreadmillWorkout]
    @Environment(\.dismiss) var dismiss
    var editingWorkout: TreadmillWorkout?
    
    @State private var totalDuration: Double = 0
    @State private var totalSpeed: Double = 0
    @State private var runningDuration: Double = 0
    @State private var runningSpeed: Double = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Total Workout")) {
                    HStack {
                        Text("Duration (minutes)")
                        Spacer()
                        TextField("Duration", value: $totalDuration, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Speed (km/h)")
                        Spacer()
                        TextField("Speed", value: $totalSpeed, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Running")) {
                    HStack {
                        Text("Duration (minutes)")
                        Spacer()
                        TextField("Duration", value: $runningDuration, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Speed (km/h)")
                        Spacer()
                        TextField("Speed", value: $runningSpeed, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section {
                    Button("Save") {
                        let workout = TreadmillWorkout(
                            date: editingWorkout?.date ?? Date(),
                            totalDuration: totalDuration,
                            totalSpeed: totalSpeed,
                            runningDuration: runningDuration,
                            runningSpeed: runningSpeed
                        )
                        
                        if let index = workouts.firstIndex(where: { $0.id == editingWorkout?.id }) {
                            workouts[index] = workout
                        } else {
                            workouts.append(workout)
                        }
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .navigationTitle(editingWorkout == nil ? "New Workout" : "Edit Workout")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let workout = editingWorkout {
                    totalDuration = workout.totalDuration
                    totalSpeed = workout.totalSpeed
                    runningDuration = workout.runningDuration
                    runningSpeed = workout.runningSpeed
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
