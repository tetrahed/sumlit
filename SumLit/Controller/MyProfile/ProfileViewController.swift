//
//  ProfileViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 9/18/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import MessageUI

protocol PostChangeProtocol: class {
    func didChangePostComment(post: PostDataModel, newComment: String)
    func didDeletePost(_ post: PostDataModel)
    func refreshHomeFeed()
}

class ProfileViewController: UIViewController, InfiniteScrollProtocol, FeedViewModelProtocol, ProfilePictureProtocol {
    
    @IBOutlet private weak var profileView: ProfileView!
    
    //MARK:- DECLARED VARIABLES
    private let imagePicker = ImagePickerManager()
    private var profileViewModel = ProfileViewModel()
    var profilePictureService: ProfilePictureService = ProfilePictureService()
    var userInfo : UserInfoDataModel!
    var feedViewModel: FeedViewModel = FeedViewModel()
    var cellHeights: [IndexPath : CGFloat] = [:]
    var fetchingMore: Bool = false
    var endReached: Bool = false
    var leadingScreensForBatching: CGFloat = 4
    let updateCommentHeightHelper = UpdateCommentHeightHelper()
    var changeUsernameViewController : ChangeUsernameViewController!
    var reportPostViewController: ReportPostViewController!
    weak var profileBlockProtocolDelegate: ProfileBlockProtocol?
    weak var postChangeProtocol: PostChangeProtocol?
    private var profileCellHeight : [IndexPath: CGFloat] = [:]
//    private var didChangeDyanmicFontSize = false
    private var padEdgeCaseCheckDone = false
    
