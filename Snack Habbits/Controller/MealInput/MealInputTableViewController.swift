//
//  MealInputTableViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/14/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

protocol MealInputTableViewControllerDelegate {
    func didSave(meal: Meal)
}


class MealInputTableViewController: UITableViewController {

    var meal:  Meal? {
        didSet {
            updateLabels(with: meal)
        }
    }
    
    var editMeal: Meal?
    var delegate: MealInputTableViewControllerDelegate?
    
    //MARK:- UI Elements
    @IBOutlet weak var mealNameLabel: UITextField!
    @IBOutlet weak var totalCaloriesLabel: UITextField!
    @IBOutlet weak var totalFatLabel: UITextField!
    @IBOutlet weak var totalCarbsLabel: UITextField!
    @IBOutlet weak var totalProteinLabel: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var enabled = false
    //MARK:- Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        saveButton.isEnabled = enabled
        
        mealNameLabel.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        totalCaloriesLabel.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        
        if let eMeal = editMeal {
            self.meal = eMeal
        }
    }


    //MARK:- Action Handlers
    @IBAction func saveButtonTapped(_ sender: Any) {
        var meal = Meal()
        if let name = mealNameLabel.text, !name.isEmpty {
            meal.name = name
        }

        if let calories = totalCaloriesLabel.text, !calories.isEmpty {
            meal.calories = Float(calories)
        }
                        
        if let fat = totalFatLabel.text, !fat.isEmpty {
            meal.fat = Float(fat)
        }
        
        if let carbs = totalCarbsLabel.text, !carbs.isEmpty {
            meal.carbs = Float(carbs)!
        }
        
        if let protein = totalProteinLabel.text, !protein.isEmpty {
            meal.protein = Float(protein)!
        }
        
        delegate?.didSave(meal: meal)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        textField.text = textField.text?.trimmingCharacters(in: .whitespaces)
        guard
            let calories = totalCaloriesLabel.text, !calories.isEmpty,
            let name     = totalCaloriesLabel.text, !name.isEmpty
        else {
            saveButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
    }
    
    // MARK:- TableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
   //MARK:- Helpers
    func updateLabels(with meal: Meal?) {
        if let name = meal?.name {
            mealNameLabel.text =  name
        }
        
        if let calories = meal?.calories {
            totalCaloriesLabel.text = "\(calories)"
        }
        
        if let fat = meal?.fat {
            totalFatLabel.text = "\(fat)"
        }
        
        if let carbs = meal?.carbs {
            totalCarbsLabel.text = "\(carbs)"
        }
        
        if let protein = meal?.protein {
            totalProteinLabel.text = "\(protein)"
        }
    }

    
}


extension MealInputTableViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingsTableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
