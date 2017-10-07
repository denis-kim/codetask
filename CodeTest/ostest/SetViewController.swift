//
//  SetViewController.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import AlamofireImage
import RealmSwift
import SwiftyBeaver

/**
 Shows the list of Sets
 */
final class SetViewController : UIViewController {
  
  /// Table View
  @IBOutlet private weak var tblView : UITableView?
  
  /// Activity loader for the table vie
  @IBOutlet private weak var activity : UIActivityIndicatorView?
  
  /// Log
  let log = SwiftyBeaver.self
  
  /// The movies set data
  fileprivate var data : Results<Episode>?
  
  // Timer for retrying to fetch data
  // (ideally we'd use reachability changes)
  private var timer: Timer?
  
  /**
   Setup the view
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// Call to setup the data
    self.setupData()
    
    /// Call to setup view related objects
    self.setupViews()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  /**
   Setup loading
   
   - parameter isLoading
   */
  func setupLoading (isLoading : Bool) {
    
    if isLoading {
        self.activity?.startAnimating()
    } else {
        self.activity?.stopAnimating()
    }
    
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
      self.activity?.alpha = isLoading ? 1.0 : 0.0
      self.tblView?.alpha = isLoading ? 0.0 : 1.0
    }) { (_) in }
  }
  
  /**
   Set's up the data for the table view
   */
  func setupData() {
    
    self.setupLoading(isLoading: true)
    
    self.setupHomeData()
  }
  
  private func setupHomeData () {
    
    Database.instance.fetchSets { (isSetsFetchComplete, movies) in
        
      if let movies = movies, isSetsFetchComplete {
        for movie in movies {
          if movie.setTypeSlug == "home" {
            self.getData(forSetItems: movie.items)
            return
          }
        }
      }
      
      // unable to get data at this time
      // will need to try again when reachability status changes
      self.setupLoading(isLoading: false)
      self.scheduleTimer()
    }
  }
  
  private func getData(forSetItems setItems: List<SetItem>) {
    
    var urls = [String]()
    for setItem in setItems {
      if (setItem.contentType == "episode") {
        urls.append(setItem.contentUrl)
      }
    }
    
    Database.instance.fetchEpisodes(forUrls: urls) { (isComplete, episodes) in
      
      self.processDataResult(isComplete: isComplete, episodes: episodes)
      
    }
  }
  
  private func processDataResult(isComplete: Bool, episodes: Results<Episode>?) {
    if let episodes = episodes, isComplete {
      
      self.data = episodes
      
      self.setupLoading(isLoading: false)
      
      self.log.verbose("Episodes count \(self.data == nil ? 0 : self.data!.count)")
      self.tblView?.reloadData()
      
      self.stopTimer()
    } else {
      
      self.setupLoading(isLoading: false)
      self.scheduleTimer()
    }
  }
  
  private func setupViews() {
    self.tblView?.delegate = self
    self.tblView?.dataSource = self
    self.tblView?.separatorStyle = .singleLine
    self.tblView?.separatorColor = UIColor.black
    self.tblView?.separatorInset = UIEdgeInsets.zero
    
  }
    
  private func scheduleTimer() {
    self.stopTimer()
    
    self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
      self.setupData()
    })
  }

  private func stopTimer() {
    self.timer?.invalidate()
    self.timer = nil
  }
}


/**
 Table View datasource
 */
extension SetViewController : UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let movies = self.data {
      self.log.verbose("Table will show \(movies.count) items")
      return movies.count
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    /// Get the cell
    guard let cell = tableView.dequeueReusableCell(withIdentifier: SetViewCell.identifier) as? SetViewCell else {
      return UITableViewCell()
    }
    
    /// Set the data
    if let data = self.data?[indexPath.row] {
      
      /// Background image
      if let urlString = data.imageURLs.first?.url,
        let url = URL(string: urlString) {
        
        cell.imgBackground?.af_setImage(withURL: url, completion: { (response) in

        })
      }
      
      /// Title
      cell.lblTitle?.text = data.title
      
      /// Description
      cell.txtDescription?.text = data.subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
      
      cell.btnFavourite?.setIsFavourite(data.isFavourite, animated: false)
      cell.btnFavourite?.tappedHandler = { [weak self] (_ button: FavButton) in
        self?.didTapButton(button, atIndexPath: indexPath)
      }
      
    }
    
    /// Return the cell
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    /// Default
    return 180.0
  }
  
}


/**
 Table view delegate
 */
extension SetViewController : UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let episode = self.data?[indexPath.row] {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      if let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
        vc.episode = episode
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
  }
}


/**
 Handle Favouriting
 */
extension SetViewController {
  fileprivate func didTapButton(_ button: FavButton, atIndexPath indexPath: IndexPath) {
    
    if let movie = self.data?[indexPath.row] {
      let done = Database.instance.update {
        movie.isFavourite = !movie.isFavourite
      }
      
      if done {
        button.setIsFavourite(movie.isFavourite, animated: true)
      }
    }
  }
}
