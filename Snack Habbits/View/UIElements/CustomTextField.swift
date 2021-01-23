//
//  CustomTextField.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/17/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    let padding: CGFloat
    let height:  Int
    let cornerRadius: CGFloat
    
    init(padding: CGFloat, placeholder: String, height: Int, cornerRadius: CGFloat ) {
        
        self.padding      = padding
        self.height       = height
        self.cornerRadius = cornerRadius
        
        super.init(frame: .zero)
        
        layer.cornerRadius  = cornerRadius
        backgroundColor     = .white
        textColor           = .black
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: height)
    }
}
