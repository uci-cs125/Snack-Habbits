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
    private var meals = [Meal]()
    let dispatchQueue = DispatchQueue(label: "myQueue", qos: .background)
    let semaphore = DispatchSemaphore(value: 0)
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.color = .black
        aiv.startAnimating()
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        collectionView?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        fetchRecipes()
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
    
    //MARK:- Setup
    private func setupActivityIndicator() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.fillSuperview()
    }
    
    //MARK:- API Service
    fileprivate func fetchRecipes() {
        
        let date = Helper.getDate()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        dispatchQueue.async {
            self.fetchCurrentUser(with: uid)
            self.semaphore.wait()
            self.fetchUserMeals(with: uid)
            self.semaphore.wait()
            self.fetchRecommendations()
        }

    }
    

    
    //MARK:- Firestore
    private func fetchCurrentUser(with uid: String){
        Firestore.firestore().collection("users").document(uid).getDocument { (documentSnapshot, error) in
            if let error = error {
                self.semaphore.signal()
                print("Error fetching current User:", error)
                return
            }
            
            guard let dictionary = documentSnapshot?.data() else {
                self.semaphore.signal()
                return
            }
            
            self.user = User(dictionary: dictionary)
            self.semaphore.signal()
        } // END Get User

    }
    
    private func fetchUserMeals(with uid: String){
        let date = Helper.getDate()
        Firestore.firestore().collection("meals").document(uid).getDocument { (documentSnapshot, error) in
            print("Fetching meals")
            
            if let error = error {
                self.semaphore.signal()
                print("****Error fetching users meals:", error)
                return
            }
            
            guard let dictionary = documentSnapshot?.data() else {
                self.semaphore.signal()
                return
                
            }
            // Make sure meals actually exists for the date
            guard let _ = dictionary[date] else { return }
            let mealDict = dictionary[date]! as! [Any]
                            
            for meal in mealDict {
                if let data = try? JSONSerialization.data(withJSONObject: meal, options: []){
                    if let parsedMeal = try? JSONDecoder().decode(Meal.self, from: data) {
                        self.meals.append(parsedMeal)
                    }
                }
                    
            }
            self.semaphore.signal()
 
        } // END get Meals
    }
    
    func fetchRecommendations() {
        var context = Context(meals: self.meals, caloriesBurned: 1000.0, currHour: Helper.getCalendarHour())
        guard let currentUser = user else { return }
        var recipeRequest = RecipeRequestBody(user: currentUser, context: context)
        
        APIService.shared.fetchMeals(recipeRequestBody: recipeRequest) { (results, error) in
            if let error = error {
                print("Failed to fetch recipes", error)
                return
            }

            self.recommendationResults = results?.results ?? []
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.collectionView?.reloadData() 
            }

        } // END get Recipes
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        fetchCurrentUser(with: uid)
        fetchUserMeals(with: uid)
    }
}
