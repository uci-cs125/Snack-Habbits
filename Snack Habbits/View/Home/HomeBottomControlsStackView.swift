//
//  HomeBottomControlsStackView.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/17/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

class HomeBottomControlsStackView: UIStackView {
    //MARK:- Properties
    let button1 = Helper.createButton(image: #imageLiteral(resourceName: "like_circle"))
    let button2 = Helper.createButton(image: #imageLiteral(resourceName: "like_circle"))
    let button3 = Helper.createButton(image: #imageLiteral(resourceName: "like_circle"))
    let button4 = Helper.createButton(image: #imageLiteral(resourceName: "like_circle"))
    let button5 = Helper.createButton(image: #imageLiteral(resourceName: "like_circle"))
    
    //MARK:- Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [button1, button2, button3, button4, button5].forEach { (button) in
            self.addArrangedSubview(button)
        }
        
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 100).isActive = true
      
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
