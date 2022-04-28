//
//  LoginView.swift
//  SumLit
//
//  Created by Junior Etrata on 5/11/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class LoginView : UIView{
   
   //MARK:- DECLARED VARIABLES
   fileprivate var didMoveElementsIntoView = false
   fileprivate var hasPlayedEmailAnimation = false
   fileprivate var hasPlayedPasswordAnimation = false
   
   // MARK:- OUTLETS
   @IBOutlet private(set) var emailTextField: UITextField!
   @IBOutlet private(set) var passwordTextField: UITextField!
   @IBOutlet fileprivate weak var loginTitleLabel: UILabel!{
      didSet{
         loginTitleLabel.highlightWord(originalText: "Welcome to\nSumlit", highlightedWord: "Sumlit")
      }
   }
   @IBOutlet private(set) weak var loginButton: UIButton!{
      didSet{
         loginButton.alpha = 0
         loginButton.removeActivityIndicator()
         loginButton.roundCorners(by: 5)
      }
   }
   @IBOutlet fileprivate weak var emailLabel: UILabel!{
      didSet{
         emailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedEmailLabel)))
      }
   }
   @IBOutlet fileprivate weak var emailLine: UIView!
   @IBOutlet fileprivate weak var passwordLabel: UILabel!{
      didSet{
         passwordLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedPasswordLabel)))
      }
   }
   @IBOutlet fileprivate weak var passwordLine: UIView!
   @IBOutlet fileprivate weak var emailStackView: UIStackView!
   @IBOutlet fileprivate weak var passwordStackView: UIStackView!
   @IBOutlet weak var otherButtonsStackView: UIStackView!{
      didSet{
         otherButtonsStackView.alpha = 0
      }
   }
   @IBOutlet weak var signUpButton: UIButton!
   @IBOutlet weak var forgotPasswordButton: UIButton!
   @IBOutlet weak var goToFeedButton: UIButton!
   
   // MARK:- OUTLET CONSTRAINTS
   @IBOutlet fileprivate weak var passwordLineLeftConstraint: NSLayoutConstraint!
   @IBOutlet fileprivate weak var usernameLineLeftConstraint: NSLayoutConstraint!
   
   //MARK:- VIEW LIFECYCLE
   override func awakeFromNib() {
      super.awakeFromNib()
      placeUIElementsIntoStartingPositions()
   }
}

//MARK:- PRIVATE METHODS
extension LoginView{
   
   @objc fileprivate func tappedEmailLabel(){
      emailTextField.becomeFirstResponder()
   }
   
   @objc fileprivate func tappedPasswordLabel(){
      passwordTextField.becomeFirstResponder()
   }
   
   fileprivate func moveOtherButtonsIntoView(){
      UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.3, options: .curveEaseIn, animations: { [weak self] in
         self?.otherButtonsStackView.transform = CGAffineTransform.identity
         self?.otherButtonsStackView.alpha = 1
      }) { (_) in }
   }
   
   fileprivate func hideSignUpAndForgotPasswordButton(){
      signUpButton.alpha = 0.5
      signUpButton.isUserInteractionEnabled = false
      forgotPasswordButton.alpha = 0.5
      forgotPasswordButton.isUserInteractionEnabled = false
   }
   
   fileprivate func showSignUpAndForgotPasswordButton(){
      signUpButton.alpha = 1
      signUpButton.isUserInteractionEnabled = true
      forgotPasswordButton.alpha = 1
      forgotPasswordButton.isUserInteractionEnabled = true
   }
}

//MARK:- PUBLIC API
extension LoginView: AuthAnimationsProtocol{
   
   func playEmailAnimation(){
      if !hasPlayedEmailAnimation{
         playTextfieldAnimation(label: emailLabel, beginPoint: usernameLineLeftConstraint, endPoint: emailLine.frame.maxX)
         hasPlayedEmailAnimation = true
      }
   }
   
   func playPasswordAnimation(){
      if !hasPlayedPasswordAnimation{
         playTextfieldAnimation(label: passwordLabel, beginPoint: passwordLineLeftConstraint, endPoint: passwordLine.frame.maxX)
         hasPlayedPasswordAnimation = true
      }
   }
   
   func placeUIElementsIntoStartingPositions(){
      loginTitleLabel.transform = CGAffineTransform(translationX: -screenSize.width, y: 0)
      loginButton.transform = CGAffineTransform(translationX: 0, y: screenSize.height)
      emailStackView.transform = CGAffineTransform(translationX: -screenSize.width, y: 0)
      passwordStackView.transform = CGAffineTransform(translationX: -screenSize.width, y: 0)
      otherButtonsStackView.transform = CGAffineTransform(translationX: 0, y: screenSize.height)
   }
   
   func moveUIElementsIntoView(){
      if !didMoveElementsIntoView{
         moveTitleAndMainButtonIntoView(title: loginTitleLabel, button: loginButton)
         moveTextfieldsIntoView(stackViews: [emailStackView,passwordStackView])
         moveOtherButtonsIntoView()
         didMoveElementsIntoView = true
      }
   }
   
   func setupBeforeSigningAsAnon(){
      loginButton.isUserInteractionEnabled = false
      loginButton.alpha = 0.5
      hideSignUpAndForgotPasswordButton()
   }
   
   func setupAfterSigningAsAnon(){
      loginButton.isUserInteractionEnabled = true
      loginButton.alpha = 1
      showSignUpAndForgotPasswordButton()
   }
   
   func setupBeforeLogin(){
      goToFeedButton.isUserInteractionEnabled = true
      goToFeedButton.alpha = 0.5
      hideSignUpAndForgotPasswordButton()
   }
   
   func setupAfterLogin(){
      goToFeedButton.isHidden = false
      goToFeedButton.alpha = 1
      showSignUpAndForgotPasswordButton()
   }
}
