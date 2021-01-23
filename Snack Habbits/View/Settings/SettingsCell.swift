//
//  SettingsCell.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/18/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {

    let textField = CustomTextField(padding: 24, placeholder: "Enter Name", height: 44, cornerRadius: 0)
    
    //MARK:- Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textField)
        textField.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

