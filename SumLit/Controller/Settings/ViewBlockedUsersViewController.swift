//
//  ViewBlockedUsersViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 9/25/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class ViewBlockedUsersViewController: UIViewController, InfiniteScrollProtocol {
   
   @IBOutlet weak var viewBlockedUsersView: ViewBlockedUsersView!
   private let viewBlockedUsersViewModel = ViewBlockedUsersViewModel()
   var cellHeights: [IndexPath : CGFloat] = [:]
   var fetchingMore: Bool = false
   var endReached: Bool = false
   var leadingScreensForBatching: CGFloat = 1.3
   
   //MARK:- VIEW LIFECYCLE
   override func viewDidLoad() {
      super.viewDidLoad()
      getBlockedUsers()
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      setupBeforeViewDisappears()
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      setupInitialView()
   }
}

//MARK:- NETWORK CALLS
extension ViewBlockedUsersViewController{
   func getBlockedUsers(){
      guard let useruuid = UserService.shared.uid else {
         endReached = true
         return
      }
      fetchingMore = true
      viewBlockedUsersViewModel.getBlockedUsers(useruuid: useruuid) { [weak self] (endReached) in
         guard let self = self else { return }
         self.viewBlockedUsersView.tableView.reloadData()
         self.fetchingMore = false
         self.endReached = endReached
      }
   }

   func performUnblockUser(cell: BlockedUsersTableViewCell){
      guard let blockedUser = cell.blockedUsers,
            let useruuid = UserService.shared.uid else { return }
      viewBlockedUsersViewModel.unblockUser(useruuid: useruuid, blockedUseruuid: blockedUser.useruuid) { [weak self] (error) in
         cell.enableUnblockButton()
         if let error = error{
            self?.presentCustomAlertOnMainThread(title: "Unblock error", message: error.localizedDescription)
         }else{
            self?.presentCustomAlertOnMainThread(title: "Success!", message: "You can view \(blockedUser.username)'s posts again.")
            self?.viewBlockedUsersView.tableView.reloadData()
         }
      }
   }
}

//MARK:- BlockedUsersTableViewCellProtocol
extension ViewBlockedUsersViewController: BlockedUsersTableViewCellProtocol, ProfileSegueProtocol{
   func viewProfile(cell: BlockedUsersTableViewCell) {
      guard let blockedUser = cell.blockedUsers else { return }
      segueToProfile(viewController: nil, useruuid: blockedUser.useruuid, username: blockedUser.username)
   }
   
   func unblockUser(cell: BlockedUsersTableViewCell) {
      setupUnblockConfirmation(cell: cell)
   }
}

//MARK:- UITableViewDelegate and UITableViewDataSource
extension ViewBlockedUsersViewController: UITableViewDelegate, UITableViewDataSource{
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return viewBlockedUsersViewModel.blockedUsers.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedUsersTableViewCell", for: indexPath) as? BlockedUsersTableViewCell{
         if !cell.hasSetDelegate{
            cell.blockedUsersDelegate = self
            cell.didSetDelegate()
         }
         cell.setupCell(blockedUsers: viewBlockedUsersViewModel.blockedUsers[indexPath.row])
         return cell
      }
      return UITableViewCell()
   }
}

// MARK:- INFINITE SCROLL
extension ViewBlockedUsersViewController {
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
      let (offsetY, contentHeight, frameHeight) = (scrollView.contentOffset.y, scrollView.contentSize.height , scrollView.frame.size.height)
      shouldGetMore(scrollOffsetY: offsetY, scrollContentHeight: contentHeight, scrollFrameHeight: frameHeight) { [weak self] (confirm) in
         if confirm{
            self?.getBlockedUsers()
         }
      }
   }
}

//MARK:- SETUP
extension ViewBlockedUsersViewController{
   func setupInitialView(){
      navigationItem.title = "Blocked Users"
   }
   
   func setupBeforeViewDisappears(){
      navigationItem.title = ""
   }
   
   func setupUnblockConfirmation(cell: BlockedUsersTableViewCell){
      let username = cell.blockedUsers?.username ?? ""
      let unblockMenuController = UIAlertController.create(title: "Unblock \(username)", message: nil, alertStyle: .alert)
      let yesButton = UIAlertAction(title: "Yes", style: .destructive) { [weak self] (_) in
         cell.disableUnblockButton()
         self?.performUnblockUser(cell: cell)
      }
      let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      unblockMenuController.addAction(cancelButton)
      unblockMenuController.addAction(yesButton)
      present(unblockMenuController, animated: true, completion: nil)
   }
}
