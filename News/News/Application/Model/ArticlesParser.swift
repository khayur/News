//
//  Articles.swift
//  News
//
//  Created by Yury Khadatovich on 25.01.22.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let newsResponse = try? newJSONDecoder().decode(NewsResponse.self, from: jsonData)

import Foundation

// MARK: - NewsResponse
struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    var articles: [Article]
}

// MARK: - Article
struct Article: Codable {
    let source: Source
    let author: String?
    let title, description: String
    let url: String
    let urlToImage: String?
    let publishedAt: Date
    let content: String?
    var isLiked: Bool? = false

    enum CodingKeys: String, CodingKey {
        case source, author, title
        case description
        case url, urlToImage, publishedAt, content
             case isLiked
    }
}

// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String
}
