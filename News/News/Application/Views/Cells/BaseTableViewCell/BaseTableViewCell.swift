//
//  BaseTableViewCell.swift
//  News
//
//  Created by Yury Khadatovich on 24.01.22.
//

import UIKit

class BaseTableViewCell: UITableViewCell, NibLoadableView, ReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