    //MARK:- LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if userInfo != nil{
            setupUI()
            callNecessaryNetworkCalls()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if userInfo != nil{
            navigationItem.title = "\(userInfo.username)'s profile"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if userInfo != nil{
            navigationItem.title = nil
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if userInfo != nil, !fetchingMore && feedViewModel.filteredPosts.isEmpty{
            getSelfPosts(isRefreshed: true)
        }
        if userInfo != nil{
            getFollowerCount()
            getCreditsCount()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if userInfo == nil{
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            profileView.askToSignInView.delegate = self
            profileView.displaySignInView()
        }
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
//            makeAllCellsDisplayFully()
//        }
//    }
//
//    private func makeAllCellsDisplayFully(){
//        didChangeDyanmicFontSize = true
//        profileView.tableView.reloadData()
//    }
    
    //MARK:- BUTTON ACTIONS
    @IBAction @objc func filterContent(_ sender: UIBarButtonItem) {
        if feedViewModel.currentState != .editing{
            setupFilterMenu()
        }
    }
    
    @IBAction func viewSettings(_ sender: UIBarButtonItem) {
        if feedViewModel.currentState != .editing{
            setupSettingsMenu()
        }
    }
}

//MARK:- NETWORK CALLS
extension ProfileViewController{
    
    func getFollowerCount(){
        profileViewModel.getFollowCount(useruuid: userInfo.useruuid) { [weak self] in
            self?.profileView.tableView.reloadData()
        }
    }
    
    func getFollowStatus(){
        guard let uuid = UserService.shared.uid, uuid != userInfo.useruuid else {
            return
        }
        profileViewModel.getFollowStatus(profileuuid: userInfo.useruuid) { [weak self] in
            self?.profileView.tableView.reloadRows(at: [ProfileView.TableViewConstants.profileIndexPath], with: .none)
        }
    }
    
    func updateFollowState(){
        guard let useruuid = UserService.shared.uid,
            let username = UserService.shared.username else { return }
        profileViewModel.updateFollowState(useruuid: useruuid, username: username, profileuuid: userInfo.useruuid) { [weak self] (error) in
            if let _ = error{
                self?.presentCustomAlertOnMainThread(title: "Follow Error", message: "We could not update your follow status.")
            }
            self?.getFollowerCount()
            self?.profileView.tableView.reloadRows(at: [ProfileView.TableViewConstants.profileIndexPath], with: .none)
        }
    }
    
    func getProfileImage(){
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.profilePictureService.getProfileImage(profileuuid: self.userInfo.useruuid) { [weak self] (image) in
                guard let self = self else { return }
                self.profileView.profileImage = image
                DispatchQueue.main.async { [weak self] in
                    self?.profileView.tableView.reloadData()
                }
            }
        }
    }
    
    func getCreditsCount(){
        profileViewModel.fetchCredits(useruuid: userInfo.useruuid) { [weak self] in
            self?.profileView.tableView.reloadData()
        }
    }
    
    func uploadPhoto(profilePhoto: UIImage){
        profileView.prepareForAsyncTask()
        profilePictureService.uploadPhoto(profileuuid: userInfo.useruuid, profilePhoto: profilePhoto) { [weak self] (result) in
            switch result{
            case .success(let image):
                if let image = image{
                    self?.profileView.profileImage = image
                    self?.presentCustomAlertOnMainThread(title: "Success!", message: "Your profile picture has been changed.")
                }else{
                    self?.profileView.profileImage = Constants.Images.defaultProfilePhoto
                    self?.presentCustomAlertOnMainThread(title: "Task failed successfully", message: "There appears to be a problem with displaying your picture. Perhaps use a different picture.")
                }
                self?.profileView.tableView.reloadRows(at: [ProfileView.TableViewConstants.profileIndexPath], with: .none)
            case .failure:
                self?.presentCustomAlertOnMainThread(title: "Upload error", message: "We were not able to save your new profile picture. Please try again.")
            }
            self?.profileView.setupAfterAsyncTask()
        }
    }
    
    func getSelfPosts(isRefreshed: Bool){
        fetchingMore = true
        feedViewModel.getPosts(useruuid: userInfo.useruuid, isRefreshed: isRefreshed, isSelfPost: true ) { [weak self] (error, endReached) in
            guard let self = self else { return }
            if isRefreshed { self.profileView.refreshControl.endRefreshing() }
            if error != nil{
                self.presentCustomAlertOnMainThread(title: "Post error", message: "We encountered a problem while grabbing more posts. Sorry for the inconvenience.")
            }else{
                if self.feedViewModel.filteredPosts.isEmpty && !endReached{
                    self.getSelfPosts(isRefreshed: false)
                }
                self.profileView.tableView.reloadData()
            }
            self.endReached = endReached
            self.fetchingMore = false
            self.profileView.setupAfterAsyncTask()
        }
    }
    
    @objc func refreshPosts(){
        if !fetchingMore{
            getSelfPosts(isRefreshed: true)
        }else{
            profileView.refreshControl.endRefreshing()
        }
        getFollowerCount()
        getCreditsCount()
    }
    
    func blockPost(post: PostDataModel, message: String, completion: @escaping ((Bool) -> Void)){
        guard let useruuid = UserService.shared.uid else { return }
        feedViewModel.blockPost(useruuid: useruuid, post: post, message: message) { [weak self] (error) in
            if error != nil{
                completion(false)
            }else{
                self?.profileView.tableView.reloadData()
                completion(true)
            }
        }
    }
    
    func blockUser(){
        guard let useruuid = UserService.shared.uid,
            let username = UserService.shared.username else { return }
        profileView.prepareForAsyncTask()
        feedViewModel.blockUser(useruuid: useruuid, username: username, blockedUseruuid: userInfo.useruuid, blockedUsername: userInfo.username) { [weak self] (error) in
            if let _ = error{
                self?.presentCustomAlertOnMainThread(title: "Block error", message: "An unknown error has occurred. Please try again.")
            }else{
                self?.profileView.setupAfterAsyncTask()
                self?.profileBlockProtocolDelegate?.didBlockUser()
                let username = self?.userInfo.username ?? ""
                self?.presentCustomAlertOnMainThread(title: "Success!", message: "\(username) has now been blocked.", completion: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    func logoutUser(){
        profileView.prepareForAsyncTask()
        UserService.shared.logout { [weak self] (error) in
            if let error = error{
                self?.profileView.setupAfterAsyncTask()
                self?.presentCustomAlertOnMainThread(title: "Logout error", message: error.localizedDescription)
            }else{
                if let tabBar = self?.tabBarController, let mainTab = tabBar as? MainTabBarViewController{
                    mainTab.navigateToLogin()
                }
            }
        }
    }
    
    func updateComment(cell: FeedTableViewCell, newComment: String){
        if let error = feedViewModel.validatePostComment(newComment: newComment){
            presentCustomAlertOnMainThread(title: "Post error", message: error.localizedDescription)
            cell.resetCommentTextView()
            feedViewModel.didFinishEditing()
            return
        }
        
        guard let post = cell.post else {
            cell.resetCommentTextView()
            feedViewModel.didFinishEditing()
            return
        }
        
        profileView.prepareForAsyncTask()
        feedViewModel.updateWithService(post: post, newComment: newComment) { [weak self] (error) in
            if let _ = error{
                self?.presentCustomAlertOnMainThread(title: "Update error", message: "Could not update this post's comment.")
            }else{
                self?.profileView.tableView.reloadData()
                self?.profileView.setupAfterAsyncTask()
                self?.feedViewModel.didFinishEditing()
                self?.postChangeProtocol?.didChangePostComment(post: post, newComment: newComment)
            }
        }
    }
    
    func deletePost(cell: FeedTableViewCell, completion: @escaping ((Bool) -> Void)){
        guard let post = cell.post else {
            completion(false)
            return
        }
        feedViewModel.delete(post) { (error) in
            if error == nil{
                completion(true)
            }else{
                completion(false)
            }
        }
    }
}

//MARK:- UITableView
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case ProfileView.TableViewConstants.profileSection:
            return userInfo != nil ? 1 : 0
        case ProfileView.TableViewConstants.feedSection:
            return feedViewModel.filteredPosts.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case ProfileView.TableViewConstants.profileSection:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as? ProfileTableViewCell{
                if let useruuid = UserService.shared.uid, userInfo.useruuid == useruuid{
                    cell.removeFollowButton()
                }else if UserService.shared.uid == nil{
                    cell.removeFollowButton()
                }
                cell.setupCell(profileImage: profileView.profileImage , username: userInfo.username, followerCount: profileViewModel.followerCountText, karmaCount: profileViewModel.karmaCountText, isFollowing: profileViewModel.isFollowing)
                if cell.profileDelegate == nil{
                    cell.profileDelegate = self
                }
                return cell
            }
        case ProfileView.TableViewConstants.feedSection:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell", for: indexPath) as? FeedTableViewCell{
                
                if cell.actionDelegate == nil && cell.editFeedCommentDelegate == nil{
                    cell.actionDelegate = self
                    cell.editFeedCommentDelegate = self
                }
                var beginEditing = false
                if feedViewModel.currentState == .editing, feedViewModel.editIndexPath == indexPath { beginEditing = true}
                cell.setupCell(post: feedViewModel.filteredPosts[indexPath.row], shouldFullyDisplay: feedViewModel.fullyDisplayedPosts[indexPath] != nil, willBeginEditingComment: beginEditing)
                if UserService.shared.uid == nil{
                    cell.setupAnonymous()
                }
                cell.tag = indexPath.row
                if DeviceDetection.isPad, !padEdgeCaseCheckDone && indexPath.row == 0{
                    padEdgeCaseCheckDone = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
                        UIView.performWithoutAnimation {
                            //                        tableView.reloadRows(at: [indexPath], with: .none)
                            tableView.beginUpdates()
                            tableView.endUpdates()
                        }
                    }
                }
                getCurrentVoteState(postuuid: feedViewModel.filteredPosts[indexPath.row].postuuid, cell: cell, tag: indexPath.row, indexPath: indexPath)
                return cell
            }
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == ProfileView.TableViewConstants.feedSection{
            guard let selfuuid = UserService.shared.uid else {
                let emptyAction = UISwipeActionsConfiguration(actions: [])
                return emptyAction
            }
            
            if selfuuid == userInfo.useruuid{
                let emptyAction = UISwipeActionsConfiguration(actions: [])
                return emptyAction
            }
            
            let post = feedViewModel.filteredPosts[indexPath.row]
            
            let report = UIContextualAction(style: .destructive, title: "Report") { [weak self] (action, view, success) in
                guard let self = self else { return }
                self.reportPostViewController = ReportPostViewController(finishedActionHandler: { [weak self] (reason) in
                    guard let self = self else { return }
                    self.reportPostViewController.customInputViewController.addActivityIndicator()
                    self.blockPost(post: post, message: reason, completion: { (didBlock) in
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            if didBlock{
                                success(true)
                                self.reportPostViewController.customInputViewController.setSuccessMessage("Success! Consider blocking this user if they continue to bother you.")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                                    self?.reportPostViewController.customInputViewController.dismiss(animated: true, completion: { [weak self] in
                                        self?.reportPostViewController.dismiss(animated: false, completion: nil)
                                        self?.reportPostViewController = nil
                                    })
                                }
                            }else{
                                self.reportPostViewController.customInputViewController.setMessage("An unexpected error has occurred. Please try again.", messageColor: UIColor.systemRed)
                            }
                        }
                    })
                }, cancelActionHandler: {
                    success(false)
                })
                self.reportPostViewController.modalPresentationStyle = .overFullScreen
                self.reportPostViewController.modalTransitionStyle = .crossDissolve
                self.present(self.reportPostViewController, animated: true, completion: nil)
            }
            report.image = #imageLiteral(resourceName: "Report")
            let actions = UISwipeActionsConfiguration(actions: [report])
            return actions
        }else{
            let emptyAction = UISwipeActionsConfiguration(actions: [])
            return emptyAction
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if UserService.shared.uid != nil,
            postChangeProtocol != nil,
            feedViewModel.currentState != .editing,
            let cell = tableView.cellForRow(at: indexPath) as? FeedTableViewCell{
            let post = feedViewModel.filteredPosts[indexPath.row]
            let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, success) in
                self?.feedViewModel.setEditIndexPath(indexPath)
                self?.feedViewModel.willBeginEditingComment()
                self?.profileView.tableView.reloadData()
                success(true)
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, success) in
                self?.setupDeletePostPrompt(cell: cell, success: { (didDelete) in
                    if didDelete{
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        self?.postChangeProtocol?.didDeletePost(post)
                    }
                    success(didDelete)
                })
            }
            let shareOptionAction = UIContextualAction(style: .normal, title: "Share") { [weak self] (action, view, success) in
                self?.openShareOptionsSheet(with: post)
                success(true)
            }
            editAction.image = #imageLiteral(resourceName: "SwipeEdit")
            editAction.backgroundColor = #colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)
            deleteAction.image = #imageLiteral(resourceName: "SwipeDelete")
            shareOptionAction.image = #imageLiteral(resourceName: "Share")
            shareOptionAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            let actions = UISwipeActionsConfiguration(actions: [deleteAction, shareOptionAction, editAction])
            return actions
        }else{
            let emptyAction = UISwipeActionsConfiguration(actions: [])
            return emptyAction
        }
    }
    
    // Prevent Jumpyness of the table view when reloading data --------
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == ProfileView.TableViewConstants.feedSection{
            cellHeights[indexPath] = cell.frame.size.height
        }else if indexPath.section == ProfileView.TableViewConstants.profileSection{
            profileCellHeight[indexPath] = cell.frame.size.height
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == ProfileView.TableViewConstants.feedSection{
            return cellHeights[indexPath] ?? UITableView.automaticDimension
        }else{
            return profileCellHeight[indexPath] ?? UITableView.automaticDimension
        }
    }
    //------------------------------------------------------------------
}

