//
//  UILabel+Init.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 3/7/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

extension UILabel {
    
    convenience init(text: String, font: UIFont, numberOfLines: Int = 1) {
        self.init(frame: .zero)
        self.text = text
        self.font = font
        self.numberOfLines = numberOfLines
    }
    
}
