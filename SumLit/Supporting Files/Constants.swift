//
//  Constants.swift
//  SumLit
//
//  Created by Junior Etrata on 9/5/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

struct Constants {
    
    struct FirebaseRefs {
        static let databaseRef = Database.database().reference()
        static let postRef = Database.database().reference().child("posts")
        static let postVoteRef = Database.database().reference().child("postVote")
        static let commentsRef = Database.database().reference().child("comments")
        static let replyCommentsRef = Database.database().reference().child("replyComments")
        static let selfPostRef = Database.database().reference().child("selfPosts")
        static let usersRef = Database.database().reference().child("users")
        static let usernamesRef = Database.database().reference().child("usernames")
        static let validUsersRef = Database.database().reference().child("validUsers")
        static let followerInfoRef = Database.database().reference().child("followerInfo")
        static let blockRef = Database.database().reference().child("block")
        static let reportMessagesRef = Database.database().reference().child("reportMessages")
        static let creditsRef = Database.database().reference().child("credits")
        static let postVoteHistory = Database.database().reference().child("postVoteHistory")
    }
    
    struct Colors {
        static let darkColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        static let orangeColor = #colorLiteral(red: 0.9739639163, green: 0.7061158419, blue: 0.1748842001, alpha: 1)
        static let placeHolderColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
        static let loadingColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 0.5)
    }
    
    struct keyboardConstants{
        static let keyboardDistanceFromTextField: CGFloat = 35.0
    }
    
    struct Images {
        static let defaultProfilePhoto = #imageLiteral(resourceName: "profileDefaultAfter")
    }
    
    struct Comment {
        static let characterLimit = 200
    }
    
    struct Auth{
        static let usernameMin = 3
        static let usernameMax = 16
        static let passwordMin = 5
    }
}
