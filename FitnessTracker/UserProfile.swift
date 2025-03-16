import SwiftUI
import SwiftData

@Model
class UserProfile {
    var weight: Double // w kg
    var height: Double // w cm
    var gender: Gender
    
    enum Gender: String, Codable {
        case male
        case female
        case other
    }
    
    init(weight: Double = 70, height: Double = 175, gender: Gender = .male) {
        self.weight = weight
        self.height = height
        self.gender = gender
    }
} 