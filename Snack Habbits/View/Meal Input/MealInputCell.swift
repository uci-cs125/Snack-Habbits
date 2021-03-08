//
//  MealInputCell.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 3/7/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import SwipeCellKit

class MealInputCell: SwipeTableViewCell {
    
    //MARK:- Properties
    let nameLabel = UILabel(text: "Meal Name", font: .systemFont(ofSize: 15))
    let calorieLabel = UILabel(text: "500 kcals", font: .systemFont(ofSize: 12))
    
    var meal: Meal! {
        didSet {
            nameLabel.text = meal.name
            calorieLabel.text = String(meal.calories ?? 0.0)
        }
    }
    
    //MARK:- Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Setup
    private func setupLayout() {
        let contentStackView = UIStackView(arrangedSubviews: [nameLabel, calorieLabel])
        contentStackView.axis = .vertical
        contentStackView.distribution = .fillEqually
        contentView.addSubview(contentStackView)
        contentStackView.fillSuperview(padding: .init(top: 8, left: 20, bottom: 8, right: 20))
    }
    
    private func setupProperties() {
 
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

