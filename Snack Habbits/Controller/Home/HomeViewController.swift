//
//  HomeViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/17/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate {

    
    
    //MARK:- Properties
    var lastFetchedUser: User?
    private var user: User?
    
    //MARK: UIElements
    let topStackView        = HomeTopNavigationStackView()
    let blueView            = UIView()
    let buttonsStackView    = HomeBottomControlsStackView()
    
    
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let loginController = LoginViewController()
            loginController.delegate = self
            let navController = UINavigationController(rootViewController: loginController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
        
    }
    
    func didFinishLoggingIn() {
        // Fetch user recomendations 
    }
    
    //MARK:- Setup
    private func setupLayout() {
        
        blueView.backgroundColor  = .lightGray
        view.backgroundColor      = .white
        
        let rootStackView = UIStackView(arrangedSubviews: [topStackView, blueView, buttonsStackView])
        
        view.addSubview(rootStackView)
        rootStackView.axis = .vertical
        rootStackView.frame = .init(x: 0, y: 0, width: 300, height: 200)
        rootStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    
    
    
    //MARK:- Handle Actions
    @objc func handleSettings(){
        let settingsController = SettingsTableViewController()
        let navController = UINavigationController(rootViewController: settingsController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    //MARK:- Firestore
    private func fetchCurrentUser(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("****Error fetching current User:", error)
                return
            }
            guard let dictionary = documentSnapshot?.data() else { return }
            self.user = User(dictionary: dictionary)
        }

    }
    

}


//MARK:- Settings Delegate
extension HomeViewController: SettingsControllerDelegate {
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
}
