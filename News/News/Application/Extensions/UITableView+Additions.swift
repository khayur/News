//
//  UITableView+Additions.swift
//  News
//
//  Created by Yury Khadatovich on 24.01.22.
//

import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(_ type: T.Type) where T: ReusableView, T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: typeName(T.self))
    }

    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: typeName(T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }

    func dequeueEmptyCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell: EmptyTableViewCell = dequeueReusableCell(forIndexPath: indexPath)
        return cell
    }
    
}
