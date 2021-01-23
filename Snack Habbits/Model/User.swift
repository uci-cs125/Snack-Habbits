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
    var imageUrl1: String?
    var name: String?
    var age: Int?
            
    init(dictionary: [String: Any]) {
        // Initialize user
        self.uid = dictionary["uid"] as? String ?? ""
        self.imageUrl1 = dictionary["imageUrl1"] as? String
        self.name = dictionary["fullName"] as? String ?? ""
        self.age = dictionary["age"] as? Int
    }
    
}
