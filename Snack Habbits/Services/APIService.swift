//
//  APiService.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 1/30/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import Foundation

class APIService {
    static let shared = APIService()
    
    func fetchMeals(searchTerm: String, completion: @escaping (SearchResult?, Error?) -> ()) {
        let urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=20e7627a1f524111abcd0589ce45265e&number=10&addRecipeNutrition=true"
        fetch(urlString: urlString, completion: completion)
    }
    
    
    func fetch<T: Decodable>(urlString: String, completion: @escaping (T?, Error?) -> ()) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Failed to fetch results:", error)
                completion(nil, error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(decodedData, nil)
            } catch let jsonErr{
                print("Failed to decode json: ", jsonErr)
                completion(nil, jsonErr)
            }
            }.resume() //END URLSession
    }
}
