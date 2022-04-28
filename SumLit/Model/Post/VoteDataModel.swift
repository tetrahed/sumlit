//
//  VoteDataModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/9/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Firebase

struct VoteDataModel {
   let upvotes: Int
   let upvoters: [String]
   let downvoters: [String]
}

extension VoteDataModel{
   init?(snapshot: DataSnapshot) {
      if let dict = snapshot.value as? [String:Any],
         let upvotes = dict["upvotes"] as? Int{

         self.upvotes = upvotes

         if let upvotersDict = dict["upvoters"] as? [String:Bool]{
            self.upvoters = Array(upvotersDict.keys)
         }else{
            self.upvoters = []
         }
         if let downvotersDict = dict["downvoters"] as? [String:Bool]{
            self.downvoters = Array(downvotersDict.keys)
         }else{
            self.downvoters = []
         }
      }else{
         return nil
      }
   }
}
