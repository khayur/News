//
//  ViewController.swift
//  News
//
//  Created by Yury Khadatovich on 24.01.22.
//

import UIKit

class NewsViewController: UIViewController {
    //MARK: -Outlets
    @IBOutlet weak var newsTableView: UITableView! {
        didSet {
            newsTableView.delegate = self
            newsTableView.dataSource = self
            newsTableView.register(NewsTableViewCell.self)
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var favouritedNewsButton: UIBarButtonItem!
    
    //MARK: -Properies
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK: -Methods
  
    //MARK: -Actions
    
}

//MARK: -TableViewDataSource Extension
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as NewsTableViewCell
        return cell
    }
    
}

//MARK: -TableViewDelegate Extension
extension NewsViewController: UITableViewDelegate {
    
}
