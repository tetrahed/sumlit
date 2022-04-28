//
//  PostService.swift
//  SumLit
//
//  Created by Junior Etrata on 8/14/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

class PostService{
    
    typealias GetPostsHandler = ( (Result<[PostDataModel],Error>) -> Void )
    typealias UpdateCommentHandler = ((Error?) -> Void)
    
    private var queryLimit: UInt = 14
    
    func getPosts(useruuid: String? = nil, filterType: FilterTypes, lastPost: PostDataModel?, isSelfPost: Bool, completion: @escaping GetPostsHandler){
        
        guard let queryRef = setDatabaseQuery(useruuid: useruuid, filterType: filterType, lastPost: lastPost, isSelfPost: isSelfPost) else{
            completion(.success([]))
            return
        }
        
        var postDataModels = [PostDataModel]()
        queryRef.observeSingleEvent(of: .value) { (snapshot) in
            let group = DispatchGroup()
            for child in snapshot.children{
                group.enter()
                if let childSnapshot = child as? DataSnapshot{
                    if var post = PostDataModel(snapshot: childSnapshot),
                        let useruuid = post.useruuid,
                        post.postuuid != lastPost?.postuuid{
                        
                        Constants.FirebaseRefs.usersRef.child(useruuid).observeSingleEvent(of: .value) { (snapshot) in
                            
                            if let dict = snapshot.value as? [String:Any],
                               let username = dict["username"] as? String{
                                post.username = username
                                postDataModels.insert(post, at: 0)
                                group.leave()
                            }else{
                                group.leave()
                            }
                        }
                    }else{
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main, execute: {
                var sorted : [PostDataModel]!
                switch filterType{
                case .oldest:
                    sorted = postDataModels.sorted(by: { (lft, rt) -> Bool in
                        lft.timeStamp < rt.timeStamp
                    })
                case .newest:
                    sorted = postDataModels.sorted(by: { (lft, rt) -> Bool in
                        lft.reverseTimeStamp < rt.reverseTimeStamp
                    })
                default:
                    break
                }
                completion(.success(sorted))
            })
        }
    }
    
    func updateComment(postuuid: String, newComment: String, completion: @escaping UpdateCommentHandler){
        guard let uuid = UserService.shared.uid else {
            completion(CustomErrors.GeneralErrors.unknownError)
            return
        }
        let commentUpdate : [String: Any] = ["posts/\(postuuid)/comment": newComment, "selfPosts/\(uuid)/\(postuuid)/comment": newComment]
        Constants.FirebaseRefs.databaseRef.updateChildValues(commentUpdate) { (error, ref) in
            if let error = error{
                completion(error)
            }else{
                completion(nil)
            }
        }
    }
}

fileprivate extension PostService{
    
    func setDatabaseQuery(useruuid: String?, filterType: FilterTypes, lastPost: PostDataModel?, isSelfPost: Bool) -> DatabaseQuery?{
        
        let queryRef = (isSelfPost) ? Constants.FirebaseRefs.selfPostRef.child(useruuid ?? "") : Constants.FirebaseRefs.postRef
        
        switch filterType{
        case .newest:
            if let lastPost = lastPost{
                let lastTimeStamp = lastPost.timeStamp
                return queryRef.queryOrdered(byChild: "timeStamp").queryEnding(atValue: lastTimeStamp).queryLimited(toLast: queryLimit)
            }else{
                return queryRef.queryOrdered(byChild: "timeStamp").queryLimited(toLast: queryLimit)
            }
        case .oldest:
            
            if let lastPost = lastPost{
                 let reverseTimeStamp = lastPost.reverseTimeStamp// else {
//                    return nil
//                }
                return queryRef.queryOrdered(byChild: "reverseTimeStamp").queryEnding(atValue: reverseTimeStamp).queryLimited(toLast: queryLimit)
            }else{
                return queryRef.queryOrdered(byChild: "reverseTimeStamp").queryLimited(toLast: queryLimit)
            }
        default:
            return nil
        }
    }
}
