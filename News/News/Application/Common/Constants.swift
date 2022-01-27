//
//  Constants.swift
//  News
//
//  Created by Yury Khadatovich on 24.01.22.
//

import UIKit

struct Constants {
    static let animationDuration = 0.25
    static let urlScheme = "https://"
    static let baseServerUrl = "newsapi.org/"
    static let endpointTopHeadlines = "v2/top-headlines"
    static let endpointEverything = "v2/everything"
    static let APIKey = "7415813ce243489184d5e50f7bc439c3"
    static let secondAPIKey = "721e808e7f364dd6a99bff14413a1919"
    static let thirdAPIKey = "1c7c8ef9e2d4459fad148e0804d1dcb4"
    static let fourthAPIKey = "7b5b06b3411141ee9726f74c6aa24a8b"
    static let appMainColor = UIColor(red: 117/255.0, green: 117/255.0, blue: 255/255.0, alpha: 1)
    static let appFontMainColor = UIColor(red: 40/255.0, green: 40/255.0, blue: 45/255.0, alpha: 1)
    static let appFontSubColor = UIColor(red: 97/255.0, green: 92/255.0, blue: 97/255.0, alpha: 1)
    static let appSupportingColor = UIColor(red: 240/255.0, green: 238/255.0, blue: 233/255.0, alpha: 1)
    static let appButtonsColor = appMainColor.withAlphaComponent(0.7)
}

/// Converting type's name to String
/// - Parameter some: Type that will be converted to String
/// - Returns: String value of parameter's name
func typeName(_ some: Any) -> String {
    return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
}
