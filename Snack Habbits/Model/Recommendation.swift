//
//  Recommendation.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/30/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import Foundation

struct SearchResult: Decodable {
    let number: Int
    let results: [Result]
}


struct Result: Decodable {
    let id:                 Int32
    let image:              String
    let title:              String
    let nutrition:          Nutrition
    let vegetarian:         Bool
    let vegan:              Bool
    let glutenFree:         Bool
    let dairyFree:          Bool
    let sustainable:        Bool
    let cheap:              Bool
    let veryHealthy:        Bool
    let aggregateLikes:     Int32
    let cuisines:           [String]
    let dishTypes:          [String]
    let diets:              [String]
    let nutritionalScore:   Float
    let tasteScore:         Float
}

struct Nutrition: Decodable {
    let nutrients: [Nutrient]
}

struct Nutrient: Decodable {
    let name: String
    let amount: Double
    let unit: String
}

 
