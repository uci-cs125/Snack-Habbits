//
//  RegistrationViewModel.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/18/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    var bindableImage         = Bindable<UIImage>()
    var bindableIsFormValid   = Bindable<Bool>()
    var bindableIsRegistering = Bindable<Bool>()
    
    var fullName:   String?  { didSet { checkFormValidity() } }
    var email:      String?  { didSet { checkFormValidity() } }
    var password:   String?  { didSet { checkFormValidity() } }
    
        
    func performRegistration(completion: @escaping (Error?) -> ()){
        guard let email = email, let password = password else { return }
        bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(error)
                return
            }
            self.saveImageToFirebase(completion: completion)
        }
    }
    
    private func saveImageToFirebase(completion: @escaping (Error?)-> ()) {
        let filename = UUID().uuidString
        let reference = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        
        reference.putData(imageData, metadata: nil, completion: { (_, error) in
            if let error = error {
                print("putData Error******\(error)")
                completion(error)
                return
            }
        
            reference.downloadURL(completion: { (url, error) in
                if let error = error {
                    print("downloadURL Error******\(error)")
                    completion(error)
                    return
                }
                self.bindableIsRegistering.value = false
                print("Saving")
                // Store download url into firestore
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFireStore(imageUrl: imageUrl, completion: completion)
            })
        })
        
    }
    
    private func saveInfoToFireStore(imageUrl: String, completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let documentData = ["fullName": fullName ?? "", "uid": uid, "imageUrl1": imageUrl]
        Firestore.firestore().collection("users").document(uid).setData(documentData) { (error) in
            if let error = error {
                print("FireStore Error ******\(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
    
    private func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        bindableIsFormValid.value = isFormValid
    }
    
                
}
