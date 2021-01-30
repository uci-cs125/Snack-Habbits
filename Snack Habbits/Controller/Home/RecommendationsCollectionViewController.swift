//
//  RecommendationsCollectionViewController.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/30/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit


class RecommendationsCollectionViewController: BaseCollectionViewController {

    //MARK:- Properties
    private let recommentationResultCellId = "recommendationCell"
    private var recommendationResults = [Result]()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearchBar()
        
        APIService.shared.fetchMeals(searchTerm: "random") { (results, error) in
            
            if let error = error {
                print("Failed to fetch apps in search page: ", error)
                return
            }
            
            self.recommendationResults = results?.results ?? []
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
        } // END APIService
    }
    
    //MARK:- Setup
    private func setupCollectionView() {
        collectionView?.backgroundColor = .white
        collectionView?.register(RecommendationResultCell.self, forCellWithReuseIdentifier: recommentationResultCellId)
    }
    
    private func setupSearchBar() {
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    //MARK:- Collection View Delegate
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: recommentationResultCellId, for: indexPath) as! RecommendationResultCell
        let recommendationResult = recommendationResults[indexPath.item]
        cell.result = recommendationResult
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendationResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let appId = String(appResults[indexPath.item].trackId)
//        let resultDetailController = ResultDetailController(appId: appId)
//        navigationController?.pushViewController(appDetailController, animated: true)
    }
}

//MARK:- Collection View Flow Layout Delegate
extension RecommendationsCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 300)
    }
}
