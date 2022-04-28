//
//  SignUpViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/5/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

struct SignUpViewModel: AuthViewModelProtocol {
   
   private let authService: AuthService
   
   init(authService: AuthService = AuthService()) {
      self.authService = authService
   }
   
   private func validate(username: String, email: String, password: String) -> Error?{
      if let error = validateUsername(username: username){
         return error
      }
      
      if let error = validateEmail(email: email){
         return error
      }
      
      if let error = validatePassword(password: password){
         return error
      }
      
      return nil
   }
   
   func performSignUp(usernameText: String?, emailText: String?, passwordText: String?, completion: @escaping ((Error?) -> Void)){
      guard let username = usernameText, let email = emailText, let password = passwordText else {
         completion(CustomErrors.GeneralErrors.unknownError)
         return
      }
      
      if let error = validate(username: username, email: email, password: password){
         completion(error)
      }else{
         authService.performSignUp(username: username, email: email, password: password) { (result) in
            switch result{
            case .success(_):
               completion(nil)
            case .failure(let error):
               completion(error)
            }
         }
      }
   }
}
