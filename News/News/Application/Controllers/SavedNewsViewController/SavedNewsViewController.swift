//
//  SavedNewsViewController.swift
//  News
//
//  Created by Yury Khadatovich on 26.01.22.
//

import UIKit
import CoreData

class SavedNewsViewController: BaseViewController {
    //MARK: -Outlets
    @IBOutlet weak var savedNewsTableView: UITableView! {
        didSet {
            savedNewsTableView.delegate = self
            savedNewsTableView.dataSource = self
            savedNewsTableView.register(NewsTableViewCell.self)
            savedNewsTableView.rowHeight = UITableView.automaticDimension
            savedNewsTableView.estimatedRowHeight = 600
        }
    }
    
    //MARK: -Properties
    private var savedArticles = [NSManagedObject]()
    private var imageLoader = ImageLoader.shared
    internal var cache = NSCache<NSURL, UIImage>()
    
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savedNewsTableView.reloadData()
        fetchDataFromDB()
    }
    
    //MARK: -Methods
    private func fetchDataFromDB(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ArticleDB")
        request.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(request)
            for data in result as! [NSManagedObject] {
                savedArticles.append(data)
            }
        } catch {
            print("Failed fetching from DB")
        }
    }
    
    private  func deleteArticleFromDB(article: NSManagedObject) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = delegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ArticleDB")
        request.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(request)
            for articleFromDB in result as! [NSManagedObject] {
                if articleFromDB.value(forKey: "url") as? String == article.value(forKey: "url") as? String {
                    managedContext.delete(articleFromDB)
                    try managedContext.save()
                }
            }
        } catch {
            print("Failed deleting from DB")
        }
    }
    
    //MARK: -Actions
    
}

//MARK: -TableViewDataSource Extension
extension SavedNewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        savedArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as NewsTableViewCell
        configureCell(cell: cell, forRowAt: indexPath)
        return cell
    }
    
    private func configureCell(cell: NewsTableViewCell, forRowAt indexPath: IndexPath) {
        let article = savedArticles[indexPath.row]
        guard let urlToImage = savedArticles[indexPath.row].value(forKey: "urlToImage") as? String,
              let imageURL = URL(string: urlToImage),
              let cacheKey = NSURL(string: urlToImage)
        else { return }
        
        cell.addToFavouritesButton.tintColor = .red
        cell.selectionStyle = .none
        if let cachedImage = self.cache.object(forKey: cacheKey) {
            cell.setCustomImage(image: cachedImage)
        } else {
            imageLoader.loadImage(from: imageURL) { [weak self] image in
                guard let self = self, let image = image else { return }
                cell.setCustomImage(image: image)
                self.cache.setObject(image, forKey: cacheKey)
            }
        }
        
        cell.headerLabel.text = article.value(forKey: "title") as? String
        cell.bodyLabel.text = article.value(forKey: "articleDescription") as? String
        
        cell.addToFavouritesButtonAction = { [unowned self] in
            let index = indexPath.row
            savedArticles.remove(at: index)
            savedNewsTableView.deleteRows(at: [indexPath], with: .fade)
            deleteArticleFromDB(article: article)
            savedNewsTableView.reloadData()
        }
        
        cell.showMoreClosure = { [unowned self] in
            cell.bodyLabel.numberOfLines = 0
            cell.showMoreButton.setTitle("Show less", for: .normal)
            self.savedNewsTableView.beginUpdates()
            self.savedNewsTableView.endUpdates()
            
        }
        
        cell.showLessClosure = { [unowned self] in
            cell.bodyLabel.numberOfLines = 3
            cell.showMoreButton.setTitle("Show more...", for: .normal)
            self.savedNewsTableView.beginUpdates()
            self.savedNewsTableView.endUpdates()
        }
    }
}

//MARK: -TableViewDelegate Extension
extension SavedNewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
