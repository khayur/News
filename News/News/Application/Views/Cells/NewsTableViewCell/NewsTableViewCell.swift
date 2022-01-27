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
    var addToFavouritesButtonAction : (() -> ())?
    var showMoreClosure: (() -> ())?
    var showLessClosure: (() -> ())?
    var isLiked = false
    
    
    //MARK: -Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
        self.coverImageView.image = nil
        self.addToFavouritesButton.addTarget(self, action: #selector(didPressAddToFavouritesButton(_:)), for: .touchUpInside)
        
        if isLiked {
            addToFavouritesButton.setImage(UIImage(systemName: "star"), for: .normal)
            addToFavouritesButton.setImage(UIImage(systemName: "star"), for: .highlighted)
        } else {
            addToFavouritesButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            addToFavouritesButton.setImage(UIImage(systemName: "star.fill"), for: .highlighted)
        }
        if !bodyLabel.isTruncated {
            showMoreButton.isHidden = true
        }
    }
    
    func setCustomImage(image: UIImage) {
        
        let aspect = image.size.width / image.size.height
        
        let constraint = NSLayoutConstraint(
            item: coverImageView as UIImageView,
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
    
    //MARK: -Actions
    @IBAction func didPressAddToFavouritesButton(_ sender: Any) {
        addToFavouritesButtonAction?()
    }
    
    @IBAction func didPressShowMoreButton(_ sender: Any) {
        if bodyLabel.numberOfLines != 0 {
            showMoreClosure?()
        } else {
            showLessClosure?()
        }
        
    }
    
}

