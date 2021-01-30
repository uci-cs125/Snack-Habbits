//
//  Recommendation.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/30/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import Foundation

struct SearchResult: Decodable {
    let results: [Result]
    
    
    enum CodingKeys: String, CodingKey {
        case results = "meals"
    }
}


struct Result: Decodable {
    let name:           String
    let mealNumber:     String

    
    enum CodingKeys: String, CodingKey {
        case name           = "strMeal"
        case mealNumber     = "idMeal"
    }

    
}

 
