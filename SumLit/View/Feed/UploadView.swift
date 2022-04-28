//
//  UploadView.swift
//  SumLit
//
//  Created by Junior Etrata on 8/15/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class UploadView: UIView
{
   @IBOutlet private(set) weak var newsLinkTextField: UITextField!
   @IBOutlet private(set) weak var continueButton: UIButton!{
      didSet{
         continueButton.roundCorners(by: 5)
      }
   }
   @IBOutlet fileprivate weak var linkButton: UIButton!
   @IBOutlet fileprivate weak var titleLabel: UILabel!{
      didSet{
         titleLabel.highlightWord(originalText: "What's going on?", highlightedWord: "?")
      }
   }
   
   let askToSignInView = AskToSignInView.instantiate(signInText: "Sign in is required before creating a new post.")
   
   private(set) var hasMovedLinkButton = false
   var wasUploading = false
}

//MARK:- PUBLIC API
extension UploadView{
   func moveLinkbutton(){
      if !hasMovedLinkButton{
         hasMovedLinkButton = true
         linkButton.isUserInteractionEnabled = false
        if #available(iOS 13.0, *) {
            linkButton.setTitleColor(.label, for: .normal)
        } else {
            // Fallback on earlier versions
            linkButton.setTitleColor(.black, for: .normal)
        }
         UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.linkButton.transform = CGAffineTransform(translationX: 0, y: -40)
         }) { (_) in }
         newsLinkTextField.placeholder = "Paste the article's URL here."
      }
   }
   
   func displaySignInView(){
      self.addSubview(askToSignInView)
      askToSignInView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
      askToSignInView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
      askToSignInView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
      askToSignInView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
   }
}
