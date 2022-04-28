//
//  ConfirmPolicyView.swift
//  SumLit
//
//  Created by Junior Etrata on 9/25/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class ConfirmPolicyView: UIView {

   @IBOutlet fileprivate weak var policyTextView: UITextView!{
      didSet{
         policyTextView.addPadding(top: 10, bottom: 10, left: 10, right: 10)
      }
   }
   @IBOutlet fileprivate weak var agreeButton: UIButton!{
      didSet{
         agreeButton.roundCorners(by: 5)
      }
   }
   @IBOutlet weak var policyBackgroundView: UIView!{
      didSet{
         policyBackgroundView.applyShadows()
         policyBackgroundView.roundCorners(by: 10)
        policyBackgroundView.layer.borderColor = UIColor.white.cgColor
        policyBackgroundView.layer.borderWidth = 1
      }
   }
}

//MARK:- PUBLIC API
extension ConfirmPolicyView{
   func setPolicy(text: NSMutableAttributedString){
      policyTextView.attributedText = text
   }
   
   func scrollTextViewToTop(){
      policyTextView.scrollToTop()
   }
}
