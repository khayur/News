//
//  UIButton+Additions.swift
//  News
//
//  Created by Yury Khadatovich on 24.01.22.
//

import UIKit

extension UIButton {
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.3
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        layer.add(pulse, forKey: nil)
    }
}
