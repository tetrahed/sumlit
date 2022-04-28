//
//  LoginViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

struct LoginViewModel: AuthViewModelProtocol{
   
   private let authService: AuthService
   
   init(authService: AuthService = AuthService()) {
      self.authService = authService
   }
   
   fileprivate func validate(email: String, password: String) -> Error?{
      if let error = validateEmail(email: email){
         return error
      }
      
      if let error = validatePassword(password: password){
         return error
      }
      return nil
   }
   
   func performLogin(emailText: String?, passwordText: String?, completion: @escaping AuthService.ResponseHandler){
      
      guard let email = emailText, let password = passwordText else { return }
      
      if let error = validate(email: email, password: password){
         completion(.failure(error))
         return
      }
      
      authService.performLogin(email: email, password: password) { (result) in
         completion(result)
      }
   }
   
   func performResend(){
      authService.resendVerification()
   }
}
