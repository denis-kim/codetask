//
//  DetailViewController.swift
//  ostest
//
//  Created by Denis Kim on 07/10/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
  
  @IBOutlet private weak var uiImageView: UIImageView!
  @IBOutlet private weak var uiTitleLabel: UILabel!
  @IBOutlet private weak var uiSynopsisTextView: UITextView!
  
  var episode: Episode!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.uiTitleLabel.numberOfLines = 0
    self.uiTitleLabel.lineBreakMode = .byWordWrapping
    
    
    self.uiTitleLabel.text = self.episode.title
    self.uiSynopsisTextView.text = self.episode.subtitle
    
    if let urlString = episode.imageURLs.first?.url,
      let url = URL(string: urlString) {
      
      self.uiImageView.af_setImage(withURL: url, completion: { (response) in
        
      })
    }
    
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    
  }
}
