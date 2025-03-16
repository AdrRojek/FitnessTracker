import SwiftUI
import SwiftData
import Charts

func formatMinutes(_ minutes: Double) -> String {
    let totalSeconds = Int(minutes * 60)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
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
    @State private var showingProfileSheet = false
    @State private var userProfile = UserProfile(weight: 70, height: 175, gender: .male)
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
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
                    WorkoutForm(workouts: $workouts)
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
        VStack {
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
                        Text(measurement.date.formatted(date: .abbreviated, time: .shortened))
                        Spacer()
                        Text(String(format: "%.1f kg", measurement.weight))
                        Button(action: {
                            selectedMeasurement = measurement
                            editedWeight = measurement.weight
                            showingEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                        }
                        Button(action: {
                            modelContext.delete(measurement)
                        }) {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Weight Progress")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddWeight = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .popover(isPresented: $showingAddWeight) {
            NavigationView {
                Form {
                    Section(header: Text("New Weight")) {
                        TextField("Weight (kg)", value: $newWeight, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
                .navigationTitle("Add Weight")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let measurement = WeightMeasurement(weight: newWeight)
                            modelContext.insert(measurement)
                            showingAddWeight = false
                            newWeight = 0
                            isAnimating = true
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingAddWeight = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let measurement = selectedMeasurement {
                NavigationView {
                    Form {
                        Section(header: Text("Edit Weight")) {
                            TextField("Weight (kg)", value: $editedWeight, format: .number)
                                .keyboardType(.decimalPad)
                        }
                    }
                    .navigationTitle("Edit Weight")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                measurement.weight = editedWeight
                                showingEditSheet = false
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingEditSheet = false
                            }
                        }
                    }
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
