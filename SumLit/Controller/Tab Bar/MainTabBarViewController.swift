//
//  MainTabBarViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 9/13/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class MainTabBarViewController: UITabBarController {

   //MARK:- VIEW LIFECYCLE
   override func viewDidLoad() {
      super.viewDidLoad()
      if let vc = viewControllers?[2] as? UINavigationController,
            let profile = vc.topViewController as? ProfileViewController,
            let uuid = UserService.shared.uid, let username = UserService.shared.username, !UserService.shared.isAnonymous{
            let userInfoDataModel = UserInfoDataModel(useruuid: uuid, username: username)
            profile.userInfo = userInfoDataModel
            profile.postChangeProtocol = self
      }else if let vc = viewControllers?[2] as? UINavigationController,
        let profile = vc.topViewController as? ProfileViewController{
        profile.userInfo = nil
    }
   }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
   
   var feedViewControler : FeedViewController? {
      return (viewControllers?[0] as? UINavigationController)?.viewControllers.first as? FeedViewController
   }
}

//MARK:- FinishUploadProtocol
extension MainTabBarViewController: FinishUploadProtocol{
   func didFinishUploadingNewPost() {
      feedViewControler?.refreshAfterFinishUploading()
   }
}

//MARK:- PostCommentChangeProtocol
extension MainTabBarViewController: PostChangeProtocol{
   func didChangePostComment(post: PostDataModel, newComment: String) {
      feedViewControler?.updateAfterCommentChange(post: post, newComment: newComment)
   }
   
   func didDeletePost(_ post: PostDataModel) {
      feedViewControler?.updateAfterDeletingPost(post)
   }
    
    func refreshHomeFeed() {
        feedViewControler?.getPosts(isRefreshed: true)
    }
}

//MARK:- NAVIGATION
extension MainTabBarViewController{
   func navigateToLogin(){
      if (presentingViewController) != nil{
         dismiss(animated: true, completion: nil)
      }else{
         setRootViewController(storyboard: "Auth", identifier: "NavigationController")
      }
   }
}
