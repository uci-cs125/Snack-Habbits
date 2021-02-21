//
//  Recommendations2CollectionViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/14/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import Firebase
//private let reuseIdentifier = "RecommendationCell"


class RecommendationsCollectionViewController: UICollectionViewController {

    //MARK:- Properties
    private var recommendationResults = [Result]()
    private var user: User?
    

    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        fetchRecipes()
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let loginController = LoginViewController()
            loginController.delegate = self
            let navController = UINavigationController(rootViewController: loginController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        } else {
            fetchRecipes()
        }
    }
    
    //MARK:- API Service
    fileprivate func fetchRecipes() {
        print("Hitting API endpoint")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        APIService.shared.fetchMeals(uid: uid) { (results, error) in
            print("Fetching results")
            if let error = error {
                print("Failed to fetch recipes", error)
                return
            }
            
            self.recommendationResults = results?.results ?? []
            DispatchQueue.main.async {
                self.collectionView?.reloadData()            
            }
            
        }
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
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return recommendationResults.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? RecommendationCollectionViewCell {
            customCell.configure(with: recommendationResults[indexPath.row])
            cell = customCell
        }
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRecipe = recommendationResults[indexPath.item]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! RecommendationDetailViewController
        vc.recommendedRecipe = selectedRecipe
        navigationController?.pushViewController(vc, animated: true)
        // TODO: set delegate to observe if user adds food from details or likes / dislikes 
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "SelectSettings":
            let destinationViewController = segue.destination as? SettingsTableViewController
            destinationViewController?.delegate = self
            destinationViewController?.user = user
        default:
            break
        }
    }


}

extension RecommendationsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 160)
    }
}

//MARK:- Settings Delegate
extension RecommendationsCollectionViewController: SettingsControllerDelegate {
    func didSaveSettings(user: User?) {
        self.user = user
    }
        
}

extension RecommendationsCollectionViewController: LoginControllerDelegate {
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
}
