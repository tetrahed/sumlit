//
//  FeedViewController.swift
//  SumLit
//
//  Created by Robert Chung on 5/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import MessageUI

class FeedViewController: UIViewController, InfiniteScrollProtocol, FeedViewModelProtocol
{
    var feedViewModel: FeedViewModel = FeedViewModel()
    var cellHeights: [IndexPath : CGFloat] = [:]
    var fetchingMore: Bool = false
    var endReached: Bool = false
    var leadingScreensForBatching: CGFloat = 3
    var shouldScrollToNewestPost = false
    var reportPostViewController: ReportPostViewController!
    @IBOutlet weak var feedView: FeedView!
    private var padEdgeCaseCheckDone = false
    
    //MARK:- VIEW LIFECYCLE
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getPosts(isRefreshed: false)
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let useruuid = UserService.shared.uid else { return }
        feedViewModel.updateBlockInfo(useruuid: useruuid) { [weak self] in
            guard let self = self else {
                return
            }
            self.feedView.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.feedViewModel.filteredPosts.isEmpty && !self.fetchingMore{
            self.getPosts(isRefreshed: true)
        }
    }
    
    //MARK:- BUTTON ACTIONS
    @IBAction func filterContent(_ sender: UIBarButtonItem) {
        setupFilterMenu()
    }
}

//MARK:- NETWORK CALLS
extension FeedViewController
{
    func getPosts(isRefreshed: Bool, completion: ((_ success: Bool) -> ())? = nil)
    {
        fetchingMore = true
        feedViewModel.getPosts(isRefreshed: isRefreshed, isSelfPost: false) { [weak self] (error, endReached) in
            guard let self = self else { return }
            if isRefreshed{ self.feedView.refreshControl.endRefreshing()}
            if error != nil{
                self.presentCustomAlertOnMainThread(title: "Post error", message: "We encountered a problem while grabbing more posts. Sorry for the inconvenience.")
            }else{
                if self.feedViewModel.filteredPosts.isEmpty{
                    if endReached{
                        self.feedView.setEmptyTableViewMessage()
                        completion?(false)
                    }else{
                        self.getPosts(isRefreshed: false)
                    }
                }else{
                    if completion != nil{
                        completion?(true)
                    }else{
                        self.feedView.tableView.reloadData()
                    }
                }
            }
            self.endReached = endReached
            self.fetchingMore = false
            self.feedView.setupAfterAsyncTask()
        }
    }
    
    @objc func refreshPosts(){
        if !fetchingMore{
            getPosts(isRefreshed: true)
        }else{
            feedView.refreshControl.endRefreshing()
        }
    }
    
    func refreshAfterFinishUploading(){
        if !fetchingMore{
            shouldScrollToNewestPost = true
            getPosts(isRefreshed: true) { [weak self] (success) in
                guard let self = self,
                    let uid = UserService.shared.uid else { return }
                if success{
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({
                        if self.feedViewModel.filterType == .newest{
                            for (index,value) in self.feedViewModel.filteredPosts.enumerated() {
                                if value.useruuid == uid{
                                    self.feedView.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: false)
                                    break
                                }
                            }
                        }
                    })
                    self.feedView.tableView.reloadData()
                    CATransaction.commit()
                }
            }
        }
    }
    
    func blockPost(post: PostDataModel, message: String, completion: @escaping ((Bool) -> Void)){
        guard let useruuid = UserService.shared.uid else { return }
        feedViewModel.blockPost(useruuid: useruuid, post: post, message: message) { [weak self] (error) in
            if error != nil{
                completion(false)
            }else{
                self?.feedView.tableView.reloadData()
                completion(true)
            }
        }
    }
}

//MARK:- FeedTableViewCellProtocol
extension FeedViewController : FeedTableViewCellProtocol, ProfileSegueProtocol
{
    func upvotePost(cell: FeedTableViewCell)
    {
        upvote(cell: cell)
    }
    
    func downvotePost(cell: FeedTableViewCell)
    {
        downvote(cell: cell)
    }
    
    func commentOnPost(cell: FeedTableViewCell) {
        guard let cellPost = cell.post else { return }
        navigateToComments(post: cellPost)
    }
    
    func linkToArticle(cell: FeedTableViewCell) {
        guard let cellPost = cell.post else { return }
        openLink(url: cellPost.link ?? "")
    }
    