//MARK:- FeedTableViewProtocol
extension ProfileViewController: FeedTableViewCellProtocol, ProfileSegueProtocol{
    func upvotePost(cell: FeedTableViewCell) {
        upvote(cell: cell)
    }
    
    func downvotePost(cell: FeedTableViewCell) {
        downvote(cell: cell)
    }
    
    func commentOnPost(cell: FeedTableViewCell) {
        guard let cellPost = cell.post, feedViewModel.currentState != .editing else { return }
        navigateToComments(post: cellPost)
    }
    
    func linkToArticle(cell: FeedTableViewCell) {
        guard let cellPost = cell.post, feedViewModel.currentState != .editing else { return }
        openLink(url: cellPost.link ?? "")
    }
    
    func viewProfile(cell: FeedTableViewCell) { }
    
    func updatedDisplay(cell: FeedTableViewCell) {
        _updateDisplay(cell, tableView: profileView.tableView, isProfile: true)
    }
}

//MARK:- EditFeedCommentProtocol
extension ProfileViewController: EditFeedCommentProtocol{
    func updateHeightOfRow(cell: FeedTableViewCell) {
        updateCommentHeightHelper.updateHeight(textView: cell.commentTextView, tableView: profileView.tableView, cell: cell, cellType: .Feed)
    }
    
