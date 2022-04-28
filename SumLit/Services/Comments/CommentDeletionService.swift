//
//  CommentDeletionService.swift
//  SumLit
//
//  Created by Junior Etrata on 11/15/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import FirebaseDatabase

struct CommentDeletionService {
    
    typealias CommentDeletionHandler = (Error?) -> Void
    
    func deleteParentComment(postuuid: String, commentuuid: String, completion: @escaping CommentDeletionHandler){
        Constants.FirebaseRefs.commentsRef.child(postuuid).child(commentuuid).child("wasDeleted").setValue(true) { (error, _) in
            completion(error)
        }
    }
    
    func deleteReplyComment(postuuid: String, parentCommentuuid: String, commentuuid: String, completion: @escaping CommentDeletionHandler){
        Constants.FirebaseRefs.replyCommentsRef.child(postuuid).child(parentCommentuuid).child(commentuuid).child("wasDeleted").setValue(true) { (error, _) in
            completion(error)
        }
    }
}
