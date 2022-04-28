//
//  InitialService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/13/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Firebase

class InitialService{
   
   typealias ResponseHandler = ((Bool) -> Void)
   
   func isValidSession(completion: @escaping ResponseHandler){
      if let user = Auth.auth().currentUser,
         user.isEmailVerified{
         let validUsersRef = Constants.FirebaseRefs.validUsersRef.child(user.uid)
         validUsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists(){
               completion(true)
            }else{
               completion(false)
            }
         }) { (_) in
            completion(false)
         }
      }else{
         completion(false)
      }
   }
}