    func didEndEditingComment(cell: FeedTableViewCell, didChange: Bool) {
        if didChange{
            updateComment(cell: cell, newComment: cell.getComment())
        }else{
            feedViewModel.didFinishEditing()
            DispatchQueue.main.async{
            UIView.performWithoutAnimation { [weak self] in
                self?.profileView.tableView.reloadData()
//                self.profileView.tableView.reloadRows(at: [self.profileView.tableView.indexPath(for: cell)!], with: .none)
            }
            }
//            DispatchQueue.main.async { [weak self] in
//                self?.profileView.tableView.reloadData()
//            }
        }
    }
}

//MARK:- EditProtocol
extension ProfileViewController: EditUsernameProtocol{
    func didChangeField(text: String) {
        userInfo.username = text
        navigationItem.title = "\(userInfo.username)'s profile"
        getSelfPosts(isRefreshed: true)
        (tabBarController as? MainTabBarViewController)?.refreshHomeFeed()
    }
}

//MARK:- ProfileProtocol
extension ProfileViewController : ProfileProtocol {
    
    func didPressOnProfileImage(cell: ProfileTableViewCell) {
        if feedViewModel.currentState != .editing{
            setupProfileConfirmationMenu()
        }
    }
    
    func didPressOnFollowButton(cell: ProfileTableViewCell) {
        if feedViewModel.currentState != .editing{
            updateFollowState()
        }
    }
    
