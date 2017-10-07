//
//  FavButton.swift
//  ostest
//
//  Created by Denis Kim on 06/10/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import UIKit

class FavButton: UIButton {
  
  private var customImageView: UIImageView?
  var tappedHandler: ((_ button: FavButton) -> Void)?
  
  func setIsFavourite(_ isFavourite: Bool, animated: Bool) {
    
    let block = {
      if (isFavourite) {
        self.customImageView?.tintColor = UIColor.red
      } else {
        self.customImageView?.tintColor = UIColor.gray
      }
    }
    
    if animated {
      UIView.animate(withDuration: 0.3) {
        block()
      }
    } else {
      block()
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.customImageView = UIImageView(frame: self.bounds)
    self.customImageView?.contentMode = .scaleAspectFit
    self.customImageView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.addSubview(self.customImageView!)
    
    if let image = UIImage(named: "heart")?.withRenderingMode(.alwaysTemplate){
      self.customImageView?.image = image
    }
    
    self.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
  }
  
  @objc private func tapped(_ button: FavButton) {
    if let tappedHandler = self.tappedHandler {
      tappedHandler(self)
    }
  }
}
