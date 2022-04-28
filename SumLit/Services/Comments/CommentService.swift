//
//  CommentService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/10/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

class CommentService{
    
    typealias GetCommentHandler = ( (Result<[CommentDataModel],Error>) -> Void )
    typealias CommentCountHandler = ( (Int) -> Void )
    typealias ChangeCommentHandler = ((Error?) -> Void)
    
    private let queryLimit: UInt = 30
    private let likesQueryLimit: UInt = 35
    
    func fetchParentComments(filterType: FilterTypes, lastComment: CommentDataModel?, postuuid: String, recentLikesComments: [CommentDataModel]?, completion: @escaping GetCommentHandler){
        
        var queryRef : DatabaseQuery
        
        switch filterType{
        case .newest:
            if let lastComment = lastComment{
                let lastTimeStamp = lastComment.timeStamp
                queryRef = Constants.FirebaseRefs.commentsRef.child(postuuid).queryOrdered(byChild: "timeStamp").queryEnding(atValue: lastTimeStamp).queryLimited(toLast: queryLimit)
            }else{
                queryRef = Constants.FirebaseRefs.commentsRef.child(postuuid).queryOrdered(byChild: "timeStamp").queryLimited(toLast: queryLimit)
            }
        case .oldest:
            if let lastComment = lastComment{
                guard let reverseTimeStamp = lastComment.reverseTimeStamp else {
                    completion(.success([]))
                    return
                }
                queryRef = Constants.FirebaseRefs.commentsRef.child(postuuid).queryOrdered(byChild: "reverseTimeStamp").queryEnding(atValue: reverseTimeStamp).queryLimited(toLast: queryLimit)
            }else{
                queryRef = Constants.FirebaseRefs.commentsRef.child(postuuid).queryOrdered(byChild: "reverseTimeStamp").queryLimited(toLast: queryLimit)
            }
        case .upvotes:
            if let lastComment = lastComment{
                let likes = lastComment.upvotes
                queryRef = Constants.FirebaseRefs.commentsRef.child(postuuid).queryOrdered(byChild: "upvotes").queryEnding(atValue: likes).queryLimited(toLast: likesQueryLimit)
            }else{
                queryRef = Constants.FirebaseRefs.commentsRef.child(postuuid).queryOrdered(byChild: "upvotes").queryLimited(toLast: likesQueryLimit)
            }
        }
        var commentsDataModel = [CommentDataModel]()
        queryRef.observeSingleEvent(of: .value) { (snapshot) in
            let group = DispatchGroup()
            for child in snapshot.children{
                if let childSnapshot = child as? DataSnapshot{
                    if var commentDataModel = CommentDataModel(snapshot: childSnapshot),
                        commentDataModel.commentuuid != lastComment?.commentuuid{
                        group.enter()
                        
                        Constants.FirebaseRefs.usersRef.child(commentDataModel.useruuid).observeSingleEvent(of: .value) { (snapshot) in
                            if let dict = snapshot.value as? [String:Any],
                                let username = dict["username"] as? String{
                                commentDataModel.username = username
                                
                                if filterType == .upvotes{
                                    if let recentLikesComments = recentLikesComments{
                                        
                                        if !recentLikesComments.contains(commentDataModel){
                                            commentsDataModel.insert(commentDataModel, at: 0)
                                        }
                                    }else{
                                        commentsDataModel.insert(commentDataModel, at: 0)
                                    }
                                }else{
                                    commentsDataModel.insert(commentDataModel, at: 0)
                                }
                            }
                            group.leave()
                        }
                    }
                }
            }
            group.notify(queue: .main, execute: {
                var sorted : [CommentDataModel]
                switch filterType{
                case .oldest:
                    sorted = commentsDataModel.sorted(by: { (lft, rt) -> Bool in
                        lft.timeStamp < rt.timeStamp
                    })
                case .newest:
                    sorted = commentsDataModel.sorted(by: { (lft, rt) -> Bool in
                        lft.reverseTimeStamp! < rt.reverseTimeStamp!
                    })
                case .upvotes:
                    sorted = commentsDataModel
                }
                completion(.success(sorted))
            })
        }
    }
    
    func fetchReplyComments(postuuid: String, parentCommentuuid: String, completion: @escaping ((Result<[ReplyCommentDataModel],Error>) -> Void)){
        var dataModels = [ReplyCommentDataModel]()
        Constants.FirebaseRefs.replyCommentsRef.child(postuuid).child(parentCommentuuid).observeSingleEvent(of: .value) { (snapshot) in
            let group = DispatchGroup()
            for child in snapshot.children{
                if let childSnapshot = child as? DataSnapshot, var replyComment = ReplyCommentDataModel(snapshot: childSnapshot){
                    group.enter()
                    Constants.FirebaseRefs.usersRef.child(replyComment.useruuid).observeSingleEvent(of: .value) { (snapshot) in
                        if let dict = snapshot.value as? [String:Any],
                            let username = dict["username"] as? String{
                            replyComment.username = username
                            if replyComment.needToGrabReplyingToUsername{
                                Constants.FirebaseRefs.usersRef.child(replyComment.repliedToUseruuid).observeSingleEvent(of: .value) { (snapshot) in
                                    if let dict = snapshot.value as? [String:Any],
                                        let username = dict["username"] as? String{
                                        replyComment.repliedToUsername = username
                                        dataModels.insert(replyComment, at: 0)
                                    }
                                    group.leave()
                                }
                            }else{
                                dataModels.insert(replyComment, at: 0)
                                group.leave()
                            }
                        }
                    }
                }
            }
            group.notify(queue: .main) {
                completion(.success(dataModels.sorted(by: { (lft, rt) -> Bool in
                    lft.timeStamp < rt.timeStamp
                })))
            }
        }
    }
    
    func updateParentComment(postuuid :String, commentuuid: String, newComment: String, completion: @escaping ChangeCommentHandler){
        Constants.FirebaseRefs.commentsRef.child(postuuid).child(commentuuid).updateChildValues(["comment": newComment]) { (error, ref) in
            if let error = error{
                completion(error)
            }else{
                completion(nil)
            }
        }
    }
    
    func updateReplyComment(postuuid :String, parentCommentuuid: String, commentuuid: String, newComment: String, completion: @escaping ChangeCommentHandler){
        Constants.FirebaseRefs.replyCommentsRef.child(postuuid).child(parentCommentuuid).child(commentuuid).updateChildValues(["comment": newComment]) { (error, ref) in
            if let error = error{
                completion(error)
            }else{
                completion(nil)
            }
        }
    }
}
