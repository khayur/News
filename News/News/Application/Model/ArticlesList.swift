//
//  ArticlesList.swift
//  News
//
//  Created by Yury Khadatovich on 25.01.22.
//

import Foundation

struct ArticlesList {
    var articles: [Article]
}

extension ArticlesList {
    
    func getArticle(fromPosition index: Int) -> Article? {
        if articles.isEmpty || index > articles.count - 1 {
            return nil
        } else {
            return articles[index]
        }
    }
}
