//
//  ReplyCommentDataModel.swift
//  SumLit
//
//  Created by Junior Etrata on 1/7/20.
//  Copyright © 2020 Sumlit. All rights reserved.
//

import Firebase

protocol ReplyingToProtocol {
    var username : String? { get }
    var RTPreplyingToUseruuid: String { get }
    var parentCommentuuid: String { get }
}

struct ReplyCommentDataModel: Equatable, ReplyingToProtocol {
    let RTPreplyingToUseruuid: String
    let repliedToUseruuid: String
    let needToGrabReplyingToUsername: Bool
    var repliedToUsername: String? = nil
    let commentuuid: String
    let parentCommentuuid: String
    let useruuid: String
    var username: String?
    var comment: String
    var upvotes: Int
    var isUpvoted: Bool
    let timeStamp : Double
    let reverseTimeStamp: Double?
    let createdAt: Date
    var wasDeleted: Bool
}

extension ReplyCommentDataModel{
    
    init?(snapshot: DataSnapshot) {
        if let dict = snapshot.value as? [String:Any],
            let parentCommentuuid = dict["parentCommentuuid"] as? String,
            let repliedToUseruuid = dict["replyingToUseruuid"] as? String,
            let useruuid = dict["useruuid"] as? String,
            let needToGrabReplyingToUsername = dict["needToGrabReplyingToUsername"] as? Bool,
            let comment = dict["comment"] as? String,
            let upvotes = dict["upvotes"] as? Int,
            let timeStamp = dict["timeStamp"] as? Double{
            
            self.parentCommentuuid = parentCommentuuid
            self.commentuuid = snapshot.key
            self.useruuid = useruuid
            self.RTPreplyingToUseruuid = useruuid
            self.repliedToUseruuid = repliedToUseruuid
            self.username = nil
            self.comment = comment
            self.upvotes = upvotes
            self.needToGrabReplyingToUsername = needToGrabReplyingToUsername
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
