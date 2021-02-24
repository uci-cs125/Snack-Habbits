//
//  User.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/18/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import Foundation

import UIKit

struct User: Codable {
    var uid:            String?
    var name:           String?
    var age:            Int?
    var heightFeet:     Int?
    var heightInches:   Int?
    var weight:         Float?
    var weeklyTarget:   String?
    var activityLevel:  String?
    var gender:         String?
    
    init(dictionary: [String: Any]) {
        // Initialize user
        self.uid            = dictionary["uid"]             as? String ?? ""
        self.name           = dictionary["fullName"]        as? String ?? ""
        self.age            = dictionary["age"]             as? Int
        self.heightFeet     = dictionary["heightFeet"]      as? Int
        self.heightInches   = dictionary["heightInches"]    as? Int
        self.weight         = dictionary["weight"]          as? Float
        self.weeklyTarget   = dictionary["weeklyTarget"]    as? String ?? ""
        self.activityLevel  = dictionary["activityLevel"]   as? String ?? ""
        self.gender         = dictionary["gender"]          as? String ?? ""
    }
    
}
 
