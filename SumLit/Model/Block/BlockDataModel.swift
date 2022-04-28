//
//  BlockDataModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/23/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

struct BlockDataModel {
   var isBlocked : [String]
   var blocking : [String]
   var reportedPosts : [String]
}

extension BlockDataModel{
   init?(snapshot: DataSnapshot) {
      if let dict = snapshot.value as? [String:Any]{
         
         if let isBlocked = dict["isBlocked"] as? [String:Any]{
            self.isBlocked = Array(isBlocked.keys)
         }else{
            self.isBlocked = []
         }
         
         if let blocking = dict["blocking"] as? [String:Any]{
            self.blocking = Array(blocking.keys)
         }else{
            self.blocking = []
         }
         
         if let reportedPosts = dict["reportedPosts"] as? [String:Any]{
            self.reportedPosts = Array(reportedPosts.keys)
         }else{
            self.reportedPosts = []
         }
      }else{
         return nil
      }
   }
}
