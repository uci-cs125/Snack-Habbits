//
//  TodaysMealsTableViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/14/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit

class TodaysMealsTableViewController: UITableViewController {

    //MARK:- Properties
    var meals = [Meal]()
    var delegate: TodaysMealsDelegate?
    // Used to keep track of which cell has an open SwipeAction
    var swipedIndex: IndexPath?
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        meals = [Meal]()
        //fetchUserMeals()
        tableView.tableFooterView = UIView()
        tableView.register(MealInputCell.self, forCellReuseIdentifier: "MealCell")

        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchUserMeals()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell") as! MealInputCell
        let meal = meals[indexPath.row]
        cell.meal = meal
        cell.delegate = self

//        cell.textLabel?.text = "\(meal.name!)"
//        cell.detailTextLabel?.text = "\(meal.calories!) kcals"
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    //MARK:- Navigation
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
        meals = [Meal]()
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
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    

}

extension TodaysMealsTableViewController: MealInputTableViewControllerDelegate {
    func didSave(meal: Meal) {
        meals.append(meal)
        saveMealToFirestore()
        print("delegate?.didSaveNewMeal()")
        delegate?.didSaveNewMeal()

        tableView.reloadData()
    }
    
}

protocol TodaysMealsDelegate {
    func didSaveNewMeal()
}

//MARK:- SwipeCell Delegate Methods
extension TodaysMealsTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .default , title: nil) { (action, indexPath) in
            //Dismiss swipe
            self.meals.remove(at: indexPath.row)
            print(self.meals[indexPath.row])
            action.hidesWhenSelected = true
            self.swipedIndex = nil
            self.saveMealToFirestore()
            self.tableView.reloadData()
        }
        
        let editAction = SwipeAction(style: .default, title: nil) { action, indexPath in
            action.hidesWhenSelected = true
            self.swipedIndex = nil
            let storyboard = UIStoryboard(name: "Main", bundle:  Bundle(for: type(of: self)))

            let editMealVC = storyboard.instantiateViewController(identifier: "MealInput") as MealInputTableViewController
            
            editMealVC.delegate = self
            editMealVC.editMeal = self.meals[indexPath.row]
            editMealVC.enabled = true
            //editToDoVC.toDo = self.toDoTasks?[indexPath.row]
            self.navigationController?.pushViewController(editMealVC, animated: true)
            // Dismiss swipe



        }
        
        // customize the action appearance
        deleteAction.image = #imageLiteral(resourceName: "trash-icon-white").resizedImage(newSize: CGSize(width: 28  , height: 28))
        deleteAction.backgroundColor = #colorLiteral(red: 0.8881979585, green: 0.3072378635, blue: 0.2069461644, alpha: 1)

        editAction.image = #imageLiteral(resourceName: "settings-icon").resizedImage(newSize: CGSize(width: 28 , height: 28))
        editAction.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)

        return [deleteAction, editAction]
        
        
    }
    
    // Used to ensure swiped cell is dismissed when transitioning to new scene
    func collectionView(_ collectionView: UICollectionView, willBeginEditingItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) {
        swipedIndex = indexPath
    }
    
    
}
