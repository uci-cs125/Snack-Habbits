//
//  Helper.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/17/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

class Helper {
    
    //MARK:- Inits
    static func createButton(image: UIImage) -> UIButton{
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        
        return button
    }
    
    static func getDate() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: date)
    }
    
    static func getCalendarHour() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        return hour
    }
    
    static func roundFloat(num: Float) -> Float {

        return Float(String(format: "%.2f", num))!
    }
}
