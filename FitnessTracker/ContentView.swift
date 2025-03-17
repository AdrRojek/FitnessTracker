import SwiftUI
import SwiftData
import Charts
import Foundation

func formatMinutes(_ minutes: Double) -> String {
    let totalSeconds = Int(minutes * 60)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var workouts: [TreadmillWorkout]
    @Query private var userProfiles: [UserProfile]
    @State private var showingAddWorkout = false
    @State private var selectedWorkout: TreadmillWorkout?
    @State private var showingDetailsSheet = false
    @State private var showingProfileSheet = false
    @State private var userProfile = UserProfile(weight: 70, height: 175, gender: .male)
    
    private var sortedWorkouts: [TreadmillWorkout] {
        workouts.sorted(by: { $0.date > $1.date })
    }

    var body: some View {
        TabView {
            NavigationView {
                Text("Home Screen")
                    .navigationTitle("Home")
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationView {
            List {
                    ForEach(sortedWorkouts) { workout in
                        WorkoutRow(workout: workout, userProfile: userProfile)
                            .onTapGesture {
                                selectedWorkout = workout
                                showingDetailsSheet = true
                            }
                    }
                }
                .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddWorkout = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddWorkout) {
                    WorkoutForm()
                }
                .sheet(isPresented: $showingDetailsSheet) {
                    if let workout = selectedWorkout {
                        WorkoutDetails(workout: workout, userProfile: userProfile)
                    }
                }
            }
            .tabItem {
                Image(systemName: "figure.run")
                Text("Workouts")
            }
            
            NavigationView {
                WeightProgressView()
            }
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Weight")
            }
            
            NavigationView {
                UserProfileView(profile: $userProfile)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
        }
        .onAppear {
            if let profile = userProfiles.first {
                userProfile = profile
                print("Profile loaded: \(profile.weight) kg, \(profile.height) cm, \(profile.gender)")
            }
        }
    }
}

struct WorkoutRow: View {
    let workout: TreadmillWorkout
    let userProfile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                .font(.headline)
            HStack {
                Text("Total: \(formatMinutes(workout.totalDuration))")
                Spacer()
                Text(String(format: "%.0f kcal", workout.calculateCaloriesBurned(userProfile: userProfile)))
            }
            HStack {
                Text("Running: \(formatMinutes(workout.runningDuration))")
                Spacer()
                Text(String(format: "%.1f km/h", workout.runningSpeed))
            }
            HStack {
                Text("Walking: \(formatMinutes(workout.walkingDuration))")
                Spacer()
                Text(String(format: "%.1f km/h", workout.walkingSpeed))
            }
        }
        .padding(.vertical, 8)
    }
}

struct WorkoutDetails: View {
    let workout: TreadmillWorkout
    let userProfile: UserProfile
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
                        Text(String(format: "%.0f kcal", workout.calculateCaloriesBurned(userProfile: userProfile)))
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
    @Environment(\.modelContext) private var modelContext
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
                        modelContext.insert(workout)
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

struct UserProfileView: View {
    @Binding var profile: UserProfile
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Weight")) {
                    TextField("Weight (kg)", value: $profile.weight, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(
                            Text("\(profile.weight, specifier: "%.1f") kg")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                                .opacity(profile.weight == 0 ? 1 : 0),
                            alignment: .trailing
                        )
                }
                Section(header: Text("Height")) {
                    TextField("Height (cm)", value: $profile.height, format: .number)
                }
                Section(header: Text("Gender")) {
                    Picker("Gender", selection: $profile.gender) {
                        Text("Male").tag(UserProfile.Gender.male)
                        Text("Female").tag(UserProfile.Gender.female)
                        Text("Other").tag(UserProfile.Gender.other)
                    }
                }
            }
            .navigationTitle("User Profile")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        modelContext.insert(profile)
                        print("Profile saved: \(profile.weight) kg, \(profile.height) cm, \(profile.gender)")
                        dismiss()
                    }
                }
            }
        }
        .environment(\.modelContext, modelContext)
    }
}

struct WeightProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var measurements: [WeightMeasurement]
    @State private var showingAddWeight = false
    @State private var newWeight: Double = 0
    @State private var isAnimating = false
    @State private var selectedMeasurement: WeightMeasurement?
    @State private var showingEditSheet = false
    @State private var editedWeight: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Chart {
                ForEach(measurements.sorted(by: { $0.date < $1.date })) { measurement in
                    LineMark(
                        x: .value("Date", measurement.date),
                        y: .value("Weight", measurement.weight)
                    )
                    .foregroundStyle(.blue)
                    
                    PointMark(
                        x: .value("Date", measurement.date),
                        y: .value("Weight", measurement.weight)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 200)
            .padding()
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeIn(duration: 1), value: isAnimating)
            
            List {
                ForEach(measurements.sorted(by: { $0.date > $1.date })) { measurement in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(measurement.date.formatted(date: .abbreviated, time: .shortened))
                            Text(String(format: "%.1f kg", measurement.weight))
                        }
                        Spacer()
                        Button {
                            selectedMeasurement = measurement
                            editedWeight = measurement.weight
                            showingEditSheet = true
                            print("DEBUG: edit button tapped")
                        } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }
            
        }
        .popover(isPresented: $showingEditSheet, attachmentAnchor: .point(.center)) {
            if let measurement = selectedMeasurement {
                VStack(spacing: 16) {
                    Text("Edit Weight")
                        .font(.headline)
                    
                    TextField("Weight (kg)", value: $editedWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        Button("Cancel") {
                            showingEditSheet = false
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Save") {
                            measurement.weight = editedWeight
                            showingEditSheet = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .frame(width: 200, height: 150)
                .presentationCompactAdaptation(.popover)

            }
        }
                .padding()
                .navigationTitle("Weight Progress")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddWeight = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .popover(isPresented: $showingAddWeight, attachmentAnchor: .point(.top)) {
                            VStack(spacing: 16) {
                                Text("New Weight")
                                    .font(.headline)
                                
                                TextField("Weight (kg)", value: $newWeight, format: .number)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                                
                                HStack(spacing: 20) {
                                    Button("Cancel") {
                                        showingAddWeight = false
                                    }
                                    .buttonStyle(.bordered)
                                    
                                    Button("Save") {
                                        let measurement = WeightMeasurement(weight: newWeight)
                                        modelContext.insert(measurement)
                                        showingAddWeight = false
                                        newWeight = 0
                                        isAnimating = true
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                            .padding()
                            .frame(width: 200, height: 150)
                            .presentationCompactAdaptation(.popover)
                        }
                    }
                }
                .onAppear {
                    isAnimating = true
        }
    }
}

#Preview {
    ContentView()
}

