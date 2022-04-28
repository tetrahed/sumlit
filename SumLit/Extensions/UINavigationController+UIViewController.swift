//
//  UINavigationController+UIViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 5/11/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

extension UIViewController {
   
   func navigateWithNCTo(storyboard: String, identifer: String){
      let vc = UIStoryboard.init(name: storyboard, bundle: Bundle.main).instantiateViewController(withIdentifier: identifer)
      navigationController?.pushViewController(vc, animated: true)
   }
}
