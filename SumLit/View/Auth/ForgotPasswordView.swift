//
//  ForgotPasswordView.swift
//  SumLit
//
//  Created by Junior Etrata on 5/11/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class ForgotPasswordView: UIView {
   
   //MARK:- DECLARED VARIABLES
   fileprivate var hasPlayedEmailAnimation = false
   fileprivate var hasPlayedInitialAnimation = false
   
   // MARK:- OUTLETS
   @IBOutlet private(set) weak var emailTextField: UITextField!
   @IBOutlet fileprivate weak var titleLabel: UILabel!{
      didSet{
         titleLabel.alpha = 0
         titleLabel.highlightWord(originalText: "Forgot\nPassword", highlightedWord: "Password")
      }
   }
   @IBOutlet private(set) weak var passwordResetButton: UIButton!{
      didSet{
         //passwordResetButton.applyShadows()
         passwordResetButton.alpha = 0
         passwordResetButton.roundCorners(by: 5)
      }
   }
   @IBOutlet fileprivate weak var emailLabel: UILabel!{
      didSet{
         emailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emailLabelTapped)))
      }
   }
   @IBOutlet fileprivate weak var emailLine: UIView!
   @IBOutlet weak var emailStackView: UIStackView!{
      didSet{
         emailStackView.alpha = 0
      }
   }
   
   //MARK:- OUTLET CONSTRAINTS
   @IBOutlet weak var emailLineLeadingConstraint: NSLayoutConstraint!
   
   //MARK:- VIEW LIFECYCLE
   override func awakeFromNib() {
      super.awakeFromNib()
      placeUIElementsIntoStartingPositions()
   }
}

//MARK:- PUBLIC API
extension ForgotPasswordView: AuthAnimationsProtocol{
   
   func moveUIElementsIntoView() {
      if !hasPlayedInitialAnimation{
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.titleLabel.alpha = 1
            self.emailStackView.alpha = 1
        }
         hasPlayedInitialAnimation = true
         moveTitleAndMainButtonIntoView(title: titleLabel, button: passwordResetButton, startDelay: 0.4)
         moveTextfieldsIntoView(stackViews: [emailStackView], startDelay: 0.7)
      }
   }
   
   func placeUIElementsIntoStartingPositions() {
      titleLabel.transform = CGAffineTransform(translationX: -screenSize.width, y: 0)
      passwordResetButton.transform = CGAffineTransform(translationX: 0, y: screenSize.height)
      emailStackView.transform = CGAffineTransform(translationX: -screenSize.width, y: 0)
   }
   
   func playEmailAnimation(){
      if !hasPlayedEmailAnimation{
         hasPlayedEmailAnimation = true
         playTextfieldAnimation(label: emailLabel, beginPoint: emailLineLeadingConstraint, endPoint: emailLine.frame.maxX)
      }
   }
}

//MARK:- PRIVATE METHODS
extension ForgotPasswordView{
   
   @objc private func emailLabelTapped(){
      emailTextField.becomeFirstResponder()
   }
}
