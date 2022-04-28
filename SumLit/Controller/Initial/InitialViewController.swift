//
//  InitialViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 9/13/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
   
   private let initialViewModel = InitialViewModel()

   //MARK:- VIEW LIFECYCLE
   override func viewDidLoad() {
      super.viewDidLoad()
      if !hasUserAcceptedPolicy(){
         navigateToLogin()
      }else{
         isUserSessionValid()
      }
   }
}

//MARK:- NETWORK CALLS
extension InitialViewController {
   
    func isUserSessionValid(){
        UserService.shared.isValidSession { [weak self] (isValid) in
            if isValid{
                DispatchQueue.global().async {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        self?.navigateToMainTab()
                    }
                }
            }else{
                UserService.shared.signInAnonymousSessionIfNeeded(completion: { (error) in
                    DispatchQueue.global().async {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            if error != nil{
                                self?.navigateToLogin()
                            }else{
                                self?.navigateToMainTab()
                            }
                        }
                    }
                })
            }
        }
    }
}

//MARK:- Navigate
extension InitialViewController: PolicyProtocol{
   func navigateToMainTab(){
      setRootViewController(storyboard: "MainTab", identifier: "MainTab")
   }
   
   func navigateToLogin(){
      if hasUserAcceptedPolicy(){
         setRootViewController(storyboard: "Auth", identifier: "NavigationController")
      }else{
         setRootViewController(storyboard: "ConfirmPolicy", identifier: "ConfirmPolicyViewController")
      }
   }
}
