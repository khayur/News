//
//  NavigationController.swift
//  News
//
//  Created by Yury Khadatovich on 24.01.22.
//

import UIKit

class NavigationController: UINavigationController {
    //MARK: - Variables
        @IBInspectable var color: UIColor?

        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return [.portrait]
        }

        override var shouldAutorotate: Bool {
            return false
        }
        
        override var modalPresentationStyle: UIModalPresentationStyle {
            get {
                return .fullScreen
            }
            set {}
        }

        override var preferredStatusBarStyle: UIStatusBarStyle {
            return viewControllers.last?.preferredStatusBarStyle ?? .lightContent
        }

    //MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()

            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            }
            
            design()
        }
    private func design() {
        color = Constants.appMainColor

        
        let appearanceOfNavBar = UINavigationBarAppearance()
        appearanceOfNavBar.configureWithOpaqueBackground()
        appearanceOfNavBar.backgroundColor = color
        
        
        self.navigationBar.standardAppearance = appearanceOfNavBar
        self.navigationBar.scrollEdgeAppearance = appearanceOfNavBar
        self.navigationBar.tintColor = .white
    }
}
