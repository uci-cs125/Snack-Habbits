//
//  RecommendationResultCell.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/30/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

class RecommendationResultCell: UICollectionViewCell {
    
    var result: Result! {
        didSet{
            nameLabel.text          = result.name
            mealNumberLabel.text    = result.mealNumber
        }
    }
    
    let nameLabel: UILabel = {
        let label   = UILabel()
        label.text  = "Food Name"
        return label
    }()
    
    let mealNumberLabel: UILabel = {
        let label   = UILabel()
        label.text  = "560"
        return label
    }()
    
    //MARK:- Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCellLayout()
        
        backgroundColor = .lightGray
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK:- Setup
    private func setupCellLayout(){
        let rootStackView = UIStackView(arrangedSubviews: [nameLabel, UIView(), mealNumberLabel])
        rootStackView.axis = .horizontal
        addSubview(rootStackView)
        rootStackView.fillSuperview(padding: .init(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    
}
