//
//  IngredientModel.swift
//  Recipe_App
//
//  Created by Sungwoo Lee on 8/21/24.
//

import Foundation

class IngredientModel: CustomStringConvertible, Identifiable {
    var name, measurement: String
    
    init(name: String, measurement: String) {
        self.name = name
        self.measurement = measurement
    }
    
    // Conforming to CustomStringConvertible
    var description: String {
        return "\(name): \(measurement)"
    }
}
