//
//  ForgotPasswordViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 4/8/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import Parse
import Firebase
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
<<<<<<< HEAD
        forgotPasswordView.passwordResetButton.addActivityIndicator()
        resetPassword()
    }
}

//MARK:- ForgotPasswordProtocol
extension ForgotPasswordViewController: ForgotPasswordProtocol{
   
   func resetPassword() {
      if let error = forgotPasswordViewModel.performReset(emailText: forgotPasswordView.emailTextField.text){
         presentAlertController(title: "Password Reset Error", message: error.localizedDescription)
      }else{
         presentAlertController(title: "Password reset", message: "An email containing information on how to reset has been sent. Check your inbox")
=======
        guard let email = forgotPasswordView.emailTextField.text, !email.isEmpty, validateEmail(enteredEmail: email) else{
         presentAlertController(title: "Error: Empty Field", message: "Please enter a valid email")
           return
        }
        
        
        //PFUser.requestPasswordResetForEmail(inBackground: email)
        Auth.auth().sendPasswordReset(withEmail: email, completion: {(error) in
            if error != nil {
                self.presentAlertController(title: "Error", message: error!.localizedDescription)
            }
            else {
                self.presentAlertController(title: "Password reset", message: "An email containing information on how to reset has been sent. Check your inbox")
            }
        })
>>>>>>> 2ea36f449724f44b11c645dc79e1f8d504fea7fa
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.navigationController?.popViewController(animated: true)
         })
      }
      forgotPasswordView.passwordResetButton.removeActivityIndicator()
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
