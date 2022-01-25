//
//  NetworkManager.swift
//  News
//
//  Created by Yury Khadatovich on 25.01.22.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func getArticles(with url: URL, completion: @escaping ([Article]?) -> ()) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let newsResponse = try? decoder.decode(NewsResponse.self, from: data)
                completion(newsResponse?.articles)
            }
            
        }.resume()
        
    }
}
