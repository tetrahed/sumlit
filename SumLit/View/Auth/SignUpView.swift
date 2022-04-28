//
//  SignUpView.swift
//  SumLit
//
//  Created by Junior Etrata on 5/11/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class SignUpView : UIView {
   
   //MARK:- DECLARED VARIABLES
   fileprivate var hasPlayedInitialAnimation = false
   fileprivate var hasPlayedUsernameAnimation = false
   fileprivate var hasPlayedEmailAnimation = false
   fileprivate var hasPlayedPasswordAnimation = false
   
   //MARK:- OUTLETS
   @IBOutlet weak var usernameTextField: UITextField!
   @IBOutlet weak var emailTextField: UITextField!
   @IBOutlet weak var passwordTextField: UITextField!
   @IBOutlet weak var titleLabel: UILabel!{
      didSet{
         titleLabel.alpha = 0
         titleLabel.highlightWord(originalText: "Create an\naccount", highlightedWord: "account")
      }
   }
   @IBOutlet weak var usernameLabel: UILabel!{
      didSet{
         usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(usernameLabelTapped)))
      }
   }
   @IBOutlet weak var emailLabel: UILabel!{
      didSet{
         emailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emailLabelTapped)))
      }
   }
   @IBOutlet weak var passwordLabel: UILabel!{
      didSet{
         passwordLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(passwordLabelTapped)))
      }
   }
   @IBOutlet weak var passwordLine: UIView!
   @IBOutlet weak var emailLine: UIView!
   @IBOutlet weak var usernameLine: UIView!
   @IBOutlet weak var scrollView: UIScrollView!
   @IBOutlet weak var signupButton: UIButton!{
      didSet{
         signupButton.alpha = 0
         signupButton.roundCorners(by: 5)
      }
   }
   @IBOutlet weak var usernameStackView: UIStackView!
   @IBOutlet weak var emailStackView: UIStackView!
   @IBOutlet weak var passwordStackView: UIStackView!
   
   //MARK:- OUTLET CONSTRAINTS
   @IBOutlet weak var usernameLineLeadingConstraint: NSLayoutConstraint!
   @IBOutlet weak var emailLineLeadingConstraint: NSLayoutConstraint!
   @IBOutlet weak var passwordLineLeadingConstraint: NSLayoutConstraint!
   
   //MARK:- VIEW LIFECYCLE
   override func awakeFromNib() {
      super.awakeFromNib()
      placeUIElementsIntoStartingPositions()
   }
}

//MARK:- PUBLIC API
extension SignUpView: AuthAnimationsProtocol{
   
   func placeUIElementsIntoStartingPositions() {
      titleLabel.transform = CGAffineTransform(translationX: -screenSize.width, y: 0)
      signupButton.transform = CGAffineTransform(translationX: 0, y: screenSize.height)
      usernameStackView.transform = CGAffineTransform(translationX: -screenSize.width, y: 0)
      emailStackView.transform = CGAffineTransform(translationX: -screenSize.width, y: 0)
      passwordStackView.transform = CGAffineTransform(translationX: -screenSize.width, y: 0)
   }
   
   func moveUIElementsIntoView() {
      if !hasPlayedInitialAnimation{
         hasPlayedInitialAnimation = true
         titleLabel.alpha = 1
         signupButton.alpha = 1
         moveTitleAndMainButtonIntoView(title: titleLabel, button: signupButton, startDelay: 0.2)
         moveTextfieldsIntoView(stackViews: [usernameStackView,emailStackView,passwordStackView], startDelay: 0.5)
      }
   }
   
   func playUsernameAnimation(){
      if !hasPlayedUsernameAnimation{
         hasPlayedUsernameAnimation = !hasPlayedUsernameAnimation
         playTextfieldAnimation(label: usernameLabel, beginPoint: usernameLineLeadingConstraint, endPoint: usernameLine.frame.maxX)
      }
   }
   
   func playEmailAnimation(){
      if !hasPlayedEmailAnimation{
         hasPlayedEmailAnimation = !hasPlayedEmailAnimation
         playTextfieldAnimation(label: emailLabel, beginPoint: emailLineLeadingConstraint, endPoint: emailLine.frame.maxX)
      }
   }
   
   func playPasswordAnimation(){
      if !hasPlayedPasswordAnimation{
         hasPlayedPasswordAnimation = !hasPlayedPasswordAnimation
         playTextfieldAnimation(label: passwordLabel, beginPoint: passwordLineLeadingConstraint, endPoint: passwordLine.frame.maxX)
      }
   }
}

//MARK:- PRIVATE METHODS
extension SignUpView{
   
   @objc fileprivate func usernameLabelTapped(){
      usernameTextField.becomeFirstResponder()
   }
   
   @objc fileprivate func emailLabelTapped(){
      emailTextField.becomeFirstResponder()
   }
   
   @objc fileprivate func passwordLabelTapped(){
      passwordTextField.becomeFirstResponder()
   }
}
