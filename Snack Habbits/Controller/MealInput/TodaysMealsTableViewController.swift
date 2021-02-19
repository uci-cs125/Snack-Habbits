//
//  TodaysMealsTableViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/14/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import Firebase
class TodaysMealsTableViewController: UITableViewController {

    var meals = [Meal]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserMeals()
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK:- Firestore
    private func fetchUserMeals(){
        let date = self.getDate()
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
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
                
        }

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return meals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Cell For row at")
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath)
        let meal = meals[indexPath.row]
        cell.textLabel?.text = "\(meal.name!)"
        cell.detailTextLabel?.text = "\(meal.calories!) kcals"
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "InputMeal":
            let destinationViewController = segue.destination as? MealInputTableViewController
            destinationViewController?.delegate = self
        default:
            break;
        }
    }
    
    //MARK:- Firestore
    private func saveMealToFirestore() {

        var mealItems = [Any]()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
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
        let todayDate = getDate()
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
    
    private func getDate() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: date)
        
    }
}

extension TodaysMealsTableViewController: MealInputTableViewControllerDelegate {
    func didSave(meal: Meal) {
        meals.append(meal)
        tableView.reloadData()
        saveMealToFirestore()
    }
    
}
