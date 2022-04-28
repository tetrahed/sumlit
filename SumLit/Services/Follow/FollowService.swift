//
//  FollowService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/22/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

class FollowService {
   
   typealias FollowerHandler = ((Error?) -> Void)
   
   func addFollower(selfuuid: String, selfusername: String, profileuuid: String, completion: @escaping FollowerHandler){
      let followInfoRef = Constants.FirebaseRefs.followerInfoRef.child(profileuuid)
      followInfoRef.runTransactionBlock({ [weak self] (currentData) -> TransactionResult in
         
         if var dict = currentData.value as? [String:AnyObject]{
            var followerCount = dict["followerCount"] as? Int ?? 0
            var followers = dict["followers"] as? [String:Any] ?? [:]
            
            if followers[selfuuid] != nil{
               return TransactionResult.abort()
            }else{
               followers[selfuuid] = self?.createInitialFollowerObject(useruuid: selfuuid, username: selfusername)
               followerCount += 1
            }
            
            dict["followerCount"] = followerCount as AnyObject
            dict["followers"] = followers as AnyObject
            currentData.value = dict
         }
         
         return TransactionResult.success(withValue: currentData)
      }) { (error, committed, snapshot) in
         if let error = error {
            completion(error)
         }else if committed{
            
            //MARK:- Add a reverse timestamp in the future.
            completion(nil)
         }
      }
   }
   
   func removeFollowFromSelf(selfuuid: String, profileuuid: String, completion: @escaping FollowerHandler){
      let followInfoRef = Constants.FirebaseRefs.followerInfoRef.child(profileuuid)
      followInfoRef.runTransactionBlock({ (currentData) -> TransactionResult in
         
         if var dict = currentData.value as? [String:AnyObject]{
            var followerCount = dict["followerCount"] as? Int ?? 0
            var followers = dict["followers"] as? [String:Any] ?? [:]
            
            if followers[selfuuid] != nil{
               followers.removeValue(forKey: selfuuid)
               followerCount -= 1
            }else{
               return TransactionResult.success(withValue: currentData)
            }
            
            dict["followerCount"] = followerCount as AnyObject
            dict["followers"] = followers as AnyObject
            currentData.value = dict
         }
         
         return TransactionResult.success(withValue: currentData)
      }) { (error, committed, snapshot) in
         if let error = error{
            completion(error)
         }else if committed{
            completion(nil)
         }
      }
   }
   
   func removeFollow(followeruuid: String, from useruuid: String, completion: @escaping FollowerHandler){
      let followInfoRef = Constants.FirebaseRefs.followerInfoRef.child(followeruuid)
      followInfoRef.runTransactionBlock({ (currentData) -> TransactionResult in
         
         if var dict = currentData.value as? [String:AnyObject]{
            var followerCount = dict["followerCount"] as? Int ?? 0
            var followers = dict["followers"] as? [String:Any] ?? [:]
            
            if followers[useruuid] != nil{
               followers.removeValue(forKey: useruuid)
               followerCount -= 1
            }else{
               return TransactionResult.success(withValue: currentData)
            }
            
            dict["followerCount"] = followerCount as AnyObject
            dict["followers"] = followers as AnyObject
            currentData.value = dict
         }
         
         return TransactionResult.success(withValue: currentData)
      }) { (error, committed, snapshot) in
         if let error = error {
            completion(error)
         }else if committed{
            completion(nil)
         }
      }
   }
}

fileprivate extension FollowService{
   func createInitialFollowerObject(useruuid: String, username: String) -> [String:Any]{
      let timeStamp: Any = [".sv":"timestamp"]
      return [
         "timeStamp": timeStamp,
         "username": username
      ]
   }
}
