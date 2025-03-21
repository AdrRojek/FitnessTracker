import SwiftUI
import SwiftData
import Charts
import Foundation
import HealthKit

func formatMinutes(_ minutes: Double) -> String {
    let totalSeconds = Int(minutes * 60)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var steps: Int = 0
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        let stepType = HKQuantityType(.stepCount)
        let typesToRead: Set<HKObjectType> = [stepType]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                self.fetchSteps()
            }
        }
    }
    
    func fetchSteps() {
        let stepType = HKQuantityType(.stepCount)
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
            guard let statistics = statistics, let sum = statistics.sumQuantity() else { return }
            
            DispatchQueue.main.async {
                self.steps = Int(sum.doubleValue(for: .count()))
            }
        }
        
        healthStore.execute(query)
    }
    
    func calculateStepsDistance() -> Double {
        return Double(steps) * 0.762 / 1000
    }
    
    func calculateStepsCalories(weight: Double, height: Double) -> Double {
        let totalDistanceMeters = Double(steps) * 0.762
        let walkingTimeMinutes = totalDistanceMeters / 80.0
        let met = 3.0
        return (met * 3.5 * weight * walkingTimeMinutes) / 200.0
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var workouts: [TreadmillWorkout]
    @Query private var userProfiles: [UserProfile]
    @Query private var weightMeasurements: [WeightMeasurement]
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var showingAddWorkout = false
    @State private var selectedWorkout: TreadmillWorkout?
    @State private var showingDetailsSheet = false
    @State private var showingProfileSheet = false
    @State private var userProfile = UserProfile(weight: 70, height: 175, gender: .male)
    
    private var sortedWorkouts: [TreadmillWorkout] {
        workouts.sorted(by: { $0.date > $1.date })
    }
    
    private var todaysWorkouts: [TreadmillWorkout] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return workouts.filter { calendar.startOfDay(for: $0.date) == today }
    }
    
    private var todaysTotalDistance: Double {
        todaysWorkouts.reduce(0) { $0 + $1.totalDistance }
    }
    
    private var todaysTotalCalories: Double {
        todaysWorkouts.reduce(0) { $0 + $1.calculateCaloriesBurned(userProfile: userProfile) }
    }

    var body: some View {
        TabView {
            NavigationView {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 20)
                            .opacity(0.3)
                            .foregroundColor(.gray)
                        
                        Circle()
                            .trim(from: 0.0, to: min(CGFloat(healthKitManager.steps) / CGFloat(userProfile.dailyStepsGoal), 1.0))
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .fill(
                                AngularGradient(
                                    gradient: Gradient(colors: [.blue, .purple, .blue]),
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(360)
                                )
                            )
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.linear, value: healthKitManager.steps)
                        
                        VStack {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text("\(healthKitManager.steps)")
                                .font(.system(size: 40, weight: .bold))
                            Text("steps today")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 250, height: 250)
                    .padding()
                    
                    VStack(spacing: 15) {
                        HStack(spacing: 20) {
                            VStack {
                                Text(String(format: "%.2f km", healthKitManager.calculateStepsDistance()))
                                    .font(.system(size: 20, weight: .bold))
                                Text("Distance (steps)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.1))
                            )
                            
                            VStack {
                                Text(String(format: "%.2f km", healthKitManager.calculateStepsDistance() + todaysTotalDistance))
                                    .font(.system(size: 20, weight: .bold))
                                Text("Distance (total)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text(String(format: "%.0f kcal", healthKitManager.calculateStepsCalories(weight: userProfile.weight, height: userProfile.height)))
                                    .font(.system(size: 20, weight: .bold))
                                Text("Calories (steps)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.1))
                            )
                            
                            VStack {
                                Text(String(format: "%.0f kcal", healthKitManager.calculateStepsCalories(weight: userProfile.weight, height: userProfile.height) + todaysTotalCalories))
                                    .font(.system(size: 20, weight: .bold))
                                Text("Calories (total)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    if !sortedWorkouts.isEmpty {
                        VStack(spacing: 8) {
                            Text("Recent Workouts")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ForEach(Array(sortedWorkouts.prefix(3))) { workout in
                                HStack {
                                    Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(String(format: "%.1f km", workout.totalDistance))
                                        .font(.caption)
                                    Text(String(format: "%.0f kcal", workout.calculateCaloriesBurned(userProfile: userProfile)))
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.1))
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
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
            }
            .sheet(isPresented: $showingAddWorkout) {
                WorkoutForm()
            }
            .sheet(isPresented: $showingDetailsSheet) {
                if let workout = selectedWorkout {
                    WorkoutDetails(workout: workout, userProfile: userProfile)
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
    @Environment(\.modelContext) private var modelContext

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
                
                Section {
                    Button(action: {
                        modelContext.delete(workout)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete workout")
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
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
                ToolbarItem(placement: .destructiveAction) {
                    Button(action: {
                        modelContext.delete(workout)
                        dismiss()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
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
    @State private var isEditing = false
    @State private var editedProfile: UserProfile?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        Text(String(format: "%.1f kg", profile.weight))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } header: {
                    HStack {
                        Spacer()
                        Text("Weight")
                        Spacer()
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        if isEditing {
                            TextField("Height (cm)", value: $profile.height, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 150)
                        } else {
                            Text(String(format: "%.1f cm", profile.height))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                } header: {
                    HStack {
                        Spacer()
                        Text("Height")
                        Spacer()
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        if isEditing {
                            Picker("Gender", selection: $profile.gender) {
                                Text("Male").tag(UserProfile.Gender.male)
                                Text("Female").tag(UserProfile.Gender.female)
                            }
                            .frame(width: 150)
                        } else {
                            Text(profile.gender == .male ? "Male" : "Female")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                } header: {
                    HStack {
                        Spacer()
                        Text("Gender")
                        Spacer()
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        if isEditing {
                            TextField("Daily Steps Goal", value: $profile.dailyStepsGoal, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 150)
                        } else {
                            Text("\(profile.dailyStepsGoal) steps")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                } header: {
                    HStack {
                        Spacer()
                        Text("Daily Steps Goal")
                        Spacer()
                    }
                }
            }
            .navigationTitle("User Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            modelContext.insert(profile)
                            print("Profile saved: \(profile.weight) kg, \(profile.height) cm, \(profile.gender), goal: \(profile.dailyStepsGoal) steps")
                        }
                        isEditing.toggle()
                    }
                }
                if isEditing {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            if let savedProfile = editedProfile {
                                profile = savedProfile
                            }
                            isEditing = false
                        }
                    }
                }
            }
            .onAppear {
                editedProfile = profile
            }
        }
        .environment(\.modelContext, modelContext)
        .frame(maxWidth: 400)
        .frame(maxWidth: .infinity)
    }
}

struct WeightProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var measurements: [WeightMeasurement]
    @Query private var userProfiles: [UserProfile]
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
        .popover(isPresented: $showingEditSheet, attachmentAnchor: .point(.trailing)) {
            if let measurement = selectedMeasurement {
                VStack(spacing: 16) {
                    HStack {
                        Text("Edit Weight")
                            .font(.headline)
                        Spacer()
                        Button {
                            modelContext.delete(measurement)
                            if let profile = userProfiles.first {
                                // Find last weight measurement (excluding the one being deleted)
                                let sortedMeasurements = measurements
                                    .filter { $0.id != measurement.id }
                                    .sorted(by: { $0.date > $1.date })
                                if let lastMeasurement = sortedMeasurements.first {
                                    profile.weight = lastMeasurement.weight
                                }
                            }
                            showingEditSheet = false
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    
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
                            if let profile = userProfiles.first {
                                profile.weight = editedWeight
                            }
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
                                if let profile = userProfiles.first {
                                    profile.weight = newWeight
                                }
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
