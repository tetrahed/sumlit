//
//  FollowInfoService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/18/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

class FollowInfoService{
   
   typealias GetFollowerCountHandler = ( (Int) -> Void )
   typealias FollowerCheckHandler = ( (Bool) -> Void)
   
   func getFollowerCount(useruuid: String, completion: @escaping GetFollowerCountHandler){
      let followInfoRef = Constants.FirebaseRefs.followerInfoRef.child(useruuid).child("followerCount")
      followInfoRef.observeSingleEvent(of: .value) { (snapshot) in
         if let count = snapshot.value as? Int{
            completion(count)
         }else{
            completion(-1)
         }
      }
   }
   
   func isFollowing(useruuid: String, profileuuid: String, completion: @escaping FollowerCheckHandler){
      let followInfoRef = Constants.FirebaseRefs.followerInfoRef.child(profileuuid).child("followers").child(useruuid)
      followInfoRef.observeSingleEvent(of: .value) { (snapshot) in
         if snapshot.exists(){
            completion(true)
         }else{
            completion(false)
         }
      }
   }
}
