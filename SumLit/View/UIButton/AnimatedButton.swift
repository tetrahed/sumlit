//
//  AnimatedButton.swift
//  SumLit
//
//  Created by Junior Etrata on 9/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class AnimatedButton: UIButton {

   @IBInspectable
   var transformScale: CGFloat = 0.9
    
   override var isHighlighted: Bool {
      didSet {
         let transform: CGAffineTransform = isHighlighted ? .init(scaleX: transformScale, y: transformScale) : .identity
         animate(transform)
      }
   }
}

private extension AnimatedButton {
   private func animate(_ transform: CGAffineTransform) {
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3, options: [.curveEaseInOut], animations: {
         self.transform = transform
      })
   }
}
