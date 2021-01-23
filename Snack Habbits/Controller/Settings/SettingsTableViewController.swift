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

class SettingsTableViewController: UITableViewController {
    
    //MARK:- Properties
    var user: User?
    var delegate: SettingsControllerDelegate?
    
    //MARK:- UI Elements
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))

    lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        
        let padding: CGFloat = 16
        
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier : 0.45).isActive = true
        
        return header
    }()
    
    
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        fetchCurrentUser()
        
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
            self.loadUserPhotos()
            self.tableView.reloadData()
        }
    }
    
    
    private func loadUserPhotos() {
        if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
            // uses this to cache images so we dont re fetch images from internet
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        
        
    }
    
    
    
    
    //MARK:- Action Handlers
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
    
    @objc private func handleSave() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let docData: [String: Any] = [
            "uid": uid,
            "imageUrl1": user?.imageUrl1 ?? "",
            "fullName": user?.name ?? "",
            "age": user?.age ?? -1,
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
    
    
    @objc private func handleSelectPhoto(button: UIButton) {
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }
    
    
    
    
    //MARK:- TableView Delegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = SettingsCell(style: .default, reuseIdentifier: nil)
        
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChanged), for: .editingChanged)
        case 2:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChanged), for: .editingChanged)
        case 3:
            cell.textField.placeholder = "Enter Age"
            if let age = user?.age {
                cell.textField.text = String(age)
            }
            cell.textField.addTarget(self, action: #selector(handleAgeChanged), for: .editingChanged)
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
            return header
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Name"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Name"
        }
        headerLabel.font = .boldSystemFont(ofSize: 16)
        return headerLabel
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
             return 300
        }
        return 40
    }
    
    
    
    //MARK:- Helpers
    private func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select photo", for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }
}



//MARK:- Image Picker Delegate
extension SettingsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
        
        
        let fileName = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(fileName)")
        guard let uploadData = selectedImage?.jpegData(compressionQuality: 0.75) else { return }
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading image"
        hud.show(in: view)
        ref.putData(uploadData, metadata: nil) { (nil, error) in
           
            if let error = error {
                 hud.dismiss()
                print("Failed to upload image to storage", error)
                return
            }
            
            ref.downloadURL(completion: { (url, error) in
                hud.dismiss()
                if let error = error {
                    print("Failed to retrieve donwload url", error)
                    return
                }
                
                if imageButton == self.image1Button {
                    self.user?.imageUrl1 = url?.absoluteString
                } 
                
            })
        }
    }
}

// UI Custom Classes
class CustomImagePickerController: UIImagePickerController {
    var imageButton: UIButton?
}

class HeaderLabel: UILabel {
    override func draw(_ rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 16, dy: 0))
    }
}
