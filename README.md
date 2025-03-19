# Fitness Tracker App

The **Fitness Tracker** app is a comprehensive tool designed to help users monitor their daily activity, workouts, and health metrics. With seamless integration with **HealthKit**, it provides real-time data on steps, distance, calories burned, and more. Users can log treadmill workouts, track weight progress, and set personal goals, all within an intuitive and visually appealing interface.

---

## Features

### **Activity Tracking**
- **Steps**: Track daily steps with real-time updates from HealthKit.
- **Distance**: Calculate distance walked or run based on step count and workout data.
- **Calories**: Estimate calories burned from steps and logged workouts.
- **Progress Visualization**: View step progress with a dynamic circular progress bar.

### **Workout Management**
- **Log Workouts**: Add treadmill workouts with details like duration, speed, and distance.
- **Workout History**: View a list of past workouts with detailed summaries.
- **Calories Burned**: Calculate calories burned for each workout based on user profile data.

### **Weight Tracking**
- **Weight Logging**: Record weight measurements over time.
- **Progress Chart**: Visualize weight trends with an interactive line chart.
- **Edit/Delete**: Easily update or remove weight entries.

### **User Profile**
- **Personalization**: Set weight, height, gender, and daily step goals.
- **Dynamic Updates**: Adjust profile details to refine calorie and distance calculations.

### **HealthKit Integration**
- **Step Data**: Fetch and display step count from HealthKit.
- **Authorization**: Request user permission to access HealthKit data.

---

## Technologies Used

- **SwiftUI**: For building a modern and responsive user interface.
- **SwiftData**: For local data persistence and management.
- **HealthKit**: For accessing and integrating health and fitness data.
- **Charts**: For visualizing data with interactive charts.
- **Foundation**: For core functionality and utilities.

---

## Screenshots

<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <img src="https://github.com/user-attachments/assets/57188516-af8a-4542-a00e-c324343cacac" alt="Home Screen" width="23%" />
  <img src="https://github.com/user-attachments/assets/ba1db683-2882-44d3-96d4-879708e5c9cd" alt="Workout Log" width="23%" />
  <img src="https://github.com/user-attachments/assets/43c53e23-bd2f-47b7-8dd2-ba48633d3476" alt="Weight Progress" width="23%" />
  <img src="https://github.com/user-attachments/assets/c71dd098-80d1-4d20-a48f-79beffa96355" alt="Profile" width="23%" />
</div>

---

## Getting Started

To run the **Fitness Tracker** app locally, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/adrrojek/FitnessTracker.git
   ```
2. **Open the Project**:
   - Open the project in Xcode.
3. **Configure HealthKit**:
   - Enable HealthKit capabilities in the Xcode project settings.
   - Update the `Info.plist` file with the necessary HealthKit permissions.
4. **Build and Run**:
   - Build the project and run it on your iOS device or simulator.

---

## Code Overview

### **HealthKit Integration**
The app uses `HealthKitManager` to request authorization and fetch step data from HealthKit. It calculates distance and calories burned based on the user's step count and profile data.

```swift
class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var steps: Int = 0
    
    func requestAuthorization() {
        let stepType = HKQuantityType(.stepCount)
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
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
}
```

### **Workout Logging**
Users can log treadmill workouts with details like duration, speed, and distance. The app calculates calories burned based on the user's profile.

```swift
struct TreadmillWorkout {
    var date: Date
    var totalDuration: Double
    var walkingSpeed: Double
    var runningDuration: Double
    var runningSpeed: Double
    
    func calculateCaloriesBurned(userProfile: UserProfile) -> Double {
        // Calorie calculation logic
    }
}
```

### **Weight Tracking**
Weight measurements are logged and displayed in a chart. Users can edit or delete entries.

```swift
struct WeightMeasurement {
    var date: Date
    var weight: Double
}
```

---

## Contributing

We welcome contributions! If you'd like to contribute to the **Fitness Tracker** project, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Commit your changes.
4. Push your branch and open a pull request.

---

## Contact

If you have any questions or feedback, feel free to reach out:

- **Email**: adr.rojek@gmail.com
- **GitHub Issues**: [Open an Issue](https://github.com/adrrojek/FitnessTracker/issues)

---

Stay active and track your progress with the **Fitness Tracker** app! 🏃‍♂️📊
