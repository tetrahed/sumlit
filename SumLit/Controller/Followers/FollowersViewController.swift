//
//  FollowersViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 9/22/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class FollowersViewController: UIViewController, InfiniteScrollProtocol {

   var userInfo : UserInfoDataModel!
   private let followersViewModel = FollowersViewModel()
   private let profilePictureService = ProfilePictureService()
   var cellHeights: [IndexPath : CGFloat] = [:]
   var fetchingMore: Bool = false
   var endReached: Bool = false
   var leadingScreensForBatching: CGFloat = 1.5
   @IBOutlet weak var followersView: FollowersView!
   
   //MARK:- VIEW LIFECYCLE
   override func viewDidLoad() {
      super.viewDidLoad()
      getFollowers()
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      setup()
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      setupWhenViewDisappears()
   }
}

//MARK:- NETWORK CALLS
extension FollowersViewController{
   func getFollowers(){
      fetchingMore = true
      followersViewModel.getFollowers(useruuid: userInfo.useruuid) { [weak self] (endReached) in
         self?.endReached = endReached
         self?.fetchingMore = false
         self?.followersView.tableView.reloadData()
      }
   }
   
   func getProfilePicture(useruuid: String, completion: @escaping ((UIImage) -> Void)){
      profilePictureService.getProfileImage(profileuuid: useruuid) { (image) in
         completion(image)
      }
   }
}

//MARK:- FollowersTableViewCellProtocol
extension FollowersViewController: FollowersTableViewCellProtocol, ProfileSegueProtocol{
   
   func viewProfile(cell: FollowersTableViewCell) {
      guard let follower = cell.follower else { return }
      segueToProfile(viewController: self, useruuid: follower.useruuid, username: follower.username)
   }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension FollowersViewController: UITableViewDelegate, UITableViewDataSource{
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return followersViewModel.filteredFollowers.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersTableViewCell") as? FollowersTableViewCell{
         
         if !cell.didSetDelegate{
            cell.followersCellProtocol = self
            cell.delegateHasBeenSet()
         }
         let follower = followersViewModel.filteredFollowers[indexPath.row]
         if follower.profilePicture == nil{
            getProfilePicture(useruuid: follower.useruuid) { [weak self] (profilePicture) in
               guard let self = self else { return }
               var followerDataModel = self.followersViewModel.filteredFollowers[indexPath.row]
               followerDataModel.profilePicture = profilePicture
               self.followersViewModel.updateFollower(followerDataModel: followerDataModel, at: indexPath.row)
               self.followersView.tableView.reloadData()
            }
         }
         cell.setupCell(follower: follower)
         return cell
      }
      return UITableViewCell()
   }

   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return UIDevice.current.userInterfaceIdiom == .pad ? 100 : 70
   }
}

//MARK:- Infinite Scroll
extension FollowersViewController{
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
      let (offsetY, contentHeight, frameHeight) = (scrollView.contentOffset.y, scrollView.contentSize.height, scrollView.frame.height)
      shouldGetMore(scrollOffsetY: offsetY, scrollContentHeight: contentHeight, scrollFrameHeight: frameHeight) { [weak self] (confirm) in
         if confirm{
            self?.getFollowers()
         }
      }
   }
}

//MARK:- ProfileBlockProtocol
extension FollowersViewController: ProfileBlockProtocol{
   func didBlockUser() {
      guard let useruuid = UserService.shared.uid else { return }
      followersViewModel.updateBlockInfo(useruuid: useruuid) { [weak self] in
         self?.followersView.tableView.reloadData()
      }
   }
}

//MARK:- SETUP
extension FollowersViewController{
   func setup(){
      navigationItem.title = "\(userInfo.username)'s Followers"
   }
   
   func setupWhenViewDisappears(){
      navigationItem.title = ""
   }
}