    func viewProfile(cell: FeedTableViewCell) {
        guard let cellPost = cell.post else { return }
        segueToProfile(viewController: self, useruuid: cellPost.useruuid ?? "", username: cellPost.username ?? "")
    }
    
    func updatedDisplay(cell: FeedTableViewCell) {
        _updateDisplay(cell, tableView: feedView.tableView)
        cell.layoutIfNeeded()
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension FeedViewController : UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if feedViewModel.filteredPosts.isEmpty{
            feedView.tableView.alpha = 0
        }else{
            feedView.tableView.alpha = 1
        }
        return feedViewModel.filteredPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell", for: indexPath) as? FeedTableViewCell
        {
            if cell.actionDelegate == nil{
                cell.actionDelegate = self
            }
            cell.tag = indexPath.row
            let shouldFullyDisplay = feedViewModel.fullyDisplayedPosts[indexPath] != nil //|| didChangeDyanmicFontSize
            cell.setupCell(post: feedViewModel.filteredPosts[indexPath.row], shouldFullyDisplay: shouldFullyDisplay)
            if UserService.shared.uid == nil{
                cell.setupAnonymous()
            }
            getCurrentVoteState(postuuid: feedViewModel.filteredPosts[indexPath.row].postuuid, cell: cell, tag: indexPath.row, indexPath: indexPath)
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
            return cell
        }
        return UITableViewCell()
    }
    
    // Prevent Jumpyness of the table view when reloading data --------
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? UITableView.automaticDimension
    }
    //------------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let selfuuid = UserService.shared.uid else {
            let emptyAction = UISwipeActionsConfiguration(actions: [])
            return emptyAction
        }
        
        if selfuuid == feedViewModel.filteredPosts[indexPath.row].useruuid {
            let emptyAction = UISwipeActionsConfiguration(actions: [])
            return emptyAction
        }
        
        let report = UIContextualAction(style: .destructive, title: "Report")
        { [weak self] (action, view, success) in
            guard let self = self else { return }
            guard let cell = tableView.cellForRow(at: indexPath) as? FeedTableViewCell, let post = cell.post else {
                success(false)
                return
            }
            
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
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let post = feedViewModel.filteredPosts[indexPath.row]
        
        let shareOptionAction = UIContextualAction(style: .normal, title: "Share") { [weak self] (action, view, success) in
            self?.openShareOptionsSheet(with: post)
            success(true)
        }
        shareOptionAction.image = #imageLiteral(resourceName: "Share")
        shareOptionAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        let actions = UISwipeActionsConfiguration(actions: [shareOptionAction])
        return actions
    }
}

// MARK:- INFINITE SCROLL
extension FeedViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        let (offsetY, contentHeight, frameHeight) = (scrollView.contentOffset.y, scrollView.contentSize.height , scrollView.frame.size.height)
        shouldGetMore(scrollOffsetY: offsetY, scrollContentHeight: contentHeight, scrollFrameHeight: frameHeight) { [weak self] (confirm) in
            if confirm{
                self?.getPosts(isRefreshed: false)
            }
        }
    }
}

//MARK:- ProfileBlockProtocol
extension FeedViewController: ProfileBlockProtocol{
    func didBlockUser() {
        guard let useruuid = UserService.shared.uid else { return }
        feedViewModel.updateBlockInfo(useruuid: useruuid) { [weak self] in
            guard let self = self else {
                return
            }
            self.feedView.tableView.reloadData()
        }
    }
}

//MARK:- Update Feed After Change
extension FeedViewController{
    func updateAfterCommentChange(post: PostDataModel, newComment: String){
        updateCommentFor(post: post, newComment: newComment)
        feedView.tableView.reloadData()
    }
    
    func updateAfterDeletingPost(_ post: PostDataModel) {
        feedViewModel.removePostIfNecessary(post)
        feedView.tableView.reloadData()
    }
}

//MARK:- SETUP
extension FeedViewController: FilterMenuProtocol{
    
    func setup(){
        feedView.refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
        navigationItem.title = "Feed"
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
            feedView.prepareForAsyncTask()
            if !feedViewModel.filteredPosts.isEmpty{
                feedView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
            getPosts(isRefreshed: true)
        }
    }
}

extension FeedViewController: ShareOptionsViewProtocol, ShareOptionsProtocol, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
