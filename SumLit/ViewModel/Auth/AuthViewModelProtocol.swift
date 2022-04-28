//
//  AuthViewModelProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 9/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

protocol AuthViewModelProtocol {
   func validateUsername(username: String) -> Error?
   func validateEmail(email: String) -> Error?
   func validatePassword(password: String) -> Error?
}

extension AuthViewModelProtocol{
   
   func validateUsername(username: String) -> Error?{
      if username.isEmpty{
         return CustomErrors.AuthValidationErrors.emptyUsername
      }
      
    if username.count > Constants.Auth.usernameMax{
         return CustomErrors.AuthValidationErrors.invalidMaxUsername(maxLength: Constants.Auth.usernameMax)
      }
      
      if username.count < Constants.Auth.usernameMin{
         return CustomErrors.AuthValidationErrors.invalidMinUsername(minLength: Constants.Auth.usernameMin)
      }
      
      if let word = username.hasForbiddenWord(){
         return CustomErrors.GeneralErrors.forbiddenWords(word: word)
      }
      
      return nil
   }
   
   func validateEmail(email: String) -> Error?{
      if email.isEmpty{
         return CustomErrors.AuthValidationErrors.emptyEmail
      }
      return nil
   }
   
   func validatePassword(password: String) -> Error?{
      if password.isEmpty{
         return CustomErrors.AuthValidationErrors.emptyPassword
      }
      
      if password.count < Constants.Auth.passwordMin{
         return CustomErrors.AuthValidationErrors.invalidPassword(minLength: Constants.Auth.passwordMin)
      }
      
      return nil
   }
}
