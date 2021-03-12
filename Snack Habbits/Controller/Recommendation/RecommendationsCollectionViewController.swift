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

import HealthKit
class RecommendationsCollectionViewController: UICollectionViewController {

    //MARK:- Properties
    private var recommendationResults = [Result]()
    private var user: User?
    private var meals = [Meal]()
    let dispatchQueue = DispatchQueue(label: "myQueue", qos: .background)
    let semaphore = DispatchSemaphore(value: 0)
    let healthStore = HKHealthStore()
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
       
        
        collectionView?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.title = "Recipes For You"
    }
    override func viewWillAppear(_ animated: Bool) {
//        navigationController?.navigationBar.prefersLargeTitles = true
        super.viewWillAppear(animated)
        if Auth.auth().currentUser == nil {
            authorizeHealthKit()
            let loginController = LoginViewController()
            loginController.delegate = self
            let navController = UINavigationController(rootViewController: loginController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        } else {
            
            getSteps { (steps) in
                self.updateUserSteps(count: steps)
            }
            fetchRecipes()
        }
    }
    
    private func authorizeHealthKit() {
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
              
          guard authorized else {
                
            let baseMessage = "HealthKit Authorization Failed"
                
            if let error = error {
              print("\(baseMessage). Reason: \(error.localizedDescription)")
            } else {
              print(baseMessage)
            }
                
            return
          }
              
          print("HealthKit Successfully Authorized.")
            self.getSteps { (steps) in
                self.updateUserSteps(count: steps)
            }
        }
        
    }
    
    func getSteps(completion: @escaping (Double) -> Void){
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: type,
                                               quantitySamplePredicate: nil,
                                               options: [.cumulativeSum],
                                               anchorDate: startOfDay,
                                               intervalComponents: interval)
        
        
        query.initialResultsHandler = { _, result, error in
                var resultCount = 0.0
                result!.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in

                if let sum = statistics.sumQuantity() {
                    // Get steps (they are of double type)
                    resultCount = sum.doubleValue(for: HKUnit.count())
                } // end if

                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            }
        }
        
        query.statisticsUpdateHandler = {
            query, statistics, statisticsCollection, error in

            // If new statistics are available
            if let sum = statistics?.sumQuantity() {
                let resultCount = sum.doubleValue(for: HKUnit.count())
                // Return
                DispatchQueue.main.async {
                    completion(resultCount)
                }
            } // end if
        }
        
        healthStore.execute(query)
    }
    
    
    //MARK:- Setup
    private func setupActivityIndicator() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.fillSuperview()
        activityIndicatorView.startAnimating()
    }
    
    //MARK:- API Service
    fileprivate func fetchRecipes() {
        setupActivityIndicator()
        let date = Helper.getDate()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        dispatchQueue.async {
            self.fetchCurrentUser(with: uid)
            self.semaphore.wait()
            print("Success Fetched Users")
            self.fetchUserMeals(with: uid)
            self.semaphore.wait()
            print("Success Fetched Meals")
            self.fetchRecommendations()
        }
        print("Success `Fetched Recommendations")
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
            guard let _ = dictionary[date] else {
                self.semaphore.signal()
                return                
            }
            let mealDict = dictionary[date]! as! [Any]
            print("mealDict \(mealDict)")
            for meal in mealDict {
                if let data = try? JSONSerialization.data(withJSONObject: meal, options: []){
                    if let parsedMeal = try? JSONDecoder().decode(Meal.self, from: data) {
                        self.meals.append(parsedMeal)
                    }
                }
                    
            }
            self.semaphore.signal()
            print("Leaving fetch meals")
        } // END get Meals
    }
    
    func fetchRecommendations() {
        
        guard let currentUser = user else { return }        
        var context = Context(meals: self.meals, dailySteps: Float(currentUser.dailySteps!) , currHour: Helper.getCalendarHour())
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
    
    
    func updateUserSteps(count: Double){
        guard let uid = Auth.auth().currentUser?.uid else { return }

         let docData: [String: Any] = [
            "uid": uid,
            "steps": count
        ]

        Firestore.firestore().collection("users").document(uid).setData(docData, merge: true) { (error) in

            if let error = error {
                print("Error saving user settings: ", error)
                return
            }

        }
        print("Saved user steps:", docData)
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


    //MARK:- Health Kit
    
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
        
    }
}

extension RecommendationsCollectionViewController: TodaysMealsDelegate {
    func didSaveNewMeal() {
        print("New Meal Has Been Added")
    }
}
