//
//  UIButton+ActivityIndicator.swift
//  SumLit
//
//  Created by Junior Etrata on 9/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol ButtonWithActivityIndicator{
   func addActivityIndicatorWithShadow()
   func removeActivityIndicatorWithShadow()
   func addActivityIndicator()
   func removeActivityIndicator()
}

extension ButtonWithActivityIndicator where Self: UIButton{
   func addActivityIndicatorWithShadow(){
      self.layer.shadowOpacity = 0
    if #available(iOS 13.0, *) {
        QuickSetupSpinner.start(from: self, style: .whiteLarge, backgroundColor: UIColor.init(named: "Label Opposite")!, baseColor: UIColor.label)
    } else {
        // Fallback on earlier versions
        QuickSetupSpinner.start(from: self, style: .whiteLarge, backgroundColor: UIColor.init(named: "Label Opposite")!, baseColor: UIColor.black)
    }
   }
   
   func removeActivityIndicatorWithShadow(){
      self.layer.shadowOpacity = defaultShadowOpacity
      QuickSetupSpinner.stop()
   }
   
   func addActivityIndicator(){
    if #available(iOS 13.0, *) {
        QuickSetupSpinner.start(from: self, style: .whiteLarge, backgroundColor: UIColor.init(named: "Label Opposite")!, baseColor: UIColor.label)
    } else {
        QuickSetupSpinner.start(from: self, style: .whiteLarge, backgroundColor: UIColor.init(named: "Label Opposite")!, baseColor: UIColor.black)
        // Fallback on earlier versions
    }
   }
   
   func removeActivityIndicator(){
      QuickSetupSpinner.stop()
   }
}

extension UIButton : ButtonWithActivityIndicator { }
