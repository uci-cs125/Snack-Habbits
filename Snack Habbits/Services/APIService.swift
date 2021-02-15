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
    func fetchMeals(searchTerm: String, completion: @escaping (SearchResult?, Error?) -> ()) {
        let currHour = getCalendarHour()
//        let urlString = "http://127.0.0.1:5000/recommendations/?hour=" + String(currHour) // run backend locally and test with this
        let urlString = "https://recommendations-backend-dev.herokuapp.com/?hour=" + String(currHour) // connected to official heroku app for Snack Habbits
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
    
    private func getCalendarHour() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        print("Time: \(hour):\(minutes)")
        return hour
    }
}
