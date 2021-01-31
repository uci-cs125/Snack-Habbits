//
//  User.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/18/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import Foundation

import UIKit

struct User {
    
    var uid: String?
    var name: String?
    var age: Int?
    var height: String?
    var weight: Float?
    var gender: String?
    
    init(dictionary: [String: Any]) {
        // Initialize user
        self.uid = dictionary["uid"] as? String ?? ""
        self.name = dictionary["fullName"] as? String ?? ""
        self.age = dictionary["age"] as? Int
        self.height = dictionary["height"] as? String ?? ""
        self.weight = dictionary["weight"] as? Float 
        
        
    }
    
}
