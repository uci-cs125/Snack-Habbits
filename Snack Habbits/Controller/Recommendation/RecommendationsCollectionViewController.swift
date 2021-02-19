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

class RecommendationsCollectionViewController: UICollectionViewController, LoginControllerDelegate {
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    private var recommendationResults = [Result]()
    private var user: User?
    

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
            print("Logged in user: \(Auth.auth().currentUser?.uid)")
            postMealRating()
        }
    }
    
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
    
    private func postMealRating() {
        

        guard let uid = Auth.auth().currentUser?.uid else { return }
        let mock_recipe_id = Int(715544)
        let url = URL(string: "http://localhost:5000/likes/")!
        let parameters: [String:Any] = [
            "user_id" : "\(uid)",
            "recipe_id": mock_recipe_id
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {
                            print("error", error ?? "Unknown error")
                            return
                }
                guard (200 ... 299) ~= response.statusCode else {
                    print("\(response.statusCode)")
                    print("\(response)")
                    return
                }
                let responseString = String(data: data, encoding: .utf8)
                print("\(responseString)")
            }.resume()
     
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
                
        
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate
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
