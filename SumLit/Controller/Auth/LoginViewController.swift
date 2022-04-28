//
//  LoginViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 4/8/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController
{
    
    var loginViewModel = LoginViewModel()
    @IBOutlet var loginView : LoginView!
    
    //MARK:- VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButton()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        loginView.moveUIElementsIntoView()
    }
    
    // MARK:- BUTTON ACTION - LOGIN
    @IBAction func handleLoginPressed(_ sender: UIButton)
    {
        view.endEditing(true)
        performLogin(email: loginView.emailTextField.text, password: loginView.passwordTextField.text)
    }
    
    @IBAction func signInAsAnonymous(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            sender.addActivityIndicator()
            self?.loginView.setupBeforeSigningAsAnon()
        }
        UserService.shared.signInAnonymousSessionIfNeeded { [weak self] (error) in
            DispatchQueue.main.async { [weak self] in
                sender.removeActivityIndicator()
                self?.loginView.setupAfterSigningAsAnon()
            }
            if error != nil{
                self?.presentCustomAlertOnMainThread(title: "Error", message: "Please try again.")
            }else{
                self?.navigateToFeed()
            }
        }
    }
}

//MARK:- LoginProtocol
extension LoginViewController: LoginProtocol{
    
    func navigateToFeed() {
        navigateTo(storyboard: "MainTab", identifier: "MainTab")
    }
    
    func performLogin(email: String?, password: String?) {
        loginView.loginButton.addActivityIndicator()
        loginView.setupBeforeLogin()
        loginViewModel.performLogin(emailText: email, passwordText: password) { [weak self] (result) in
            DispatchQueue.main.async { [weak self] in
                self?.loginView.loginButton.removeActivityIndicator()
                self?.loginView.setupAfterLogin()
            }
            switch result{
            case .success(let verified):
                if verified{
                    self?.navigateToFeed()
                }else{
                    self?.presentCustomAlertOnMainThread(title: "Email verification", message: "Check your email to verify your account.")
                    self?.navigationItem.rightBarButtonItem?.showButton()
                }
            case .failure(let error):
                self?.presentCustomAlertOnMainThread(title: "Login error", message: FirebaseErrorHelper.convertErrorToMessage(error: error))
            }
        }
    }
    
    @objc func resendVerification() {
        loginViewModel.performResend()
        navigationItem.rightBarButtonItem?.hideButton()
        presentCustomAlertOnMainThread(title: "Success!", message: "Check your email to verify your account.")
    }
}

//MARK:- SETUP
extension LoginViewController{
    func setupBarButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Resend Verification", style: .plain, target: self, action: #selector(resendVerification))
        navigationItem.rightBarButtonItem?.hideButton()
    }
}

// MARK:- TEXTFIELD DELEGATE
extension LoginViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        switch textField
        {
        case loginView.emailTextField:
            loginView.passwordTextField.becomeFirstResponder()
        case loginView.passwordTextField:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        switch textField
        {
        case loginView.emailTextField:
            loginView.playEmailAnimation()
        case loginView.passwordTextField:
            loginView.playPasswordAnimation()
        default:
            return
        }
    }
}
