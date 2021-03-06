//
//  BaseViewController.swift
//  News
//
//  Created by Yury Khadatovich on 25.01.22.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Outlets
    
    // MARK: - Variables
    
    var loadingView: LoadingView!

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLoadingView()
        configureServices()
        configureViews()
        
        modalPresentationStyle = .fullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Actions
    
    // MARK: - Helper Methods
    
    func configureServices() {}
    func configureViews() {}
    
    func createLoadingView() {
        loadingView = LoadingView.instantiate()
        loadingView.layer.zPosition = 2
        loadingView.frame = view.bounds
        view.addSubview(loadingView)
        loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func showLoading() {
        loadingView.start()
    }
    
    func hideLoading() {
        loadingView.finish()
    }
}

