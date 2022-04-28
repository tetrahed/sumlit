//
//  AddCommentService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/10/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

class AddCommentService{
    
    typealias AddCommentHandler = ( (Result<Bool,Error>) -> Void )
    
    func addParentComment(useruuid: String, postuuid: String, comment: String, completion: @escaping AddCommentHandler){
        
        let commentRef = Constants.FirebaseRefs.commentsRef.child(postuuid).childByAutoId()
        let commentObject = createParentCommentObject(useruuid: useruuid, comment: comment)
        commentRef.setValue(commentObject) { (error, ref) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                if let error = error{
                    completion(.failure(error))
                }else{
                    completion(.success(true))
                }
            }
//            if let error = error{
//                completion(.failure(error))
//            }else{
//                completion(.success(true))
//            }
        }
    }
    
    func addReplyComment(parentCommentuuid: String, replyingToUseruuid: String, needToGrabReplyingToUsername: Bool, useruuid: String, postuuid: String, username: String, comment: String, completion: @escaping ((Result<ReplyCommentDataModel,Error>) -> Void)){
        let replyCommentRef = Constants.FirebaseRefs.replyCommentsRef.child(postuuid).child(parentCommentuuid).childByAutoId()
        let replyComment = createReplyCommentObject(parentCommentuuid: parentCommentuuid, replyingToUseruuid: replyingToUseruuid, needToGrabReplyingToUsername: needToGrabReplyingToUsername, useruuid: useruuid, comment: comment)
        replyCommentRef.setValue(replyComment) { (error, ref) in
            if let error = error{
                completion(.failure(error))
            }else{
                ref.observeSingleEvent(of: .value) { (snapshot) in
                    if var replyDataModel = ReplyCommentDataModel(snapshot: snapshot){
                        replyDataModel.username = username
                        
                        if replyDataModel.needToGrabReplyingToUsername{
                            Constants.FirebaseRefs.usersRef.child(replyDataModel.repliedToUseruuid).child("username").observeSingleEvent(of: .value) { (snapshot) in
                                if let replyingToUsername = snapshot.value as? String{
                                    replyDataModel.repliedToUsername = replyingToUsername
                                    completion(.success(replyDataModel))
                                }
                            }
                        }else{
                            completion(.success(replyDataModel))
                        }
                    }else{
                        completion(.failure(CustomErrors.GeneralErrors.unknownError))
                    }
                }
            }
        }
    }
}

private extension AddCommentService{
    func createParentCommentObject(useruuid: String, comment: String) -> [String:Any]?{
        let timeStamp: Any = [".sv":"timestamp"]
        return [
            "useruuid": useruuid,
            "comment": comment,
            "upvotes": 0,
            "timeStamp": timeStamp,
        ]
    }
    
    func createReplyCommentObject(parentCommentuuid: String, replyingToUseruuid: String?, needToGrabReplyingToUsername: Bool, useruuid: String, comment: String) -> [String:Any]? {
        let timeStamp: Any = [".sv":"timestamp"]
        return [
            "parentCommentuuid": parentCommentuuid,
            "replyingToUseruuid": replyingToUseruuid as Any,
            "needToGrabReplyingToUsername": needToGrabReplyingToUsername,
            "useruuid": useruuid,
            "comment": comment,
            "upvotes": 0,
            "timeStamp": timeStamp,
        ]
    }
}
