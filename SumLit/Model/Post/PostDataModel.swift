//
//  PostDataModel.swift
//  SumLit
//
//  Created by Junior Etrata on 8/14/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Firebase

struct PostDataModel: Equatable
{
    let postuuid : String
    let useruuid: String?
    var username: String? = nil
    let summary: String?
    let title: String?
    var comment: String?
    let link: String?
    let timeStamp: Double
    let reverseTimeStamp: Double
    let createdAt: Date?
    var wasDeleted: Bool = false
    let commentCount : Int
}

extension PostDataModel {
    init?(snapshot: DataSnapshot) {
        if let dict = snapshot.value as? [String:Any],
            let useruuid = dict["useruuid"] as? String,
            let summary = dict["summary"] as? String,
            let title = dict["title"] as? String,
            let comment = dict["comment"] as? String,
            let link = dict["link"] as? String,
            let timeStamp = dict["timeStamp"] as? Double{
            
            self.postuuid = snapshot.key
            self.summary = summary
            self.title = title
            self.comment = comment
            self.link = link
            self.timeStamp = timeStamp
            self.useruuid = useruuid
            if let commentCount = dict["commentCount"] as? Int{
                self.commentCount = commentCount
            }else{
                self.commentCount = 0
            }
            self.reverseTimeStamp = -timeStamp
//            if let reverseTimeStamp = dict["reverseTimeStamp"] as? Double{
//                self.reverseTimeStamp = reverseTimeStamp
//            }else{
//                self.reverseTimeStamp = nil
//            }
            self.createdAt = Date(timeIntervalSince1970: timeStamp/1000)
        }else if let dict = snapshot.value as? [String:Any],
            let timeStamp = dict["timeStamp"] as? Double{
            self.postuuid = snapshot.key
            self.summary = nil
            self.title = nil
            self.comment = nil
            self.link = nil
            self.useruuid = nil
            self.createdAt = nil
            self.timeStamp = timeStamp
            self.reverseTimeStamp = -timeStamp
//            if let reverseTimeStamp = dict["reverseTimeStamp"] as? Double{
//                self.reverseTimeStamp = reverseTimeStamp
//            }else{
//                self.reverseTimeStamp = nil
//            }
            self.wasDeleted = true
            self.commentCount = 0
        }else{
            return nil
        }
    }
}
