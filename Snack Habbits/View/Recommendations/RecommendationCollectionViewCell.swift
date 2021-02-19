//
//  RecommendationCollectionViewCell.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 2/14/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import UIKit
import SDWebImage
class RecommendationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    
    @IBOutlet weak var tagLabel: UITextView!
    func configure(with result: Result){
        layer.cornerRadius = 10
        layer.masksToBounds = true
        layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let url = URL(string: result.image)

        titleLabel.text = result.title
        imageView.sd_setImage(with: url)
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        print("Found result with similarity score: \(result.similarityScore)")
        ratingLabel.text = "\(result.aggregateLikes) Likes"
        
        calorieLabel.text = "\(result.nutrition.nutrients[0].amount) \(result.nutrition.nutrients[0].unit) per serving"
        
        var tags = ""
        if result.vegetarian {
            tags.append("vegetarian      ")
        }
        
        if result.vegan {
            tags.append("vegan      ")
        }
        
        if result.glutenFree {
            tags.append("gluten-free      ")
        }
        
        if result.dairyFree {
            tags.append("dairy-free      ")
        }
        
        if result.sustainable {
            tags.append("sustainable      ")
        }
        
        if result.cheap {
            tags.append("cheap      ")
        }
        
        if result.veryHealthy {
            tags.append("very-healthy      ")
        }
        
        for dishType in result.dishTypes {
            if dishType != "main course" {
                tags.append("\(dishType)      ") // eliminates duplicates
            }
        }
        
        for cuisine in result.cuisines {
            let cuisine = cuisine.lowercased()
            tags.append("\(cuisine)      ") // eliminates duplicates
        }
        
        for diet in result.diets {
            let diet = diet.lowercased()
            tags.append("\(diet)      ") // eliminates duplicates
        }
        tagLabel.text = tags
    }
}
