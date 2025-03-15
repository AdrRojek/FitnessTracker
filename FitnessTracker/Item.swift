//
//  Item.swift
//  FitnessTracker
//
//  Created by adrian on 15/03/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
