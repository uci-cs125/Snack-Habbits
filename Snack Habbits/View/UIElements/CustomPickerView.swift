//
//  CustomPickerView.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/30/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

class CustomPickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate
{

    
    
    public var data: [String]? {
        didSet {
            super.delegate = self
            super.dataSource = self
            self.reloadAllComponents()
        }
    }
    
    public var selectedValue: String {
        get {
            if data != nil {
                let feet    = data![selectedRow(inComponent: 0)]
                let inches  = data![selectedRow(inComponent: 1)]
                return "\(feet) ft \(inches) inches"
            } else {
                return ""
            }
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if data != nil {
            return data!.count
        } else {
            return 0
        }
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if data != nil {
            return data![row]
        } else {
            return ""
        }
    }
}
