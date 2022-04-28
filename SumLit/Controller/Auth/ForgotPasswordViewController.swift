//
//  ForgotPasswordViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 4/8/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController
{

   @IBOutlet var forgotPasswordView: ForgotPasswordView!
   let forgotPasswordViewModel = ForgotPasswordViewModel()
   
   //MARK:- VIEW LIFECYCLE
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      forgotPasswordView.moveUIElementsIntoView()
   }
   
    //MARK:- BUTTON ACTIONS
    @IBAction func resetPassword(_ sender: UIButton)
    {
        forgotPasswordView.passwordResetButton.addActivityIndicator()
        resetPassword()
    }
}

//MARK:- ForgotPasswordProtocol
extension ForgotPasswordViewController: ForgotPasswordProtocol{
   
   func resetPassword() {
      forgotPasswordViewModel.performReset(emailText: forgotPasswordView.emailTextField.text) { [weak self] (error) in
         if let error = error{
            self?.presentCustomAlertOnMainThread(title: "Password reset error", message: FirebaseErrorHelper.convertErrorToMessage(error: error))
            self?.forgotPasswordView.passwordResetButton.removeActivityIndicator()
         }else{
            self?.presentCustomAlertOnMainThread(title: "Success!", message: "An email containing information on how to reset has been sent. Check your inbox.")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
               self?.navigationController?.popViewController(animated: true)
            })
         }
      }
   }
}

// MARK:- TEXTFIELD DELEGATES
extension ForgotPasswordViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
   
   func textFieldDidBeginEditing(_ textField: UITextField) {
      forgotPasswordView.playEmailAnimation()
   }
   
   func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
      guard let text = textField.text else { return true}
      textField.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
      return true
   }
}
