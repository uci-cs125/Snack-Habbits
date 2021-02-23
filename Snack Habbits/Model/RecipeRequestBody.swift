//
//  RecipeRequestBody.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/22/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import Foundation

struct RecipeRequestBody: Codable {
    var profile: User
    var context: Context
    
    init(user: User, context: Context){
        self.profile = user
        self.context = context
    }
}

struct Context: Codable {
    var mealsEaten: [Meal]
    var caloriesBurned: Float
    var currHour: Int
    
    init(meals: [Meal], caloriesBurned: Float, currHour: Int){
        self.mealsEaten = meals
        self.caloriesBurned = caloriesBurned
        self.currHour = currHour
    }
}

