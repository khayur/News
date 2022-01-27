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
#if DEBUG
        print(url)
#endif
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                print(error.localizedDescription)
                print("Error \(error)")
                completion(nil)
            } else if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let newsResponse = try? decoder.decode(NewsResponse.self, from: data)
                completion(newsResponse?.articles)
#if DEBUG
                print(response as Any)
#endif
            }
            
        }.resume()
        
    }
}
