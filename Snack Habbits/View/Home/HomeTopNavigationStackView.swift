//
//  HomeTopNavigationStackView.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/17/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

class HomeTopNavigationStackView: UIStackView {

    //MARK:- Properties
    let settingsButton  = Helper.createButton(image: #imageLiteral(resourceName: "top_left_profile"))
    let topRightButton  = Helper.createButton(image: #imageLiteral(resourceName: "top_left_profile"))
    let appIcon         = UIImageView(image: #imageLiteral(resourceName: "top_left_profile"))
    
    //MARK:- Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        appIcon.contentMode = .scaleAspectFit
        
        [settingsButton, UIView(), appIcon, UIView(), topRightButton].forEach { (view) in
            addArrangedSubview(view)
        }
        
        // Configures stack view    
        distribution = .equalCentering
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
        
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }

}
