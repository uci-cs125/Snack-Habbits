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
    // TODO:- Use Date as part of query in order to return relevant results (Breakfast, Lunch, Dinner)
    func fetchMeals(uid: String, completion: @escaping (SearchResult?, Error?) -> ()) {
        let currHour = getCalendarHour()
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
            } catch let jsonErr {
                print("Failed to decode json: ", jsonErr)
                completion(nil, jsonErr)
            }
            }.resume() //END URLSession
    }
    
    func postLikedMeal(uid: String, recipeID: Int32, completion: @escaping(Data?, URLResponse?, Error?) ->()) {

        //let mock_recipe_id = Int(715544)
        let url = URL(string: "http://localhost:5000/likes/")!
        let parameters: [String:Any] = [
            "user_id" : "\(uid)",
            "recipe_id": recipeID
        ]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        let session = URLSession.shared
            session.dataTask(with: request) { (data, response, error) in
                completion(data, response, error)
            }.resume()
     
        
    }
    
//    func fetch<T: Decodable>(urlString: String,uid: String, completion: @escaping (T?, Error?) -> ()) {
//        guard let url = URL(string: urlString) else { return }
//
//
//        //guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let error = error {
//                print("Failed to fetch results:", error)
//                completion(nil, error)
//                return
//            }
//            guard let data = data else { return }
//
//            do {
//                let decodedData = try JSONDecoder().decode(T.self, from: data)
//                completion(decodedData, nil)
//            } catch let jsonErr {
//                print("Failed to decode json: ", jsonErr)
//                completion(nil, jsonErr)
//            }
//            }.resume() //END URLSession
//    }
//
    

    private func getCalendarHour() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        print("Time: \(hour)")
        return hour
    }
    
    

    
}
