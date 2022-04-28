//
//  UIViewEssentials.swift
//  SumLit
//
//  Created by Junior Etrata on 9/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol UIViewEssentials{
   func roundCorners()
   func roundCorners(by value: CGFloat)
   func applyShadows()
   func applyShadows(opacity: Float, radius: CGFloat, offset: CGSize)
   func addBorder(borderColor: CGColor, borderWidth: CGFloat)
}

extension UIViewEssentials where Self: UIView{
   
   var defaultShadowOpacity: Float {
      return 0.4
   }
   
   func roundCorners(){
      self.layer.cornerRadius = self.frame.height/2
   }
   
   func roundCorners(by value: CGFloat){
      self.layer.cornerRadius = value
   }
   
   func addBorder(borderColor: CGColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), borderWidth: CGFloat){
      self.layer.borderColor = borderColor
      self.layer.borderWidth = borderWidth
   }

   func applyShadows(){
      self.layer.shadowColor = UIColor.black.cgColor
      self.layer.shadowOpacity = defaultShadowOpacity
      self.layer.shadowOffset = CGSize(width: 0, height: 3)
      self.layer.shadowRadius = 2
   }
   
   func applyShadows(opacity: Float, radius: CGFloat, offset: CGSize){
      self.layer.shadowColor = UIColor.black.cgColor
      self.layer.shadowOpacity = opacity
      self.layer.shadowOffset = offset
      self.layer.shadowRadius = radius
   }
}

extension UIView : UIViewEssentials { }
