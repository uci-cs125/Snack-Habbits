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
        let urlString = "https://www.themealdb.com/api/json/v1/1/\(searchTerm).php"
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
