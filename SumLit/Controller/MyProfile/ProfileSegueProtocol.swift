//
//  ProfileSegueProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 9/15/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol ProfileSegueProtocol {
   func segueToProfile(viewController: ProfileBlockProtocol?, useruuid: String, username: String)
}

extension ProfileSegueProtocol where Self: UIViewController{
   func segueToProfile(viewController: ProfileBlockProtocol?, useruuid: String, username: String){
      let otherUserProfileStoryboard = UIStoryboard(name: "OtherUserProfile", bundle: nil)
      if let otherUserProfileVC = otherUserProfileStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController{
         let userInfoDataModel = UserInfoDataModel(useruuid: useruuid, username: username)
         otherUserProfileVC.userInfo = userInfoDataModel
         if let viewController = viewController{
            otherUserProfileVC.profileBlockProtocolDelegate = viewController
         }
         navigationController?.pushViewController(otherUserProfileVC, animated: true)
      }
   }
}
