//
//  RealmEpisode.swift
//  ostest
//
//  Created by Denis Kim on 06/10/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import RealmSwift


/**
 The set Realm Object
 */
class Episode : Object {

  dynamic var title : String = ""
  dynamic var subtitle : String = ""
  var imageURLs = List<Image>()
  dynamic var isFavourite : Bool = false
  
  /**
   Creates a Realm object from the APIEpisode
   */
  static func initEpisode (from api : APIEpisode) -> Episode {
    
    let images = List<Image>()
    for thisImageURL in api.imageURLs {
      let newImage = Image()
      newImage.url = thisImageURL
      images.append(newImage)
    }
    
    let episode = Episode()
    episode.title = api.title
    episode.subtitle = api.subtitle
    episode.imageURLs = images
    
    return episode
  }
  
}
