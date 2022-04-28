//
//  FirebaseErrorHelper.swift
//  SumLit
//
//  Created by Junior Etrata on 9/9/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Firebase

struct FirebaseErrorHelper {
   static func convertErrorToMessage(error: Error) -> String{
      if let errorCode = AuthErrorCode(rawValue: error._code),
         let message = errorCode.errorMessage{
         return message
      }else{
         return error.localizedDescription
      }
   }
}

extension AuthErrorCode {
   var errorMessage: String? {
      switch self {
      case .emailAlreadyInUse:
         return "The email is already in use with another account."
      case .userNotFound:
         return "User doesn't exist."
      case .userDisabled:
         return "Your account has been disabled. Please contact support."
      case .invalidEmail, .invalidSender, .invalidRecipientEmail:
         return "Please enter a valid email."
      case .networkError:
         return "Network error. Please try again."
      case .weakPassword:
         return "Your password is too weak. The password must be 7 characters long or more."
      case .wrongPassword:
         return "Your password is incorrect. Please try again or use 'Forgot password' to reset your password."
      case .tooManyRequests:
         return "Too many requests. Please try again later."
      case .internalError:
         return "Internal Error has occurred. Please try again later."
      default:
         return nil
      }
   }
}
