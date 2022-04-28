//
//  CustomErrors.swift
//  SumLit
//
//  Created by Junior Etrata on 9/15/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

struct CustomErrors{
   
   //MARK:- GENERAL ERRORS
   enum GeneralErrors: Error, LocalizedError {
      case unknownError
      case forbiddenWords(word: String)
      case banned
      
      public var errorDescription: String? {
         switch self {
         case .unknownError:
            return "An unknown error has occurred. Please try again."
         case let .forbiddenWords(word):
            return "Please refrain from using words like: \(word)"
         case .banned:
            return "Either a network error has occurred, or your account has been suspended."
         }
      }
   }
   
   //MARK:- AUTH ERRORS
   enum AuthValidationErrors: Error, LocalizedError {
      case emptyEmail
      case emptyPassword
      case emptyUsername
      case invalidEmail
      case invalidPassword(minLength: Int)
      case invalidMaxUsername(maxLength: Int)
      case invalidMinUsername(minLength: Int)
      
      public var errorDescription: String? {
         switch self {
         case .emptyEmail:
            return "Please enter an email."
         case .emptyPassword:
            return "Please enter a password."
         case .invalidEmail:
            return "Please enter a valid email."
         case let .invalidPassword(minLength):
            return "Passwords need to be \(minLength) characters or more."
         case .emptyUsername:
            return "Please enter a username."
         case let .invalidMaxUsername(maxLength):
            return "Usernames need to be \(maxLength) characters or less."
         case let .invalidMinUsername(minLength):
            return "Usernames need to be \(minLength) characters or more."
         }
      }
   }
   
   enum AuthServiceErrors: Error, LocalizedError {
      case usernameAlreadyTaken
      case notVerified
      
      public var errorDescription: String? {
         switch self {
         case .usernameAlreadyTaken:
            return "This username is already been taken."
         case .notVerified:
            return "Please check your email and "
         }
      }
   }
   
   //MARK:- ARTICLE SERVICE ERRORS
   enum ArticleParserError: Error, LocalizedError {
      case deadlink
      case brokenLink
      
      public var errorDescription: String? {
         switch self {
         case .deadlink:
            return "The link you entered is either dead or forbidden. Please enter a different link."
         case .brokenLink:
            return "There's an error somewhere. Please try again or use a different link."
         }
      }
   }
   
   //MARK:- NEW COMMENT ERRORS
   enum AddNewCommentError: Error, LocalizedError{
      case emptyComment
      case blocked
      
      public var errorDescription: String? {
         switch self {
         case .emptyComment:
            return "Comment field is empty."
         case .blocked:
            return "You are not allowed to comment on this person's post anymore."
         }
      }
   }
   
   //MARK:- FOLLOW ERROR
   enum FollowError: Error, LocalizedError{
      case blocked
      
      public var errorDescription: String? {
         switch self {
         case .blocked:
            return "You are not allowed to follow this person anymore."
         }
      }
   }
}
