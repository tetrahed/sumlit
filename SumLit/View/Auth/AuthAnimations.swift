//
//  AuthAnimations.swift
//  SumLit
//
//  Created by Junior Etrata on 9/9/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol AuthAnimationsProtocol {
   func placeUIElementsIntoStartingPositions()
   func playTextfieldAnimation(label: UILabel, beginPoint: NSLayoutConstraint, endPoint: CGFloat)
   func moveTitleAndMainButtonIntoView(title: UILabel, button: UIButton, startDelay: TimeInterval)
   func moveTextfieldsIntoView(stackViews: [UIStackView], startDelay: TimeInterval)
   func moveUIElementsIntoView()
}

extension AuthAnimationsProtocol where Self: UIView{
   
   var screenSize: CGRect {
      return UIScreen.main.bounds
   }
   
   func playTextfieldAnimation(label: UILabel, beginPoint: NSLayoutConstraint, endPoint: CGFloat){
      UIView.transition(with: label, duration: 0.25, options: .transitionCrossDissolve, animations: {
        if #available(iOS 13.0, *) {
            label.textColor = UIColor.label
        } else {
            label.textColor = .black
            // Fallback on earlier versions
        }
      }, completion: nil)
      UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
         beginPoint.constant = endPoint
         self.layoutIfNeeded()
      }) { (_) in }
   }
   
   func moveTitleAndMainButtonIntoView(title: UILabel, button: UIButton, startDelay: TimeInterval = 0.1) {
      UIView.animate(withDuration: 0.8, delay: startDelay, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
         title.transform = CGAffineTransform.identity
         button.transform = CGAffineTransform.identity
         button.alpha = 1
      }) { (_) in }
   }
   
   func moveTextfieldsIntoView(stackViews: [UIStackView], startDelay: TimeInterval = 0.4) {
      let stackTransform = CGAffineTransform(translationX: -screenSize.width, y: 0).scaledBy(x: 4, y: 1)
      UIView.animate(withDuration: 0.2, delay: startDelay, options: .curveEaseIn, animations: {
         for stackView in stackViews{
            stackView.transform = stackTransform
         }
      }) { (_) in
         UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            for stackView in stackViews{
               stackView.transform = CGAffineTransform.identity
            }
         }, completion: { (_) in })
      }
   }
}
