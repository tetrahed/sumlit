//
//  ForgotPasswordViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/5/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

struct ForgotPasswordViewModel: AuthViewModelProtocol{
   
   private let authService: AuthService
   
   init(authService: AuthService = AuthService()) {
      self.authService = authService
   }
   
   fileprivate func validate(email: String) -> Error?{
      if let error = validateEmail(email: email) {
         return error
      }
      return nil
   }
   
   func performReset(emailText: String?, completion: @escaping ((Error?) -> Void)){
      
      guard let email = emailText else {
         completion(CustomErrors.GeneralErrors.unknownError)
         return
      }
      
      if let error = validate(email: email){
         completion(error)
      }
      
      authService.performReset(email: email) { (result) in
         switch result{
         case .success(_):
            completion(nil)
         case .failure(let error):
            completion(error)
         }
      }
   }
   
}
