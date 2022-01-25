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
            newsTableView.rowHeight = UITableView.automaticDimension
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var favouritedNewsButton: UIBarButtonItem!
    
    //MARK: -Properies
    private var model: ArticlesList?
    private let cache = NSCache<NSURL, UIImage>()
    private var networkManager = NetworkManager.shared
    private var imageLoader = ImageLoader.shared
    private var dateManager = DateManager.shared
    private let refreshControl = UIRefreshControl()
    private var loadMoreStatus = false
    private var daysCounter = 1.0
    private var previousDate: String {
        DateManager.shared.getDate(daysAgo: daysCounter)
    }
    
    private var newDate = DateManager.shared.getCurrentDate()
    private var expandedIndexSet : IndexSet = []
    private var searching = false
    private var searchedNews = [Article]()
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        loadNews(from: previousDate, to: newDate, completion: nil)
        configureTableView()
        self.searchBar.showsCancelButton = true
    }
    
    //MARK: -Methods
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search for news"
    }
    
    private func configureTableView() {
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing News...")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        newsTableView.addSubview(refreshControl)
    }
    
    private func loadNews(from sinceDate: String, to tillDate: String, completion:  (()-> Void)?) {
        let url = getURL(from: sinceDate, to: tillDate)
        
        self.showLoading()
        
        networkManager.getArticles(with: url) { articles in
            if let articles = articles {
                if self.model == nil {
                    self.model = ArticlesList(articles: articles)
                } else {
                    self.model?.articles.append(contentsOf: articles)
                }
            }
            
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
                self.hideLoading()
            }
        }
        (completion ?? self.refreshControl.endRefreshing)()
    }
    
    private func getURL(from sinceDate: String, to tillDate: String) -> URL {
        let urlScheme = Constants.urlScheme
        let baseServerURL = Constants.baseServerUrl
        let endpointTopHeadlines = Constants.endpointTopHeadlines
        let endpointEverything = Constants.endpointEverything
        let apiKey = Constants.APIKey
        let from = sinceDate
        let to = tillDate
        let requestParameters = "?" + RequestParameters.question + "apple" + "&from=" + from + "&to=" + to + "&apiKey="
        guard let url = URL(string: urlScheme + baseServerURL + endpointEverything + requestParameters + apiKey) else { fatalError("Bad URL!") }
        return url
    }
    
    //MARK: -Actions
    @objc func refresh(_ sender: AnyObject) {
        self.model = nil
        daysCounter = 1
        newDate = dateManager.getCurrentDate()
        loadNews(from: previousDate, to: newDate,  completion: self.refreshControl.endRefreshing)
    }
}

//MARK: -TableViewDataSource Extension
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedNews.count
        } else {
            return model?.articles.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as NewsTableViewCell
        
        configureCell(cell: cell, forRowAt: indexPath)
        
        if expandedIndexSet.contains(indexPath.row) {
            cell.bodyLabel.numberOfLines = 0
        } else {
            cell.bodyLabel.numberOfLines = 3
        }
        
        return cell
    }
    
    func configureCell(cell: NewsTableViewCell, forRowAt indexPath: IndexPath) {
        if searching {
            let article = searchedNews[indexPath.row]
            guard let urlToImage = article.urlToImage,
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
        } else {
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
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            loadMore()
        }
    }
    
    private func loadMore() {
        guard !loadMoreStatus, daysCounter <= 7 else { return }
        newDate = previousDate
        daysCounter += 1
        
        self.loadMoreStatus = true
        self.showLoading()
        self.newsTableView.tableFooterView?.isHidden = false
        loadMoreBegin( completionHandler: {
            self.loadMoreStatus = false
            self.hideLoading()
            self.newsTableView.tableFooterView?.isHidden = true
        })
        
    }
    
    func loadMoreBegin(completionHandler: @escaping () -> ()) {
        self.loadNews(from: previousDate, to: newDate, completion: nil)
        sleep(1)
        DispatchQueue.main.async {
            completionHandler()
        }
    }
    
}

//MARK: -TableViewDelegate Extension
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if(expandedIndexSet.contains(indexPath.row)){
            expandedIndexSet.remove(indexPath.row)
        } else {
            expandedIndexSet.insert(indexPath.row)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

//MARK: -SearchBar delegate extension

extension NewsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let model = self.model else { return }

        searchedNews = model.articles.filter({ article in
            article.title.lowercased().contains(searchText.lowercased()) 
        })
        searching = true
        newsTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        newsTableView.reloadData()
    }
}
