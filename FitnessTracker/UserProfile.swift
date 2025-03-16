import Foundation

struct UserProfile: Codable {
    var weight: Double // w kg
    var height: Double // w cm
    var gender: Gender
    
    enum Gender: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
} 