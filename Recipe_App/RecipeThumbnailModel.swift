//
//  RecipeModel.swift
//  Recipe_App
//
//  Created by Sungwoo Lee on 8/21/24.
//

import Foundation

class RecipeThumbnailModel: Identifiable, Equatable, Hashable {
    var id, name, imageURL: String
    
    init(id: String, name: String, imageURL: String) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
    
    static func == (lhs: RecipeThumbnailModel, rhs: RecipeThumbnailModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

extension RecipeThumbnailModel {
    static let sampleData = [RecipeThumbnailModel(id: "53049", name: "Apam Balik", imageURL: "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg"),
                             RecipeThumbnailModel(id: "2", name: "Recipe 2", imageURL: "url 2"),
                             RecipeThumbnailModel(id: "3", name: "Recipe 3", imageURL: "url 3"),
                             RecipeThumbnailModel(id: "4", name: "Recipe 4", imageURL: "url 4"),
                             RecipeThumbnailModel(id: "5", name: "Recipe 5", imageURL: "url 5"),
                             RecipeThumbnailModel(id: "6", name: "Recipe 6", imageURL: "url 6")]
}
