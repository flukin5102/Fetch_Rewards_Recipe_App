//
//  RecipeModel.swift
//  Recipe_App
//
//  Created by Sungwoo Lee on 8/21/24.
//

import Foundation

class RecipeModel: RecipeThumbnailModel {
    var ingredients: [IngredientModel]
    var instructions: String
    
    init(recipeThumbnail: RecipeThumbnailModel, ingredients: [IngredientModel], instructions: String) {
        self.ingredients = ingredients
        self.instructions = instructions
        super.init(id: recipeThumbnail.id, name: recipeThumbnail.name, imageURL: recipeThumbnail.imageURL)
    }
}
