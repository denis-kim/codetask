//
//  API.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftyBeaver

/**
 The API Class connects to the Skylark API to access content and present it type safe structs
 */
class API {
  
  /// Singleton instance
  static let instance = API()
  
  /// Log
  let log = SwiftyBeaver.self
  
  /// The base URL
  let baseURL = "http://feature-code-test.skylark-cms.qa.aws.ostmodern.co.uk:8000"
  
  func getEpisodes(forUrls urls: [String], completion : @escaping (_ isSuccess : Bool, _ items : [APIEpisode]?) -> Void) {
   
    var count = urls.count
    var all = [APIEpisode]()
    
    for url in urls {
      let urlString = baseURL + url
      self.getJson(forUrlString: urlString, completion: { (isComplete, json) in
        
        if let json = json, isComplete {
         
          let episode = APIEpisode(with: json)
          all.append(episode)
        }
        
        count -= 1
        
        if count == 0 {
          self.updateEpisodes(all, completion: completion)
        }
      })
    }
    
  }
  
  private func updateEpisodes(_ all: [APIEpisode], completion : @escaping (_ isSuccess : Bool, _ items : [APIEpisode]?) -> Void) {
    
    var count = all.count
    var allUpdated = [APIEpisode]()

    for episode in all {
      self.updateEpisode(episode: episode, completion: { (isComplete, updatedEpisode) in
        if let updatedEpisode = updatedEpisode, isComplete {
          allUpdated.append(updatedEpisode)
        } else {
          allUpdated.append(episode)
        }
        
        count -= 1
        
        if count == 0 {
          completion(true, allUpdated)
        }
        
      })
    }
  }
  
  private func updateEpisode (episode : APIEpisode, completion : @escaping (_ isSuccess : Bool, _ updatedEpisode : APIEpisode?) -> Void) {
   
    if episode.imageURLs.count == 0 {
      completion(true, episode)
      return
    }
    
    let urlString = baseURL + episode.imageURLs.first!
    self.getJson(forUrlString: urlString) { (isComplete, json) in
      if let json = json, isComplete, let url = json["url"].string {
        let updated = APIEpisode(title: episode.title, subtitle: episode.subtitle, imageURLs: [url])
        completion(true, updated)
      } else {
        completion(true, episode)
      }
    }
    
  }
  
  /**
   Get sets
   */
  func getSets (completion : @escaping (_ isSuccess : Bool, _ set : [APISet]?) -> Void) {
    
    let apiString = "\(baseURL)/api/sets/"
    log.verbose("Getting sets with URL \(apiString)")
    
    self.getJson(forUrlString: apiString) { (isGood, json) in
      if let json = json, isGood {
        let sets = APISet.parse(json)
        
        //update sets
        if let sets = sets {
          self.updateSets(sets, completion: completion)
        } else {
          completion(true, sets)
        }

      } else {
        completion(false, nil)
      }
    }
  }
  
  /**
   Updates an APISet object from the /sets/ endpoint to a full formed APISet with correct images
   
   - parameter set: The APISet to convert
   - returns: APISet
   */
  func updateSet (set : APISet, completion : @escaping (_ isSuccess : Bool, _ set : APISet?) -> Void) {
    
    guard let apiString = set.imageURLs.first else {
      completion(false, nil)
      return
    }
    log.verbose("Getting image information with URL \(apiString)")
    
    
    /// Request
    let queue = DispatchQueue.global(qos: .userInitiated)
    Alamofire.request("\(self.baseURL)\(apiString)").responseJSON(queue: queue) { response in
      
      self.log.verbose("Response for getting set image \(response.response.debugDescription)")
      
      if let result = response.result.value {
        let json = JSON(result)
        guard let url = json["url"].string else {
          DispatchQueue.main.async {
            completion(false, nil)
          }
          return
        }
        
        let newSet = APISet(uid: set.uid, setTypeSlug: set.setTypeSlug, title: set.title, setDescription: set.setDescription, setDescriptionFormatted: set.setDescriptionFormatted, summary: set.summary, imageURLs: [url], items: set.items)
        
        DispatchQueue.main.async {
          completion(true, newSet)
        }
        
      } else {
        DispatchQueue.main.async {
          completion(false, nil)
        }
      }
    }
  }
  
  private func updateSets(_ sets: [APISet], completion : @escaping (_ isSuccess : Bool, _ set : [APISet]?) -> Void) {
    
      var count = sets.count
      var updatedSets = [APISet]()
    
      for set in sets {

        self.updateSet(set: set, completion: { (isComplete, updatedSet) in
          
          if isComplete == true, let updatedSet = updatedSet  {
            updatedSets.append(updatedSet)
          } else {
            updatedSets.append(set)
          }
          
          count -= 1
          print(count)
          
          if count == 0 {
            //all update requests finished
            completion(true, updatedSets)
          }
          
        })
      }
    
  }
  
  private func getJson(forUrlString urlString: String, completion : @escaping (_ isSuccess : Bool, _ json : JSON?) -> Void) {
    
    let queue = DispatchQueue.global(qos: .userInitiated)
    
    Alamofire.request(urlString).responseJSON (queue: queue) { response in
      
      self.log.verbose("Response for getting for url \(urlString) :\n \(response.response.debugDescription)")
      
      if let dict = response.result.value as? NSDictionary {
        
        let json = JSON(dict)
        if json.isEmpty {
          //can consider as a different kind of failure
          
          DispatchQueue.main.async {
            completion(false, nil)
          }
          
        } else {
          DispatchQueue.main.async {
            completion(true, json)
          }
        }
        
      } else {
        DispatchQueue.main.async {
          completion(false, nil)
        }
      }
    }
    
  }
}
