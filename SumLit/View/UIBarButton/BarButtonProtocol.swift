//
//  BarButtonProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 9/9/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol BarButtonProtocol {
   func hideButton()
   func showButton(color: UIColor)
}

extension BarButtonProtocol where Self: UIBarButtonItem{
   
   func hideButton(){
      self.tintColor = .clear
      self.isEnabled = false
   }
   
   func showButton(color: UIColor = Constants.Colors.darkColor){
      self.tintColor = color
      self.isEnabled = true
   }
}

extension UIBarButtonItem: BarButtonProtocol { }
