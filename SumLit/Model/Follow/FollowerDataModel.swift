//
//  FollowerDataModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/22/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct FollowerDataModel {
   var profilePicture: UIImage?
   let username: String
   let useruuid: String
   let followedAt: Date
   let timeStamp: Double
}

extension FollowerDataModel {
   init?(snapshot: DataSnapshot) {
      
      if let dict = snapshot.value as? [String:Any],
         let username = dict["username"] as? String,
         let timeStamp = dict["timeStamp"] as? Double{
         self.useruuid = snapshot.key
         self.username = username
         self.followedAt = Date(timeIntervalSince1970: timeStamp/1000)
         self.timeStamp = timeStamp
      }else{
         return nil
      }
   }
}
