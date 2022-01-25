//
//  NewsTableViewCell.swift
//  News
//
//  Created by Yury Khadatovich on 24.01.22.
//

import UIKit

class NewsTableViewCell: BaseTableViewCell {
    //MARK: - Outlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var addToFavouritesButton: UIButton!
    
    //MARK: - Properties
    var aspectConstraint: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                coverImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                coverImageView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    //MARK: -Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
        self.coverImageView.image = nil
    }
    
    func setCustomImage(image: UIImage) {
        
        let aspect = image.size.width / image.size.height
        
        let constraint = NSLayoutConstraint(
            item: coverImageView,
            attribute: .width,
            relatedBy: .equal,
            toItem: coverImageView,
            attribute: .height,
            multiplier: aspect,
            constant: 0.0
        )
        
        constraint.priority = UILayoutPriority(999)
        aspectConstraint = constraint
        self.coverImageView.contentMode = .scaleAspectFit
        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.clipsToBounds = true
        self.coverImageView.image = image
        
    }
}

