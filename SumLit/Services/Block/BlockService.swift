//
//  BlockService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/23/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

class BlockService {
   
   typealias GetBlockInfoHandler = ((BlockDataModel) -> Void)
   typealias BlockPostHandler = ( (Error?) -> Void)
   typealias BlockUserHandler = ( (Error?) -> Void)
   
   func getBlockInfo(useruuid: String, completion: @escaping GetBlockInfoHandler){
      let blockRef = Constants.FirebaseRefs.blockRef.child(useruuid)
      blockRef.observeSingleEvent(of: .value) { (snapshot) in
         if let blockDataModel = BlockDataModel(snapshot: snapshot){
            completion(blockDataModel)
         }else{
            completion(BlockDataModel(isBlocked: [], blocking: [], reportedPosts: []))
         }
      }
   }
   
   func blockPost(message: String, selfuuid: String, postuuid: String, posterusername: String, postTitle: String, completion: @escaping BlockPostHandler){
      let reportedPostsRef = "block/\(selfuuid)/reportedPosts/\(postuuid)"
      guard let reportMessagesRefKey = Constants.FirebaseRefs.reportMessagesRef.childByAutoId().key else{
         completion(CustomErrors.GeneralErrors.unknownError)
         return
      }
      let reportMessagesRef = "reportMessages/\(reportMessagesRefKey)"
      let reportMessageObject = createReportMessageObject(message: message, postuuid: postuuid, posterUsername: posterusername, postTitle: postTitle)
      
      let reportCreation : [String: Any] = [reportedPostsRef: true, reportMessagesRef: reportMessageObject]
      Constants.FirebaseRefs.databaseRef.updateChildValues(reportCreation) { (error, ref) in
         if let error = error{
            completion(error)
         }else{
            completion(nil)
         }
      }
   }
   
   func blockUser(selfuuid: String, selfusername: String, blockedUseruuid: String, blockedUsername: String, completion: @escaping BlockUserHandler){
      let timeStamp: Any = [".sv":"timestamp"]
      let blockingRef = "block/\(selfuuid)/blocking/\(blockedUseruuid)"
      let isBlockedRef = "block/\(blockedUseruuid)/isBlocked/\(selfuuid)"
      let blockingObject = createBlockingRef(blockedUsername: blockedUsername, timeStamp: timeStamp)
      let blockedObject = createBlockedRef(blockerUsername: selfusername, timeStamp: timeStamp)
      let followService = FollowService()
      followService.removeFollowFromSelf(selfuuid: selfuuid, profileuuid: blockedUseruuid) { (error) in
         if let error = error{
            completion(error)
         }else{
            followService.removeFollow(followeruuid: selfuuid, from: blockedUseruuid, completion: { (error) in
               if let error = error{
                  completion(error)
               }else{
                  let blockCreation: [String:Any] = [blockingRef: blockingObject, isBlockedRef: blockedObject]
                  Constants.FirebaseRefs.databaseRef.updateChildValues(blockCreation) { (error, ref) in
                     if let error = error{
                        completion(error)
                     }else{
                        completion(nil)
                     }
                  }
               }
            })
         }
      }
   }
}

fileprivate extension BlockService{
   func createReportMessageObject(message: String, postuuid: String, posterUsername: String, postTitle: String) -> [String:String]{
      return [
         "message": message,
         "postuuid": postuuid,
         "posterUsername": posterUsername,
         "postTitle": postTitle
      ]
   }
   
   func createBlockingRef(blockedUsername: String, timeStamp: Any) -> [String:Any]{
      return [
         "username": blockedUsername,
         "timeStamp": timeStamp
      ]
   }
   
   func createBlockedRef(blockerUsername: String, timeStamp: Any) -> [String:Any]{
      return [
         "username": blockerUsername,
         "timeStamp": timeStamp
      ]
   }
}
