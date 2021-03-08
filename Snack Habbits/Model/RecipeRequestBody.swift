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
    var dailySteps: Float
    var currHour: Int
    
    init(meals: [Meal], dailySteps: Float, currHour: Int){
        self.mealsEaten = meals
        self.dailySteps = dailySteps
        self.currHour = currHour
    }
}

struct CalorieRequestBody: Codable {
    var profile: User
    
    init(user: User){
        self.profile = user
    }
}
