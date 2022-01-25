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
    private let cache = NSCache<NSURL, UIImage>()
    private var networkManager = NetworkManager.shared
    private var imageLoader = ImageLoader.shared
    private let refreshControl = UIRefreshControl()
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        loadNews(completion: nil)
        configureTableView()
        cache.countLimit = 100
    }
    
    //MARK: -Methods
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search for news"
    }
    
    private func configureTableView() {
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        newsTableView.addSubview(refreshControl)
    }
    
    private func loadNews(completion:  (()-> Void)?) {
        let urlScheme = Constants.urlScheme
        let baseServerURL = Constants.baseServerUrl
        let endpoint = Constants.endpointTopHeadlines
        let apiKey = Constants.APIKey
        let from = RequestParameters.from(hoursAgo: 24)
        let to = RequestParameters.to()
        let requestParameters = "?" + RequestParameters.country + Countries.us.rawValue + "&" + from + "&" + to + "&apiKey="
        guard let url = URL(string: urlScheme + baseServerURL + endpoint + requestParameters + apiKey) else { fatalError("Bad URL!") }
        
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
        (completion ?? self.refreshControl.endRefreshing)()
    }
    
    //MARK: -Actions
    @objc func refresh(_ sender: AnyObject) {
        loadNews(completion: self.refreshControl.endRefreshing)
    }
}

//MARK: -TableViewDataSource Extension
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model?.articles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as NewsTableViewCell
        
        configureCell(cell: cell, forRowAt: indexPath)
        return cell
    }
    
    func configureCell(cell: NewsTableViewCell, forRowAt indexPath: IndexPath) {
        guard let model = model,
              let article = model.getArticle(fromPosition: indexPath.row),
              let urlToImage = article.urlToImage,
              let imageURL = URL(string: urlToImage),
              let cacheKey = NSURL(string: urlToImage)
        else { return }
        
        cell.coverImageView.image = UIImage(named: "placeholder")
        cell.headerLabel.text = article.title
        cell.bodyLabel.text = article.description
        imageLoader.loadImage(from: imageURL) { [weak self] image in
            guard let self = self, let image = image else { return }
                cell.setCustomImage(image: image)
                self.cache.setObject(image, forKey: cacheKey)
        }
    }
    
}

//MARK: -TableViewDelegate Extension
extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let model = model,
              let article = model.getArticle(fromPosition: indexPath.row),
              let urlToImage = article.urlToImage,
              let imageURL = URL(string: urlToImage),
              let cacheKey = NSURL(string: urlToImage)
        else { return }
        
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as NewsTableViewCell
        
        if let cachedImage = self.cache.object(forKey: cacheKey) {
            print("Using a cached image for item: \(cacheKey)")
            cell.coverImageView.image = cachedImage
        } else {
            imageLoader.loadImage(from: imageURL) { [weak self] image in
                guard let self = self, let image = image else { return }
                    cell.setCustomImage(image: image)
                    self.cache.setObject(image, forKey: cacheKey)
            
            }
        }
    }
}

//MARK: -SearchBar delegate extension

extension NewsViewController: UISearchBarDelegate {
    
}
