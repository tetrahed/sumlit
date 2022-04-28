//
//  GradientView.swift
//  SumLit
//
//  Created by Junior Etrata on 10/26/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit

class GradientView: UIView {
   override open class var layerClass: AnyClass {
      return CAGradientLayer.classForCoder()
   }
   
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      let gradientLayer = layer as! CAGradientLayer
      gradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.9800000191, green: 0.9800000191, blue: 0.9800000191, alpha: 1).cgColor, #colorLiteral(red: 0.9399999976, green: 0.9399999976, blue: 0.9399999976, alpha: 1).cgColor, #colorLiteral(red: 0.9100000262, green: 0.9100000262, blue: 0.9100000262, alpha: 1).cgColor]
      layer.cornerRadius = 5
   }
}
