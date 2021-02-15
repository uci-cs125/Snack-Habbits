//
//  SelectActivityLebelTableViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/14/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//


import UIKit

protocol SelectActivityLevelTableViewControllerDelegate {
    func didSelect(activityLevel: String)
}

class SelectActivityLevelTableViewController: UITableViewController {

    var delegate: SelectActivityLevelTableViewControllerDelegate?
    
    let data = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active"]
    
    var selectedActivityLevel: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityLevelCell", for: indexPath)
        let activityLevel = data[indexPath.row]
        if activityLevel == selectedActivityLevel {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = activityLevel
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedActivityLevel = data[indexPath.row]
        delegate?.didSelect(activityLevel: selectedActivityLevel!)
        tableView.reloadData()
        self.navigationController?.popViewController(animated: true)
    }

}
