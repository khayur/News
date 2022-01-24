//
//  UIStoryboard+Additions.swift
//  News
//
//  Created by Yury Khadatovich on 24.01.22.
//

import UIKit.UIStoryboard

enum StoryboardType: String {
    case main = "Main"
}

extension UIStoryboard {

    static let mainStoryboard = UIStoryboard(.main)

    convenience init(_ type: StoryboardType) {
        self.init(name: type.rawValue, bundle: nil)
    }

    func instantiate<T>(identifier: String = "") -> T {
        let identifier = identifier.isEmpty ? typeName(T.self) : identifier
        guard let controller = instantiateViewController(withIdentifier: identifier) as? T else {
            fatalError()
        }
        return controller
    }

}
