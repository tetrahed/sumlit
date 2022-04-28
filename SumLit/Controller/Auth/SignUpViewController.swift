//
//  SignUpViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 4/8/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController
{
    
    // MARK:- OUTLETS
   @IBOutlet var signUpView: SignUpView!
   let signUpViewModel = SignUpViewModel()
   
   //MARK:- VIEW LIFECYCLE
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      signUpView.moveUIElementsIntoView()
   }
   
    // MARK:- BUTTON ACTION - SIGN UP
    @IBAction func createAccount(_ sender: UIButton)
    {
      view.endEditing(true)
      signUpView.signupButton.addActivityIndicator()
      performSignUp()
    }
}

//MARK:- SignUpProtocol
extension SignUpViewController: SignUpProtocol{
   
   func performSignUp() {
      signUpViewModel.performSignUp(usernameText: signUpView.usernameTextField.text, emailText: signUpView.emailTextField.text, passwordText: signUpView.passwordTextField.text) { [weak self] (error) in
         self?.signUpView.signupButton.removeActivityIndicator()
         if let error = error{
            self?.presentCustomAlertOnMainThread(title: "Sign up error", message: FirebaseErrorHelper.convertErrorToMessage(error: error))
         }else{
            self?.presentCustomAlertOnMainThread(title: "Success!", message: "Your account is created. Check your email inbox to finish verification.")
         }
      }
   }
}

// MARK:- TEXTFIELD DELEGATE
extension SignUpViewController : UITextFieldDelegate
{
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField
        {
        case signUpView.usernameTextField:
            signUpView.emailTextField.becomeFirstResponder()
        case signUpView.emailTextField:
            signUpView.passwordTextField.becomeFirstResponder()
        case signUpView.passwordTextField:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
   
   func textFieldDidBeginEditing(_ textField: UITextField) {
      switch textField {
      case signUpView.usernameTextField:
         signUpView.playUsernameAnimation()
      case signUpView.emailTextField:
         signUpView.playEmailAnimation()
      case signUpView.passwordTextField:
         signUpView.playPasswordAnimation()
      default:
         break
      }
   }
}
