//
//  ViewRules.swift
//  SumLit
//
//  Created by Junior Etrata on 9/25/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class CommunityGuidelinesView: UIView {

   @IBOutlet fileprivate weak var rulesTextView: UITextView!{
      didSet{
         rulesTextView.addPadding(top: 10, bottom: 10, left: 10, right: 10)
      }
   }
}

//MARK:- PUBLIC API
extension CommunityGuidelinesView{
   func setTextView(text: NSMutableAttributedString){
      rulesTextView.attributedText = text
   }
   
   func scrollTextViewToTop(){
      rulesTextView.scrollToTop()
   }
}
