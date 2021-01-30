//
//  HomeTabBarController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/30/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewControllers()
    }
    
    //MARK:- Setup
    private func setupViewControllers() {
        viewControllers = [
            generateNavigationController(with: RecommendationsCollectionViewController(), title: "Default1", image: #imageLiteral(resourceName: "top_left_profile")),
            generateNavigationController(with: UITableViewController(), title: "Default2", image: #imageLiteral(resourceName: "top_left_profile")),
            generateNavigationController(with: UITableViewController(), title: "Default3", image: #imageLiteral(resourceName: "top_left_profile"))
        ]
    }
    
    //MARK:- Helpers
    // Generates view controller wrapped in navigation controller
    private func generateNavigationController(with rootViewController: UIViewController, title: String, image:UIImage) -> UIViewController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        
       // navController.navigationBar.prefersLargeTitles = true
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        
        rootViewController.navigationItem.title = title
        rootViewController.view.backgroundColor = .white
        
        return navController
    }

}
