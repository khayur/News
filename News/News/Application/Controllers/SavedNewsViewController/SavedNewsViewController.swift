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
    //    var savedNews: [Article]?
    var savedArticles = [NSManagedObject]()
    var newsViewController: NewsViewController?
    internal var cache = NSCache<NSURL, UIImage>()
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataFromDB()
        print(cache)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savedNewsTableView.reloadData()
        
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
            print("Failed")
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
        guard let imageURL = savedArticles[indexPath.row].value(forKey: "urlToImage") as? String,
              let cacheKey = NSURL(string: imageURL)
        else { return }
    
        if let cachedImage = self.cache.object(forKey: cacheKey) {
            print("Success!!!!!")
            print("Using a cached image for item: \(cacheKey)")
            cell.setCustomImage(image: cachedImage)
        } else {
            cell.coverImageView.image = UIImage(named: "placeholder")
        }
        
        cell.headerLabel.text = article.value(forKey: "title") as? String
        cell.bodyLabel.text = article.value(forKey: "articleDescription") as? String
        
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let imageURL = savedArticles[indexPath.row].value(forKey: "urlToImage") as? String,
//              let cacheKey = NSURL(string: imageURL)
//        else { return }
//        
//        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as NewsTableViewCell
//        
//        if let cachedImage = self.cache.object(forKey: cacheKey) {
//            print("Success!!!!!")
//            print("Using a cached image for item: \(cacheKey)")
//            cell.coverImageView.image = cachedImage
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//        } else {
////            imageLoader.loadImage(from: imageURL) { [weak self] image in
////                guard let self = self, let image = image else { return }
////                cell.setCustomImage(image: image)
////                self.cache.setObject(image, forKey: cacheKey)
////            }
//        }
    }
}
