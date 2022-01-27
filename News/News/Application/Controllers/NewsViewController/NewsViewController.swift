//
//  ViewController.swift
//  News
//
//  Created by Yury Khadatovich on 24.01.22.
//

import UIKit
import CoreData

class NewsViewController: BaseViewController {
    //MARK: -Outlets
    @IBOutlet weak var newsTableView: UITableView! {
        didSet {
            newsTableView.delegate = self
            newsTableView.dataSource = self
            newsTableView.register(NewsTableViewCell.self)
            newsTableView.rowHeight = UITableView.automaticDimension
            newsTableView.estimatedRowHeight = 600
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var favouritedNewsButton: UIBarButtonItem!
    
    //MARK: -Properies
    private var model: ArticlesList?
    private var savedArticles = [NSManagedObject]()
    internal let cache = NSCache<NSURL, UIImage>()
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
    private var searching = false
    private var searchedNews = [Article]()
    private var savedNews = [Article]()
    
    
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
        let endpointEverything = Constants.endpointEverything
        let apiKey = Constants.secondAPIKey//Constants.APIKey
        let from = sinceDate
        let to = tillDate
        let requestParameters = "?" + RequestParameters.question + "apple" + "&from=" + from + "&to=" + to + "&apiKey="
        guard let url = URL(string: urlScheme + baseServerURL + endpointEverything + requestParameters + apiKey) else { fatalError("Bad URL!") }
        return url
    }
    
   private func saveArticle(article: Article) {
       
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
       let container = appDelegate.persistentContainer
       let managedContext = container.viewContext
       let entity =  NSEntityDescription.entity(forEntityName: "ArticleDB", in: managedContext)
       let articleDB = NSManagedObject(entity: entity!, insertInto: managedContext)
       articleDB.setValue(article.title, forKey: "title")
       articleDB.setValue(article.description, forKey: "articleDescription")
       articleDB.setValue(article.author, forKey: "author")
       articleDB.setValue(article.urlToImage, forKey: "urlToImage")
       articleDB.setValue(article.content, forKey: "content")
       articleDB.setValue(article.publishedAt, forKey: "publishedAt")
       articleDB.setValue(article.url, forKey: "url")
       
       managedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
           
       do {
          try managedContext.save()
         } catch {
          print("Failed saving")
       }
       
       savedArticles.append(articleDB)
       
       
    }
    
    //MARK: -Actions
    @objc func refresh(_ sender: AnyObject) {
        self.model = nil
        daysCounter = 1
        newDate = dateManager.getCurrentDate()
        loadNews(from: previousDate, to: newDate,  completion: self.refreshControl.endRefreshing)
    }
    
    @IBAction func didPressFavouritesButton(_ sender: Any) {
        guard let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: typeName(SavedNewsViewController.self)) as? SavedNewsViewController else { fatalError() }
        vc.newsViewController = self
        vc.cache = self.cache
        self.navigationController?.pushViewController(vc, animated: true)
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
        return cell
    }
    
    func configureCell(cell: NewsTableViewCell, forRowAt indexPath: IndexPath) {
        
        if !cell.bodyLabel.isTruncated {
            cell.showMoreButton.tintColor = .clear
        }
        
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
        
        cell.addToFavouritesButtonAction = { [unowned self] in
            guard let model = model,
                  var article = model.getArticle(fromPosition: indexPath.row)
            else { return }
            
            saveArticle(article: article)
//        isLiked = !isLiked
//            if !isLiked{
//                cell.addToFavouritesButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
//                cell.addToFavouritesButton.setImage(UIImage(systemName: "star.fill"), for: .highlighted)
//                article.isLiked = false
//                self.unsaveArticle(from: cell, at: indexPath)
//            } else {
//                cell.addToFavouritesButton.setImage(UIImage(systemName: "star"), for: .normal)
//                cell.addToFavouritesButton.setImage(UIImage(systemName: "star"), for: .highlighted)
//                article.isLiked = true
//                self.saveArticle(from: cell, at: indexPath)
//            }
        }
        
        cell.showMoreClosure = { [unowned self] in
            cell.bodyLabel.numberOfLines = 0
            cell.showMoreButton.setTitle("Show less", for: .normal)
            self.newsTableView.beginUpdates()
            self.newsTableView.endUpdates()
            
        }
        
        cell.showLessClosure = { [unowned self] in
            cell.bodyLabel.numberOfLines = 3
            cell.showMoreButton.setTitle("Show more...", for: .normal)
            self.newsTableView.beginUpdates()
            self.newsTableView.endUpdates()
        }
        
    }
    
    func isInFavourites(article: Article, at cell: NewsTableViewCell) -> Bool {
        for savedArticle in savedNews {
            if cell.headerLabel.text == savedArticle.title {
                return true
            }
        }
        return false
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
