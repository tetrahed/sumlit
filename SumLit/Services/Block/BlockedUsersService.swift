//
//  ViewBlockedUsersService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/25/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

class BlockedUsersService {
   
   typealias GetBlockUsersInfoHandler = (([BlockedUserDataModel]) -> Void)
   typealias UnblockUserHandler = ( (Error?) -> Void)
   
   let queryLimit: UInt = 14
   
   func getBlockedUsers(useruuid: String, filterType: FilterTypes, lastBlockedUser: BlockedUserDataModel?, completion: @escaping GetBlockUsersInfoHandler){
      var queryRef: DatabaseQuery
      switch filterType {
      case .newest:
         if let lastBlockedUser = lastBlockedUser{
            let lastTimeStamp = lastBlockedUser.timeStamp
            queryRef = Constants.FirebaseRefs.blockRef.child(useruuid).child("blocking").queryOrdered(byChild: "timeStamp").queryEnding(atValue: lastTimeStamp).queryLimited(toLast: queryLimit)
         }else{
            queryRef = Constants.FirebaseRefs.blockRef.child(useruuid).child("blocking").queryOrdered(byChild: "timeStamp").queryLimited(toLast: queryLimit)
         }
         break
      default:
         completion([])
         return
      }
      var blockedUsers = [BlockedUserDataModel]()
      queryRef.observeSingleEvent(of: .value) { (snapshot) in
         for child in snapshot.children{
            if let childSnapshot = child as? DataSnapshot{
               if let blockedUser = BlockedUserDataModel(snapshot: childSnapshot),
                  blockedUser.useruuid != lastBlockedUser?.useruuid{
                  blockedUsers.insert(blockedUser, at: 0)
               }
            }
         }
         completion(blockedUsers)
      }
   }
   
   func unblockUser(useruuid: String, blockedUseruuid: String, completion: @escaping UnblockUserHandler){
      let unblockCreation : [String:Any?] = ["block/\(useruuid)/blocking/\(blockedUseruuid)": nil, "block/\(blockedUseruuid)/isBlocked/\(useruuid)": nil]
      Constants.FirebaseRefs.databaseRef.updateChildValues(unblockCreation) { (error, ref) in
         if let error = error{
            completion(error)
         }else{
            completion(nil)
         }
      }
   }
}
