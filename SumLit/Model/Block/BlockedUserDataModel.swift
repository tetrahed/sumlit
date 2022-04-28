//
//  ViewBlockedUsersDataModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/25/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

struct BlockedUserDataModel {
   let useruuid : String
   let username : String
   let timeStamp: Double
}

extension BlockedUserDataModel{
   init?(snapshot: DataSnapshot) {
      if let dict = snapshot.value as? [String:Any],
         let username = dict["username"] as? String,
         let timestamp = dict["timeStamp"] as? Double{
         self.useruuid = snapshot.key
         self.username = username
         self.timeStamp = timestamp
      }else{
         return nil
      }
   }
}
