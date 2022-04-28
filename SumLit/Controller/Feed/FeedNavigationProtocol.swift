//
//  FeedNavigation.swift
//  SumLit
//
//  Created by Junior Etrata on 9/19/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol FeedNavigationProtocol {
   func navigateToComments(post: PostDataModel)
}

extension FeedNavigationProtocol where Self: UIViewController{
   
   func navigateToComments(post: PostDataModel){
      if let commentsVC = UIStoryboard.init(name: "Comments", bundle: Bundle.main).instantiateViewController(withIdentifier: "CommentsViewController") as? CommentsViewController{
         commentsVC.post = post
         commentsVC.opCommentDataModel = OPCommentDataModel(useruuid: post.useruuid!, username: post.username!, comment: post.comment!, createdAt: post.createdAt!)
         navigationController?.pushViewController(commentsVC, animated: true)
      }
   }
}
