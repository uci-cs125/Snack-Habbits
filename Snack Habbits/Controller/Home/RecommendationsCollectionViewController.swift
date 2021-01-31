//
//  RecommendationsCollectionViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/30/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import Firebase

class RecommendationsCollectionViewController: BaseCollectionViewController, LoginControllerDelegate {
    func didFinishLoggingIn() {
        
    }
    

    //MARK:- Properties
    private let recommentationResultCellId = "recommendationCell"
    private var recommendationResults = [Result]()
    private var user: User?
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        //setupNavigationController()
        
        let settingsbutton = UIBarButtonItem(image:  #imageLiteral(resourceName: "top_left_profile"), style: .plain, target: self, action: #selector(handleSettingsButtonTapped))
        settingsbutton.tintColor = .gray
        self.navigationItem.leftBarButtonItem = settingsbutton
        APIService.shared.fetchMeals(searchTerm: "random") { (results, error) in
            
            if let error = error {
                print("Failed to fetch apps in search page: ", error)
                return
            }
            
            self.recommendationResults = results?.results ?? []
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
        } // END APIService
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
    
    //MARK:- Setup
    private func setupCollectionView() {
        collectionView?.backgroundColor = .white
        collectionView?.register(RecommendationResultCell.self, forCellWithReuseIdentifier: recommentationResultCellId)
    }
    
    
    
    //MARK:- Collection View Delegate
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recommentationResultCellId, for: indexPath) as! RecommendationResultCell
        let recommendationResult = recommendationResults[indexPath.item]
        cell.result = recommendationResult

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendationResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let appId = String(appResults[indexPath.item].trackId)
//        let resultDetailController = ResultDetailController(appId: appId)
//        navigationController?.pushViewController(appDetailController, animated: true)
    }
    
    
    @objc private func handleSettingsButtonTapped()
    {
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

//MARK:- Collection View Flow Layout Delegate
extension RecommendationsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 32, height: 300)
    }
}

//MARK:- Settings Delegate
extension RecommendationsCollectionViewController: SettingsControllerDelegate {
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
}
