//
//  PolicyProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 9/25/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol PolicyProtocol {
   func hasUserAcceptedPolicy() -> Bool
   func didAcceptPolicy()
}

extension PolicyProtocol where Self: UIViewController{
   
   fileprivate var policyKey: String {
      return "acceptedPolicy"
   }
   
   func hasUserAcceptedPolicy() -> Bool{
      return UserDefaults.standard.bool(forKey: policyKey)
   }
   
   func didAcceptPolicy(){
      UserDefaults.standard.set(true, forKey: policyKey)
   }
}
