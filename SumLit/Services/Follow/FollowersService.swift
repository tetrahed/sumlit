//
//  FollowersService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/23/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

class FollowersService {
   typealias GetFollowersHandler = (([FollowerDataModel]) -> Void)
   
   let queryLimit: UInt = 14
   
   func getFollowers(useruuid: String, lastFollower: FollowerDataModel?, filterType: FilterTypes, completion: @escaping GetFollowersHandler){
      
      var queryRef : DatabaseQuery
      
      switch filterType {
      case .newest:
         if let lastFollower = lastFollower{
            let lastTimeStamp = lastFollower.timeStamp
            queryRef = Constants.FirebaseRefs.followerInfoRef.child(useruuid).child("followers").queryOrdered(byChild: "timeStamp").queryEnding(atValue: lastTimeStamp).queryLimited(toLast: queryLimit)
         }else{
            queryRef = Constants.FirebaseRefs.followerInfoRef.child(useruuid).child("followers").queryOrdered(byChild: "timeStamp").queryLimited(toLast: queryLimit)
         }
      default:
         completion([])
         return
      }
      
      var followers = [FollowerDataModel]()
      queryRef.observeSingleEvent(of: .value) { (snapshot) in
         for child in snapshot.children{
            if let childSnapshot = child as? DataSnapshot{
               if let followerDataModel = FollowerDataModel(snapshot: childSnapshot),
                  followerDataModel.useruuid != lastFollower?.useruuid{
                  followers.insert(followerDataModel, at: 0)
               }
            }
         }
         completion(followers)
      }
   }
}
