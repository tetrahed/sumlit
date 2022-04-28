//
//  AuthViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 5/16/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {

    func validateEmail(enteredEmail : String) -> Bool {
      
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
   
    
    func segueToFeed(usernameOfUser: String){
        UserDefaults.standard.set(usernameOfUser, forKey: "userLoggedIn")
        UserDefaults.standard.synchronize()
      
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.rememberLogin()
    }
}
