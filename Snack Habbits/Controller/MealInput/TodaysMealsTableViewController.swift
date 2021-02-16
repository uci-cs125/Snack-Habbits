//
//  TodaysMealsTableViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/14/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

class TodaysMealsTableViewController: UITableViewController {

    var meals = [Meal]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
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
}

extension TodaysMealsTableViewController: MealInputTableViewControllerDelegate {
    func didSave(meal: Meal) {
        meals.append(meal)
        tableView.reloadData()

    }
    
}
