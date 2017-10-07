//
//  SetViewCell.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import UIKit

/** 
  The set view cell that shows a movie on the home screen
 */
class SetViewCell : UITableViewCell {
  
  /// Reuse identifier
  static let identifier = "SetViewCellIdentifier"
  
  /// Image view for the background
  @IBOutlet weak var imgBackground : UIImageView?
  
  /// The title label
  @IBOutlet weak var lblTitle : UILabel?
  
  /// The text view to show the description
  @IBOutlet weak var txtDescription : UITextView?
  
  /// Favourite
  @IBOutlet weak var btnFavourite : FavButton?
  
  /// Gradient layer
  private var gradientLayer: CAGradientLayer?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.selectionStyle = .none
    self.txtDescription?.isScrollEnabled = false
    
    self.addGradient()
  }
  
  private func addGradient() {
    let maskedAlpha = UIColor(white: 0, alpha: 0.2).cgColor
    let visibleAlpha = UIColor(white: 0, alpha: 1.0).cgColor
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = self.bounds
    gradientLayer.colors = [visibleAlpha, maskedAlpha, maskedAlpha]
    
    self.imgBackground?.layer.mask = gradientLayer
    
    self.gradientLayer = gradientLayer
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.imgBackground?.af_cancelImageRequest()
    self.imgBackground?.layer.removeAllAnimations()
    self.imgBackground?.image = nil
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    //unfortunately we have to force the content view to layout
    //(otherwise we might not have the correct frames)
    self.contentView.layoutIfNeeded()
    
    let textBeginOffest = self.lblTitle!.frame.origin.y
    let startFromPortion = max(0.0, Double(textBeginOffest)/Double(self.bounds.size.height) - 0.2)
    let fadePortion = min(1.0, startFromPortion+0.5)
    
    self.gradientLayer?.locations = [NSNumber(value: startFromPortion), NSNumber(value: fadePortion), 1.0]
    self.imgBackground?.layer.mask = self.gradientLayer
  }
}
