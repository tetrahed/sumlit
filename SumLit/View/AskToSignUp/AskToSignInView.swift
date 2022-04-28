//
//  AskToSignInView.swift
//  SumLit
//
//  Created by Junior Etrata on 10/15/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit

protocol AskToSignInProtocol: class {
   func navigateToLogin()
}

class AskToSignInView: UIView {
   
   private let nibName = "AskToSignIn"
   weak var delegate : AskToSignInProtocol?

   @IBOutlet fileprivate weak var signInButton: UIButton!{
      didSet{
         signInButton.roundCorners(by: 5)
         signInButton.addBorder(borderWidth: 2)
      }
   }
   @IBOutlet weak var signInTextLabel: UILabel!
   
   @IBAction fileprivate func allowUserToSignIn(_ sender: UIButton) {
      delegate?.navigateToLogin()
   }
   
   static func instantiate(signInText: String) -> AskToSignInView {
      let view: AskToSignInView = initFromNib()
      view.signInTextLabel.text = signInText
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
   }
}

extension UIView {
   class func initFromNib<T: UIView>() -> T {
      return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?[0] as! T
   }
}
