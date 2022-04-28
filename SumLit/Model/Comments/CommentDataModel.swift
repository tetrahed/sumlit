//
//  CommentDataModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/10/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

struct CommentDataModel: Equatable, ReplyingToProtocol {
    let RTPreplyingToUseruuid: String
    let parentCommentuuid: String
    let commentuuid: String
    let useruuid: String
    var username: String?
    var comment: String
    var upvotes: Int
    var isUpvoted: Bool
    let timeStamp : Double
    let reverseTimeStamp: Double?
    let createdAt: Date
    var hasReplies: Bool = false
    var replyCount: Int = 0
    var wasDeleted : Bool
}

extension CommentDataModel{
    
    init?(snapshot: DataSnapshot) {
        if let dict = snapshot.value as? [String:Any],
            let useruuid = dict["useruuid"] as? String,
            let comment = dict["comment"] as? String,
            let upvotes = dict["upvotes"] as? Int,
            let timeStamp = dict["timeStamp"] as? Double{
            
            self.commentuuid = snapshot.key
            self.useruuid = useruuid
            self.RTPreplyingToUseruuid = useruuid
            self.parentCommentuuid = snapshot.key
            self.username = nil
            self.comment = comment
            self.upvotes = upvotes
            if let upvoters = dict["upvoters"] as? [String:Bool],
                let uuid = UserService.shared.uid{
                self.isUpvoted = (upvoters[uuid] != nil)
            }else{
                self.isUpvoted = false
            }
            self.timeStamp = timeStamp
            if let reverseTimeStamp = dict["reverseTimeStamp"] as? Double{
                self.reverseTimeStamp = reverseTimeStamp
            }else{
                self.reverseTimeStamp = nil
            }
            self.createdAt = Date(timeIntervalSince1970: timeStamp/1000)
            if let hasReplies = dict["hasReplies"] as? Bool{
                self.hasReplies = hasReplies
            }
            if let replyCount = dict["replyCount"] as? Int{
                self.replyCount = replyCount
            }
            
            if let wasDeleted = dict["wasDeleted"] as? Bool{
                self.wasDeleted = wasDeleted
            }else{
                self.wasDeleted = false
            }
        }else{
            return nil
        }
    }
}
