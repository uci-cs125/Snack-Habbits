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

    func fetchMeals(recipeRequestBody: RecipeRequestBody, completion: @escaping (SearchResult?, Error?) -> ()) {
        let urlString = "http://localhost:5000/recipes/"
//        let urlString = "https://recommendations-backend-dev.herokuapp.com/recipes"
        fetch(urlString: urlString, requestBody: recipeRequestBody, completion: completion)
    }
    
    func fetchCalorieGoal(calorieRequestBody: CalorieRequestBody, completion: @escaping(CalorieResult?, Error?) -> ()){
        let urlString = "http://localhost:5000/calories/"
        fetchCalories(urlString: urlString, requestBody: calorieRequestBody, completion: completion)
    }
    
    func fetchCalories<T: Decodable>(urlString: String,requestBody: CalorieRequestBody, completion: @escaping (T?, Error?) -> ()) {
        guard let url = URL(string: urlString) else { return }
       
        let encoder = JSONEncoder()
        var request = URLRequest(url: url)
        do {
            let httpBody = try encoder.encode(requestBody)
            if let JSONString = String(data: httpBody, encoding: String.Encoding.utf8) {
               print(JSONString)
            }
            request.httpBody = httpBody
        } catch {
            print("Error serializing CalorieFetch JSON \(error.localizedDescription)")
        }
                           
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Failed to fetch calorie goal:", error)
                completion(nil, error)
                return
            }
            guard let data = data else { return }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                print("Decoded calorie in APIService")
                completion(decodedData, nil)
            } catch let jsonErr {
                print("Failed to decode calorie json in APIService: ", jsonErr)
//                print(String(data: data, encoding: String.Encoding.utf8))
                completion(nil, jsonErr)
            }
            }.resume() //END URLSession
    }
    
    func fetch<T: Decodable>(urlString: String,requestBody: RecipeRequestBody, completion: @escaping (T?, Error?) -> ()) {
        guard let url = URL(string: urlString) else { return }
       
        let encoder = JSONEncoder()
        var request = URLRequest(url: url)
        do {
            let httpBody = try encoder.encode(requestBody)
            if let JSONString = String(data: httpBody, encoding: String.Encoding.utf8) {
               //print(JSONString)
            }
            request.httpBody = httpBody
        } catch {
            print("Error serializing JSON \(error.localizedDescription)")
        }
                           
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Failed to fetch results:", error)
                completion(nil, error)
                return
            }
            guard let data = data else { return }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
//                print("Decoded results in APIService")
                completion(decodedData, nil)
            } catch let jsonErr {
//                print("Failed to decode json in APIService: ", jsonErr)
//                print(String(data: data, encoding: String.Encoding.utf8))
                completion(nil, jsonErr)
            }
            }.resume() //END URLSession
    }
    
//    func fetch<T: Decodable>(urlString: String, completion: @escaping (T?, Error?) -> ()) {
//        guard let url = URL(string: urlString) else { return }
//
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
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
    func postLikedMeal(uid: String, recipeID: Int32, completion: @escaping(Data?, URLResponse?, Error?) ->()) {

        //let mock_recipe_id = Int(715544)
//        let url = URL(string: "http://localhost:5000/likes/")!
        let url = URL(string: "https://recommendations-backend-dev.herokuapp.com/likes")!
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
    


    


    
    

    
}
