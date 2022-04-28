//
//  PostDeletionService.swift
//  SumLit
//
//  Created by Junior Etrata on 11/8/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import FirebaseDatabase

struct PostDeletionService{
   
   typealias DeletePostHandler = ((Error?) -> Void)
   
   func deletePost(_ postDataModel: PostDataModel, completion: @escaping DeletePostHandler){
      //MARK:- NEED TO IMPLEMENT A BETTER DELETE METHOD
      //let deleteObject = createDeletedObject(postDataModel: postDataModel)
      let deleteObjectValues : [String:Any?] = ["posts/\(postDataModel.postuuid)": nil, "selfPosts/\(postDataModel.useruuid ?? "")/\(postDataModel.postuuid)": nil, "postVote/\(postDataModel.postuuid)": nil]
      //, "comments/\(postDataModel.postuuid)": nil]
      Constants.FirebaseRefs.databaseRef.updateChildValues(deleteObjectValues) { (error, ref) in
         completion(error)
      }
   }
}

fileprivate extension PostDeletionService{
   func createDeletedObject(postDataModel: PostDataModel) -> [String:Any]{
      return [
         "timeStamp": postDataModel.timeStamp,
         "reverseTimeStamp": postDataModel.reverseTimeStamp ?? nil
      ]
   }
}
