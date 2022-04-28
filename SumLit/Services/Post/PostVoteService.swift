//
//  VoteService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

class PostVoteService{
   
   typealias upvoteCount = Int
   typealias UpvotePostHandler = ( (Result<(VoteState, upvoteCount),Error>) -> Void )
   
   enum VoteState {
      case upvoted
      case downvoted
      case none
   }
   
   func upvotePost(useruuid: String, postuuid: String, completion: @escaping UpvotePostHandler)
   {
      var voteState: VoteState = .none
      var newUpvotes: Int = 0
      let voteRef = Constants.FirebaseRefs.postVoteRef.child(postuuid)
      voteRef.runTransactionBlock({ (currentData) -> TransactionResult in
         if var dict = currentData.value as? [String:AnyObject]{
            var downvoters = dict["downvoters"] as? [String:Bool] ?? [:]
            var upvoters = dict["upvoters"] as? [String:Bool] ?? [:]
            var upvotes = dict["upvotes"] as? Int ?? 0
            
            if upvoters[useruuid] != nil{
               upvoters.removeValue(forKey: useruuid)
               upvotes -= 1
            }else if upvoters[useruuid] == nil{
               upvoters[useruuid] = true
               upvotes += 1
               if downvoters[useruuid] != nil{
                  downvoters.removeValue(forKey: useruuid)
                  upvotes += 1
               }
               voteState = .upvoted
                dict["lastUpvoteruuid"] = useruuid as AnyObject
            }
            
            newUpvotes = upvotes
            dict["downvoters"] = downvoters as AnyObject
            dict["upvoters"] = upvoters as AnyObject
            dict["upvotes"] = upvotes as AnyObject
            currentData.value = dict
         }
         return TransactionResult.success(withValue: currentData)
      }) { (error, committed, snapshot) in
         if let error = error{
            completion(.failure(error))
         }else{
            if committed{
               completion(.success((voteState,newUpvotes)))
            }
         }
      }
   }
   
   func downvotePost(useruuid: String, postuuid: String, completion: @escaping UpvotePostHandler){
      var voteState: VoteState = .none
      var newUpvotes: Int = 0
      let voteRef = Constants.FirebaseRefs.postVoteRef.child(postuuid)
      voteRef.runTransactionBlock({ (currentData) -> TransactionResult in
         if var dict = currentData.value as? [String:AnyObject]{
            var downvoters = dict["downvoters"] as? [String:Bool] ?? [:]
            var upvoters = dict["upvoters"] as? [String:Bool] ?? [:]
            var upvotes = dict["upvotes"] as? Int ?? 0
            
            if downvoters[useruuid] != nil{
               downvoters.removeValue(forKey: useruuid)
               upvotes = upvoters.count
            }else if downvoters[useruuid] == nil{
               downvoters[useruuid] = true
               upvotes -= 1
               if upvoters[useruuid] != nil{
                  upvoters.removeValue(forKey: useruuid)
                  upvotes -= 1
               }
               voteState = .downvoted
            }
            
            newUpvotes = upvotes
            dict["downvoters"] = downvoters as AnyObject
            dict["upvoters"] = upvoters as AnyObject
            dict["upvotes"] = upvotes as AnyObject
            currentData.value = dict
         }
         return TransactionResult.success(withValue: currentData)
      }) { (error, committed, snapshot) in
         if let error = error{
            completion(.failure(error))
         }else{
            if committed{
               completion(.success((voteState,newUpvotes)))
            }
         }
      }
   }
   
   func getCurrentVoteState(useruuid: String, postuuid: String, completion: @escaping UpvotePostHandler){
      let postVoteRef = Constants.FirebaseRefs.postVoteRef.child(postuuid)
      postVoteRef.observeSingleEvent(of: .value) { (snapshot) in
         var voteState: VoteState = .none
         if let voteDataModel = VoteDataModel(snapshot: snapshot){
            if voteDataModel.upvoters.contains(useruuid){
               voteState = .upvoted
            }else if voteDataModel.downvoters.contains(useruuid){
               voteState = .downvoted
            }
            completion(.success((voteState, voteDataModel.upvotes)))
         }
      }
   }
}
