//
//  ForgotPasswordViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 4/8/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import Parse

class ForgotPasswordViewController: AuthViewController
{

   // MARK:- OUTLETS
   @IBOutlet var forgotPasswordView: ForgotPasswordView!
   
   //MARK:- DECLARED VARIABLES
   private var hasPlayedEmailAnimation = false
   
   //MARK:- VIEW LIFECYCLE
   override func viewDidLoad() {
      super.viewDidLoad()
      navigationItem.setHidesBackButton(true, animated: false)
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
      navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
      forgotPasswordView.delegate = self
   }
   
    //MARK:- BUTTON ACTIONS
    @IBAction func resetPassword(_ sender: UIButton)
    {
        guard let email = forgotPasswordView.emailTextField.text, !email.isEmpty, validateEmail(enteredEmail: email) else{
         presentAlertController(title: "Error: Empty Field", message: "Please enter a valid email")
           return
        }
      
        PFUser.requestPasswordResetForEmail(inBackground: email)
        presentAlertController(title: "Password reset", message: "An email containing information on how to reset has been sent. Check your inbox")
         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.navigationController?.popViewController(animated: true)
         })
    }
   
   @objc private func cancelAction(){
      navigationController?.popViewController(animated: true)
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
      if !hasPlayedEmailAnimation {
         hasPlayedEmailAnimation = true
         forgotPasswordView.playEmailAnimation()
      }
   }
}

//MARK:- FORGOTPASSWORD DELEGATE
extension ForgotPasswordViewController: ForgotPasswordViewProtocol{
   func emailLabelTapped() {
      forgotPasswordView.emailTextField.becomeFirstResponder()
   }
}
