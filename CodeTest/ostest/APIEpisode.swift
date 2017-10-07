//
//  APIEpisode.swift
//  ostest
//
//  Created by Denis Kim on 06/10/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import SwiftyJSON
import SwiftyBeaver

struct APIEpisode {
  
  private(set) var title: String = ""
  private(set) var subtitle: String = ""
  private(set) var imageURLs : [String] = [String]()
  
  init(title: String, subtitle: String, imageURLs: [String]) {
    self.title = title
    self.subtitle = subtitle
    self.imageURLs = imageURLs
  }
  
  init (with object : JSON) {
    if let title = object["title"].string {
      self.title = title
    }
    
    if let subtitle = object["subtitle"].string {
      self.subtitle = subtitle
    }
    
    if let imageURLs = object["image_urls"].array {
      for thisImageURL in imageURLs {
        if let url = thisImageURL.string {
          self.imageURLs.append(url)
        }
      }
    }
  }
  
}