    func didPressOnFollowersButton(cell: ProfileTableViewCell) {
        let followersStoryboard = UIStoryboard(name: "Followers", bundle: nil)
        if let followersVC = followersStoryboard.instantiateViewController(withIdentifier: "FollowersViewController") as? FollowersViewController, feedViewModel.currentState != .editing{
            followersVC.userInfo = userInfo
            navigationController?.pushViewController(followersVC, animated: true)
        }
    }
}

// MARK:- INFINITE SCROLL
extension ProfileViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let (offsetY, contentHeight, frameHeight) = (scrollView.contentOffset.y, scrollView.contentSize.height , scrollView.frame.size.height)
        shouldGetMore(scrollOffsetY: offsetY, scrollContentHeight: contentHeight, scrollFrameHeight: frameHeight) { [weak self] (confirm) in
            guard let self = self else { return }
            if self.userInfo != nil, confirm && self.feedViewModel.currentState == .normal{
                self.getSelfPosts(isRefreshed: false)
            }
        }
    }
}

//MARK:- SETUP
extension ProfileViewController: FilterMenuProtocol{
    
    func setupUI(){
        profileView.refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        setupNavigationBarItems()
    }
    
    func setupNavigationBarItems(){
        if navigationItem.rightBarButtonItem == nil{
            let filterButton = UIBarButtonItem(image: UIImage(named: "Sort"), style: .plain, target: self, action: #selector(filterContent(_:)))
            guard let uuid = UserService.shared.uid else {
                navigationItem.rightBarButtonItem = filterButton
                return
            }
            let blockButton = UIBarButtonItem(image: #imageLiteral(resourceName: "blockIcon"), style: .plain, target: self, action: #selector(setupBlockUserPrompt))
            if uuid != userInfo.useruuid{
                navigationItem.rightBarButtonItems = [filterButton, blockButton]
            }else{
                navigationItem.rightBarButtonItem = filterButton
            }
        }
    }
    
    func callNecessaryNetworkCalls(){
        getProfileImage()
        getFollowerCount()
        getCreditsCount()
        getSelfPosts(isRefreshed: false)
        if UserService.shared.uid != nil{
            getFollowStatus()
        }
    }
    
    func setupFilterMenu(){
        setupFilterMenu(filterTitle: feedViewModel.filterTitle, filterTypes: [.oldest,.newest]) { [weak self] (newFilterType) in
            if let newFilterType = newFilterType{
                self?.changeFilterType(filterType: newFilterType)
            }
        }
    }
    
    func changeFilterType(filterType: FilterTypes){
        if feedViewModel.filterType != filterType{
            feedViewModel.filterType = filterType
            profileView.prepareForAsyncTask()
            if !feedViewModel.filteredPosts.isEmpty{
                profileView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
            getSelfPosts(isRefreshed: true)
        }
    }
    
    @objc func setupBlockUserPrompt(){
        presentCustomPrompt(promptTitle: "Block user", message: "Do you wish to block \(userInfo.username)?", acceptCompletion: { [weak self] in
            self?.blockUser()
        })
    }
    
    @objc func setupDeletePostPrompt(cell: FeedTableViewCell, success: @escaping ((Bool) -> Void)){
        presentCustomPrompt(promptTitle: "Delete post", message: "Are you sure you want to delete this post? You can't undo this action.", acceptCompletion: { [weak self] in
            self?.deletePost(cell: cell, completion: success)
            }, declineCompletion: {
                success(false)
        })
    }
    
    func setupProfileConfirmationMenu(){
        guard let uuid = UserService.shared.uid else{
            return
        }
        
        if uuid == userInfo.useruuid{
            let optionMenu = UIAlertController.create(title: nil, message: nil, alertStyle: .actionSheet)
            let editAction = UIAlertAction(title: "Change profile image?", style: .destructive) { [weak self] (action) in
                guard let self = self else { return }
                self.imagePicker.pickImage(self, { (image) in
                    if let image = image{
                        self.uploadPhoto(profilePhoto: image)
                    }
                })
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            cancelAction.setValue(Constants.Colors.orangeColor, forKey: "titleTextColor")
            optionMenu.addAction(editAction)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    func setupSettingsMenu(){
        let settingsMenuController = UIAlertController.create(title: "Settings", message: nil, alertStyle: .actionSheet)
        let logoutButton = UIAlertAction(title: "Logout", style: .destructive) { [weak self] (_) in
            self?.logoutUser()
        }
        logoutButton.setValue(UIImage(named: "outline_vertical_align_bottom_black_36pt_1x"), forKey: "image")
        let viewRulesButton = UIAlertAction(title: "Community Guidelines", style: .default) { [weak self] (_) in
            self?.navigateWithNCTo(storyboard: "CommunityGuidelines", identifer: "CommunityGuidelinesViewController")
        }
        viewRulesButton.setValue(UIImage(named: "outline_description_black_36pt_1x"), forKey: "image")
        let viewBlockedUsers = UIAlertAction(title: "View Blocked Users", style: .default) { [weak self] (_) in
            self?.navigateWithNCTo(storyboard: "ViewBlockedUsers", identifer: "ViewBlockedUsersViewController")
        }
        viewBlockedUsers.setValue(UIImage(named: "outline_visibility_black_36pt_1x"), forKey: "image")
        let changeUsernameButton = UIAlertAction(title: "Change Username", style: .default) { [weak self] (_) in
            guard let self = self else { return }
            let updateUsernameViewController = UpdateUsernameViewController()
            updateUsernameViewController.modalPresentationStyle = .overCurrentContext
            updateUsernameViewController.modalTransitionStyle = .crossDissolve
            updateUsernameViewController.editDelegate = self
            self.present(updateUsernameViewController, animated: true, completion: nil)
        }
        changeUsernameButton.setValue(UIImage(named: "outline_create_black_36pt_1x"), forKey: "image")
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelButton.setValue(Constants.Colors.orangeColor, forKey: "titleTextColor")
        settingsMenuController.addAction(viewBlockedUsers)
        settingsMenuController.addAction(viewRulesButton)
        settingsMenuController.addAction(changeUsernameButton)
        settingsMenuController.addAction(logoutButton)
        settingsMenuController.addAction(cancelButton)
        present(settingsMenuController, animated: true, completion: nil)
    }
}

extension ProfileViewController: ShareOptionsViewProtocol, ShareOptionsProtocol, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: AskToSignInProtocol{
    
    func navigateToLogin() {
        (tabBarController as? MainTabBarViewController)?.navigateToLogin()
    }
}
