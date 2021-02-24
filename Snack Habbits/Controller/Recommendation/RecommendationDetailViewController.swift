//
//  RecommendationDetailViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/20/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class RecommendationDetailViewController: UIViewController {

    var recommendedRecipe: Result?
    var meals = [Meal]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var fatDaily: UILabel!
    @IBOutlet weak var saturatedFatLabel: UILabel!
    @IBOutlet weak var cholesterolLabel: UILabel!
    @IBOutlet weak var cholesterolDaily: UILabel!
    @IBOutlet weak var sodiumLabel: UILabel!
    @IBOutlet weak var sodiumDaily: UILabel!
    @IBOutlet weak var carbLabel: UILabel!
    @IBOutlet weak var carbDaily: UILabel!
    @IBOutlet weak var fiberLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var proteinDaily: UIStackView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchUserMeals()
    }
    
    @IBAction func addToMealTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Meal Added", message: "Please rate the meal so we can recommend similar meals to you", preferredStyle: .actionSheet)
        
        let loveAction = UIAlertAction(title: "Loved the meal", style: .default, handler: { action in
            self.postMealRating()
            self.saveMealToFirestore()
        })
        
        let dislikeAction = UIAlertAction(title: "Wasn't my favorite", style: .default, handler: {action in
            self.saveMealToFirestore()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(loveAction)
        ac.addAction(dislikeAction)
        ac.addAction(cancelAction)
        
        self.present(ac, animated: true, completion: nil)
    }
    

    @IBAction func recipeLinkClicked(_ sender: UIButton) {
        guard let recipe = recommendedRecipe else { return }
        if let url = URL(string: recipe.sourceUrl){
            UIApplication.shared.open(url)
        }
    }
    
    private func setupUI(){

        guard let recipe = recommendedRecipe else { return }
        recipeImage.layer.cornerRadius = 12
        recipeImage.layer.masksToBounds = true
        titleLabel.text = recipe.title
        let imageUrl = URL(string: recipe.image)
        recipeImage.sd_setImage(with:imageUrl)
        guard let recommendedRecipe = recommendedRecipe else { return }
        for nutrient in recommendedRecipe.nutrition.nutrients {
            switch nutrient.name {
            case "Calories":
                calorieLabel.text = "\(nutrient.amount) CALORIES PER SERVING)"
            case "Fat":
                fatLabel.text = "\(nutrient.amount) \(nutrient.unit)"
            case "Saturdated Fat":
                saturatedFatLabel.text = "\(nutrient.amount) \(nutrient.unit)"
            case "Carbohydrates":
                carbLabel.text = "\(nutrient.amount) \(nutrient.unit)"
            case "Cholesterol":
                cholesterolLabel.text = "\(nutrient.amount) \(nutrient.unit)"
            case "Sodium":
                sodiumLabel.text = "\(nutrient.amount) \(nutrient.unit)"
            case "Sugar":
                sugarLabel.text = "\(nutrient.amount) \(nutrient.unit)"
            case "Protein":
                proteinLabel.text = "\(nutrient.amount) \(nutrient.unit)"
            default:
                break
            }
        }
    }
    
    
    //MARK:- Firestore
    private func saveMealToFirestore() {
        
        var mealItems = [Any]()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var meal = Meal()
        meal.name = recommendedRecipe?.title
        
        if let calories = recommendedRecipe?.nutrition.nutrients[0].amount {
            meal.calories = Helper.roundFloat(num: Float(calories))
        }

        if let fat = recommendedRecipe?.nutrition.nutrients[1].amount {
            meal.fat = Helper.roundFloat(num: Float(fat))
        }

        if let carbs = recommendedRecipe?.nutrition.nutrients[2].amount {
            meal.carbs = Helper.roundFloat(num: Float(carbs))
        }

        if let protein = recommendedRecipe?.nutrition.nutrients[3].amount {
            meal.protein = Helper.roundFloat(num: Float(protein))
        }
        self.meals.append(meal)
      

        for meal in meals {
            do {
                let jsonData = try JSONEncoder().encode(meal)
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                mealItems.append(jsonObject)
            }
            catch{
                print("Error encoding meal object")
            }
        }
        let todayDate = Helper.getDate()
        let docData: [String: Any] = [
            "\(todayDate)": mealItems
        ]

        Firestore.firestore().collection("meals").document(uid).setData(docData, merge: true) { (error) in
            if let error = error {
                print("Error saving meals: ", error)
                return
            }
            
        }
    }
    
    private func fetchUserMeals(){
        let date = Helper.getDate()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("meals").document(uid).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("****Error fetching users meals:", error)
                return
            }
            
            guard let dictionary = documentSnapshot?.data() else { return }
            
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

        }
    }
    
    
    private func postMealRating() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let recipeId = recommendedRecipe?.id else { return }
        
        APIService.shared.postLikedMeal(uid: uid, recipeID: recipeId) { (data, response, error) in
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
        }
              
    }
    
    
}
