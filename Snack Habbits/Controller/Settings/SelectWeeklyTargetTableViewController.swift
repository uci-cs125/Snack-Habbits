//
//  SelectWeeklyTargetTable.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/14/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

protocol SelectWeeklyTargetTableViewControllerDelegate {
    func didSelect(weeklyTarget: String)
}


class SelectWeeklyTargetTableViewController: UITableViewController {

    var delegate: SelectWeeklyTargetTableViewControllerDelegate?
    
    let data = ["Maintain my weight", "Lose 2.0 lb/week", "Lose 1.5 lb/week", "Lose 1.0 lb/week", "Lose 0.5 lb/week","Gain 0.5 lb/week",  "Gain 1.0 lb/week",  "Gain 1.5 lb/week", "Gain 2.0 lb/week"]
    
    var selectedWeeklyTarget: String?
    
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TargetTypeCell", for: indexPath)
        let targetType = data[indexPath.row]
        if targetType == selectedWeeklyTarget {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = targetType
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedWeeklyTarget = data[indexPath.row]
        delegate?.didSelect(weeklyTarget: selectedWeeklyTarget!)
        tableView.reloadData()
        self.navigationController?.popViewController(animated: true)
    }
}
