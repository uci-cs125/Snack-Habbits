//
//  SettingsTableViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/18/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

protocol SettingsControllerDelegate {
    func didSaveSettings()
}

class SettingsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return feetList.count
        }else if component == 2 {
            return inchList.count
        }else {
            return 1
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(feetList[row])"
        }else if component == 1 {
            return "ft"
        }else if component == 2 {
            return "\(inchList[row])"
        }else {
            return "in"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let feetIndex = pickerView.selectedRow(inComponent: 0)
        let inchIndex = pickerView.selectedRow(inComponent: 2)
        
    }
    
    
    //MARK:- Properties
    let feetList = Array(3...9)

    let inchList = Array(0...11)
    
    var user: User?
    var delegate: SettingsControllerDelegate?
    var pickerView: UIPickerView?
    var toolBarAccessory: UIToolbar?
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))

    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //a flexible space between the two buttons
    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
    
    //MARK:- UI Elements

    lazy var header: UIView = {
        let header = UIView()
        let padding: CGFloat = 16
        return header
    }()
    
    
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUser()
        setupNavigationBar()
        setupTableView()
        
        
        pickerView = UIPickerView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.pickerView?.delegate = self
        self.pickerView?.dataSource = self
        self.pickerView!.backgroundColor = UIColor.white
        pickerView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        toolBarAccessory = UIToolbar()
        toolBarAccessory?.autoresizingMask = .flexibleHeight
        toolBarAccessory?.barStyle = .default
        toolBarAccessory?.barTintColor = UIColor.red
        toolBarAccessory?.backgroundColor = UIColor.red
        toolBarAccessory?.isTranslucent = false
        toolBarAccessory?.isUserInteractionEnabled = true
        
        var frame = toolBarAccessory?.frame
        frame?.size.height = 44.0
        toolBarAccessory?.frame = frame!
        
        toolBarAccessory?.items = [cancelButton, flexSpace, doneButton]
        
    }
    

    //MARK:- Setup
    private func setupTableView() {
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView() // Removes horizontal lines in table
        tableView.keyboardDismissMode = .interactive // Allows dragging to interact with keyboard
    }
    
    
    private func setupNavigationBar() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        ]
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
        
        tableView.reloadData()
    }
    
    
    
    
    
    
    //MARK:- Action Handlers
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc private func handleDone() {
        let indexPath = IndexPath(row: 0, section: 4)
        
        if let cell = self.tableView.cellForRow(at:indexPath) as? SettingsCell
        {
            
            guard let feet = pickerView?.selectedRow(inComponent: 0) else { return }
            guard let inches = pickerView?.selectedRow(inComponent: 2) else { return }
            cell.textField.text = "\(feetList[feet]) feet \(inchList[inches]) inches"
            cell.textField.endEditing(true)
        }
        
        view.endEditing(true)
    }
    
    @objc private func handleSave() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docData: [String: Any] = [
            "uid": uid,
            "fullName": user?.name ?? "",
            "age": user?.age ?? -1,
            "weight": user?.weight ?? 0.0,
            "height": user?.height ?? ""
            
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
        }
        
        dismiss(animated: true, completion:  {
            self.delegate?.didSaveSettings()
        })
    }
    
    
    @objc private func handleLogout() {
        try? Auth.auth().signOut()
        dismiss(animated: true)
    }
    
    
    @objc private func handleNameChanged(textField: UITextField){
        user?.name = textField.text
    }
    
    
    @objc private func handleAgeChanged(textField: UITextField){
        if let newAge = Int(textField.text ?? "") {
             user?.age = newAge
        }
    }
    
    @objc private func handleWeightChanged(textField: UITextField){
        if let newWeight = Float(textField.text ?? "") {
             user?.weight = newWeight
        }
    }
    
    @objc private func handleHeightChanged(textField: UITextField){
        print("height changed")
            user?.height = textField.text
    }
    
    
    
    //MARK:- TableView Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        cell.textField.delegate = self

        cell.textField.returnKeyType = UIReturnKeyType.done
        switch indexPath.section {
        case 0:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChanged), for: .editingChanged)
        case 1:
            
            cell.textField.placeholder = "Enter Age"
            if let age = user?.age {
                cell.textField.text = String(age)
            }
            cell.textField.keyboardType = .asciiCapableNumberPad
            cell.textField.addTarget(self, action: #selector(handleAgeChanged), for: .editingChanged)
        case 2:
            
            cell.textField.placeholder = "Enter Gender"
            //cell.textField.addTarget(self, action: #selector(handleAgeChanged), for: .editingChanged)
        case 3:
            
            cell.textField.placeholder = "Enter Weight"
            cell.textField.keyboardType = .decimalPad
            cell.textField.text = String(user?.weight?.description ?? "-")
            cell.textField.addTarget(self, action: #selector(handleWeightChanged), for: .editingChanged)
        case 4:
           
            cell.textField.placeholder = "Enter Height"
            cell.textField.inputView = pickerView
            cell.textField.inputAccessoryView = toolBarAccessory
            cell.textField.text = user?.height ?? ""
            cell.textField.addTarget(self, action: #selector(handleHeightChanged), for: .editingDidEnd)
        default:
            cell.textField.placeholder = "Enter Bio"
        }
        
        return cell
    }
    
    
    
    
    //MARK: Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerLabel = HeaderLabel()
        
        switch section {
        case 0:
            headerLabel.text = "Name"
        case 1:
            headerLabel.text = "Age"
        case 2:
            headerLabel.text = "Gender"
        case 3:
            headerLabel.text = "Weight"
        case 4:
            headerLabel.text = "Height"
        default:
            headerLabel.text = "Name"
        }
        headerLabel.font = .boldSystemFont(ofSize: 16)
        return headerLabel
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//             return 150
//        }
        return 40
    }
    


}


class HeaderLabel: UILabel {
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 16, dy: 0))
    }
}


//MARK:- Text Field Delegate
extension SettingsTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    

}
