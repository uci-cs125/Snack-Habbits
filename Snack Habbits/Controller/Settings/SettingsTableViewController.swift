//
//  SettingsTableViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/14/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

protocol SettingsControllerDelegate {
    func didSaveSettings(user: User?)
}

class SettingsTableViewController: UITableViewController {

    //MARK:- Properties
    // Height Picker Data Source
    let feetPickerData = Array(3...9)
    let inchPickerData = Array(0...11)
    let heightPickerCellIndexPath = IndexPath(row: 2, section: 0)
    var isHeightPickerShown: Bool = false {
        didSet{
            heightPickerView.isHidden = !isHeightPickerShown
        }
    }
    
    var user: User?
    var delegate: SettingsControllerDelegate?

    //MARK:- UI Elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var heightPickerView: UIPickerView!

    @IBOutlet weak var activityLevelLabel: UILabel!
    @IBOutlet weak var currentWeightTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var weeklyTargetLabel: UILabel!
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        //fetchCurrentUser()
        updateActivityLevel()
        updateWeeklyTarget()
        updateHeightView()
        
        nameTextField.text = user?.name ?? ""
        if let height = user?.heightFeet, let inches = user?.heightInches {
            heightLabel.text = "\(height) ft \(inches) in"
        }

        if let activityLevel = user?.activityLevel {
            activityLevelLabel.text = activityLevel
        } 
  
        if let currentWeight = user?.weight {
            currentWeightTextField.text = "\(currentWeight)"
        }
        
        if let age = user?.age {
            ageTextField.text = "\(age)"
        }
        
        if let weeklyTarget = user?.weeklyTarget {
            weeklyTargetLabel.text = weeklyTarget
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        guard let user = user else {return}
        if let name = user.name {
            nameTextField.text = name
        }
        
        if let height = user.heightFeet, let inches = user.heightInches {
            heightLabel.text = "\(height) ft \(inches) in"
        }
        
        if let activityLevel = user.activityLevel {
            activityLevelLabel.text = activityLevel
        }
  
        if let currentWeight = user.weight {
            currentWeightTextField.text = "\(currentWeight)"
        }
        
        if let age = user.age {
            ageTextField.text = "\(age)"
        }
        
        if let weeklyTarget = user.weeklyTarget {
            weeklyTargetLabel.text = weeklyTarget
        }
        
        
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Actions
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard var user = user else { return }
        
        user.name = nameTextField.text
        user.weight = Float(currentWeightTextField.text!)
        user.age = Int(ageTextField.text!)
        print("uid: ", uid)
        let docData: [String: Any] = [
            "uid": "123945654",
            "fullName": user.name,
            "age": user.age,
            "weight": user.weight,
            "heightFeet": user.heightFeet,
            "heightInches": user.heightInches,
            "weeklyTarget": user.weeklyTarget,
            "activityLevel": user.activityLevel
        ]

        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving"
        hud.show(in: view)

        Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
            hud.dismiss()
            if let error = error {
                print("Error saving user settings: ", error)
                return
            }
            
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didSaveSettings(user: self.user)
        }
        print("Saved settings:", docData)
        
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        print("Logout")
        try? Auth.auth().signOut()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleTapDismiss(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.transform = .identity
        })
    }
    
    //MARK:- Firebase
    private func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("****Error fetching current User:", error)
                return
            }
            guard let dictionary = documentSnapshot?.data() else { return }
            self.user = User(dictionary: dictionary)
        }
        
       // tableView.reloadData()
    }
    
    //MARK:- Tableview Delegate

    // Hides or shows picker view when selecting height cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (heightPickerCellIndexPath.section, heightPickerCellIndexPath.row):
            if isHeightPickerShown {
                return 216.0
            } else {
                return 0.0
            }
        default:
            return 44.0
        }
    }
   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (heightPickerCellIndexPath.section, heightPickerCellIndexPath.row - 1):
            isHeightPickerShown = !isHeightPickerShown
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            break;
        }
    }
    
    
    func updateActivityLevel() {
        if let activityLevel =  user?.activityLevel {
            activityLevelLabel.text = activityLevel
        }
    }
    
    func updateWeeklyTarget() {
        if let weeklyTarget = user?.weeklyTarget {
            weeklyTargetLabel.text = weeklyTarget
        }
    }
    

    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "SelectActivityLevel":
            let destinationViewController = segue.destination as? SelectActivityLevelTableViewController
            destinationViewController?.delegate = self
            destinationViewController?.selectedActivityLevel = user?.activityLevel
        case "SelectWeeklyTarget":
            let destinationViewController = segue.destination as? SelectWeeklyTargetTableViewController
            destinationViewController?.delegate = self
            destinationViewController?.selectedWeeklyTarget = user?.weeklyTarget
        default:
            break
        }

    }
}

extension SettingsTableViewController: SelectActivityLevelTableViewControllerDelegate {
    func didSelect(activityLevel: String) {
        self.user?.activityLevel = activityLevel
        updateActivityLevel()
    }
    
    
}

extension SettingsTableViewController: SelectWeeklyTargetTableViewControllerDelegate {
    func didSelect(weeklyTarget: String) {
        self.user?.weeklyTarget = weeklyTarget
        updateWeeklyTarget()
    }
}

extension SettingsTableViewController: UIPickerViewDataSource, UIPickerViewDelegate
{
    
    //MARK:- Picker delegate
            
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        switch pickerView.tag {
        case 1:
           return 4
        default:
            return 1
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
        case 1:
            switch component {
            case 0:
                return feetPickerData.count
            case 2:
                return inchPickerData.count
            default:
                return 1
            }
        default:
            return 1
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView.tag {
        
        case 1:
            switch component {
            case 0:
                return "\(feetPickerData[row])"
            case 1:
                return "ft"
            case 2:
                return "\(inchPickerData[row])"
            case 3:
                return "in"
            default:
                return "Default"
            }
            
        default:
            return "Default"
        }
        

    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            user?.heightFeet = feetPickerData[row]
        case 2:
            user?.heightInches = inchPickerData[row]
        default:
            break
        }
        
        updateHeightView()
        
    }
    
    func updateHeightView() {
        if let heightFeet = user?.heightFeet, let heightInches = user?.heightInches {
            heightLabel.text = "\(heightFeet)' \(heightInches)\""
        }
    }
}

// Put this piece of code anywhere you like
extension SettingsTableViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(SettingsTableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
