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
}
