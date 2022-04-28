//
//  Navigation+UIViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 9/13/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

extension UIViewController {
   
   func setRootViewController(storyboard: String, identifier: String){
      let mainStoryboard: UIStoryboard = UIStoryboard(name: storyboard, bundle: nil)
      let viewController = mainStoryboard.instantiateViewController(withIdentifier: identifier)
      let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
      appDelegate.window?.rootViewController = viewController
   }
   
   func navigateFromRootTo(storyboard: String, identifier: String){
      let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
      appDelegate.window?.rootViewController?.navigateTo(storyboard: storyboard, identifier: identifier)
   }
   
   func navigateTo(storyboard: String, identifier: String){
      let storyBoard: UIStoryboard = UIStoryboard(name: storyboard, bundle: nil)
      let newViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
      newViewController.modalPresentationStyle = .overFullScreen
      self.present(newViewController, animated: true, completion: nil)
   }
}
