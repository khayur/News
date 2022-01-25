//
//  ImageLoader.swift
//  News
//
//  Created by Yury Khadatovich on 25.01.22.
//

import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private init() {}
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let data = data {
                DispatchQueue.main.async {
                    completion(UIImage(data: data))
                }
            }
        }.resume()
    }
}
