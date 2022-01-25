//
//  ViewController.swift
//  News
//
//  Created by Yury Khadatovich on 24.01.22.
//

import UIKit

class NewsViewController: BaseViewController {
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
    private var model: ArticlesList?
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        loadNews()
        
    }
    
    //MARK: -Methods
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search for news"
    }
    
    private func loadNews() {
        let urlScheme = Constants.urlScheme
        let baseServerURL = Constants.baseServerUrl
        let endpoint = Constants.endpointTopHeadlines
        let apiKey = Constants.APIKey
        let requestParameters = "?" + RequestParameters.country + Countries.us.rawValue + "&apiKey="
        guard let url = URL(string: urlScheme + baseServerURL + endpoint + requestParameters + apiKey) else { fatalError("Bad URL!") }
        
        let networkManager = NetworkManager.shared
        self.showLoading()
        
        networkManager.getArticles(with: url) { articles in
            if let articles = articles {
                self.model = ArticlesList(articles: articles)
            }
            
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
                self.hideLoading()
            }
        }
    }
    //MARK: -Actions
    
}

//MARK: -TableViewDataSource Extension
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model?.articles.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as NewsTableViewCell
        configureCell(cell: cell, forRowAt: indexPath)
        return cell
    }
    
    func configureCell(cell: NewsTableViewCell, forRowAt indexPath: IndexPath) {
        guard let model = model else { return }
        cell.headerLabel.text = model.articles[indexPath.row].title
        cell.bodyLabel.text = model.articles[indexPath.row].description
    }
    
}

//MARK: -TableViewDelegate Extension
extension NewsViewController: UITableViewDelegate {
    
}

//MARK: -SearchBar delegate extension

extension NewsViewController: UISearchBarDelegate {
    
}
