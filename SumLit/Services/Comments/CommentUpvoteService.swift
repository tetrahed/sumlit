//
//  CommentLikesService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/10/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

class CommentUpvoteService {
    
    typealias CommentUpvoteHandler = ( (Result<CommentDataModel,Error>) -> Void )
    
    func upvoteParentComment(postuuid: String, useruuid: String, comment: CommentDataModel, completion: @escaping CommentUpvoteHandler){
        var newComment = comment
        let commentsRef = Constants.FirebaseRefs.databaseRef.child("comments/\(postuuid)/\(comment.commentuuid)")
        commentsRef.runTransactionBlock({ (currentData) -> TransactionResult in
            if var dict = currentData.value as? [String:AnyObject]{
                var upvotes = dict["upvotes"] as? Int ?? 0
                var upvoters = dict["upvoters"] as? [String:Bool] ?? [:]
                
                if upvoters[useruuid] == nil{
                    upvoters[useruuid] = true
                    upvotes += 1
                    newComment.upvotes = upvotes
                    newComment.isUpvoted = true
                }else{
                    upvoters.removeValue(forKey: useruuid)
                    upvotes -= 1
                    newComment.upvotes = upvotes
                    newComment.isUpvoted = false
                }
                dict["upvotes"] = upvotes as AnyObject
                dict["upvoters"] = upvoters as AnyObject
                currentData.value = dict
            }
            
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error{
                completion(.failure(error))
            }else{
                if committed{
                    completion(.success(newComment))
                }
            }
        }
    }
    
    func upvoteReplyComment(reply: ReplyCommentDataModel, postuuid: String, useruuid: String, completion: @escaping ((Result<ReplyCommentDataModel,Error>) -> Void)){
        var newReplyComment = reply
        let replyCommentsRef = Constants.FirebaseRefs.replyCommentsRef.child(postuuid).child(reply.parentCommentuuid).child(reply.commentuuid)
        replyCommentsRef.runTransactionBlock({ (currentData) -> TransactionResult in
            if var dict = currentData.value as? [String:AnyObject]{
                var upvotes = dict["upvotes"] as? Int ?? 0
                var upvoters = dict["upvoters"] as? [String:Bool] ?? [:]
                
                if upvoters[useruuid] == nil{
                    upvoters[useruuid] = true
                    upvotes += 1
                    newReplyComment.upvotes = upvotes
                    newReplyComment.isUpvoted = true
                }else{
                    upvoters.removeValue(forKey: useruuid)
                    upvotes -= 1
                    newReplyComment.upvotes = upvotes
                    newReplyComment.isUpvoted = false
                }
                dict["upvotes"] = upvotes as AnyObject
                dict["upvoters"] = upvoters as AnyObject
                currentData.value = dict
            }
            
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error{
                completion(.failure(error))
            }else{
                if committed{
                    completion(.success(newReplyComment))
                }
            }
        }
    }
}
