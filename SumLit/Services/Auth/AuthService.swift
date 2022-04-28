//
//  AuthService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseAuth

class AuthService {
   
   typealias ResponseHandler = ( (Result<Bool,Error>) -> Void )

   func performLogin(email: String, password: String, completion: @escaping ResponseHandler) {
      do {
         try Auth.auth().useUserAccessGroup("group.com.RobbyApp.SumLit")
      } catch {
         return completion(.failure(CustomErrors.GeneralErrors.unknownError))
      }
      Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
         if let error = error {
            completion(.failure(error))
         }else{
            if let currentUser = Auth.auth().currentUser{
               if currentUser.isEmailVerified{
                  UserService.shared.isValidSession(completion: { (valid) in
                     if valid{
                        completion(.success(true))
                     }else{
                        completion(.failure(CustomErrors.GeneralErrors.banned))
                     }
                  })
               }else{
                  completion(.success(false))
               }
            }else{
               completion(.failure(CustomErrors.GeneralErrors.unknownError))
            }
         }
      }
   }
   
   func performReset(email: String, completion: @escaping ResponseHandler){
      Auth.auth().sendPasswordReset(withEmail: email) { (error) in
         if let error = error{
            completion(.failure(error))
         }else{
            completion(.success(true))
         }
      }
   }
   
   func performSignUp(username: String, email: String, password: String, completion: @escaping ResponseHandler){
      checkIfUsernameIsAvailable(username: username) { [weak self] (state) in
         switch state {
         case .success(let available):
            if available{
               self?.createUser(username: username, email: email, password: password, completion: { (result) in
                  switch result{
                  case .success(_):
                     completion(.success(true))
                  case.failure(let error):
                     completion(.failure(error))
                  }
               })
            }else{
               completion(.failure(CustomErrors.AuthServiceErrors.usernameAlreadyTaken))
            }
         case .failure(_):
            break
         }
      }
   }
   
   func resendVerification(){
      Auth.auth().currentUser?.sendEmailVerification(completion: { (_) in })
   }
}

fileprivate extension AuthService{
   func checkIfUsernameIsAvailable(username : String, completion: @escaping (ResponseHandler)) {
      let usernameRef = Constants.FirebaseRefs.usernamesRef.child(username)
      usernameRef.observeSingleEvent(of: .value) { (snapshot) in
         if snapshot.exists(){
            completion(.success(false))
         }else{
            completion(.success(true))
         }
      }
   }
   
   func createNecessaryInformationForUser(username: String, completion: @escaping ResponseHandler){
      if let uid = Auth.auth().currentUser?.uid{
         let followInfoObject = createFollowInfoObject()
         let userObject = createUserObject(uid: uid, username: username)
         let userCreation : [String: Any] = ["usernames/\(username)": true, "users/\(uid)" : userObject, "validUsers/\(uid)":username, "followerInfo/\(uid)": followInfoObject]
         Constants.FirebaseRefs.databaseRef.updateChildValues(userCreation) { (error, ref) in
            if let error = error{
               completion(.failure(error))
            }else{
               completion(.success(true))
            }
         }
      }
   }
   
   func createUserObject(uid: String, username: String) -> [String:String]{
      return  [
         "uid": uid,
         "username": username
         ] as [String:String]
   }
   
   func createFollowInfoObject() -> [String:Any]{
      return  [
         "followerCount": 0,
         ] as [String:Any]
   }
   
   func createUser(username: String, email: String, password: String, completion: @escaping ResponseHandler) {
      Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
         if result == nil, let error = error{
            completion(.failure(error))
         }else{
            Auth.auth().currentUser?.sendEmailVerification(completion: { (_) in })
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            
            changeRequest?.commitChanges(completion: { [weak self] (error) in
               if let error = error {
                  completion(.failure(error))
               }else{
                  self?.createNecessaryInformationForUser(username: username, completion: { (response) in
                     switch response{
                     case .success:
                        completion(.success(true))
                     case .failure(let error):
                        completion(.failure(error))
                     }
                  })
               }
            })
         }
      }
   }
}
