//
//  CommentsViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 5/24/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CommentsViewController: UIViewController, InfiniteScrollProtocol
{
    var post: PostDataModel!
    private var commentsViewModel : CommentsViewModel!
    private let likesLeadingScreensForBatching: CGFloat = 1.5
    var cellHeights: [IndexPath : CGFloat] = [:]
    var fetchingMore: Bool = false
    var endReached: Bool = false
    var leadingScreensForBatching: CGFloat = 2.5
    let updateCommentHeightHelper = UpdateCommentHeightHelper()
    var opCommentDataModel : OPCommentDataModel!
    var collapsedCells : [IndexPath] = []
//    private var observer: NSObjectProtocol?
    
    // MARK:- Outlets
    
    @IBOutlet weak var commentsView: CommentsView!
    
    // MARK:- View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsViewModel = CommentsViewModel(postuuid: post.postuuid)
        setupUI()
        fetchParentComments(isRefreshed: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = commentsView.customDistanceFromTextField
        view.endEditing(true)
//        observer = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] notification in
//            self?.commentsView.tableView.beginUpdates()
//            self?.commentsView.tableView.endUpdates()
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = Constants.keyboardConstants.keyboardDistanceFromTextField
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        NotificationCenter.default.removeObserver(observer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UserService.shared.uid == nil{
            commentsView.hideAddingComments()
        }
    }
    
    // MARK:- Button actions
    @IBAction func handleAddNewComment(_ sender: UIButton) {
        commentsView.newCommentTextView.resignFirstResponder()
        commentsView.disableAddingNewComments()
        addNewComment(sender: sender, comment: commentsView.didBeginAddComment ? commentsView.newCommentTextView.text : "")
    }
    
    @IBAction func changeReplyingToState(_ sender: UIButton) {
        switch commentsView.replyingToState{
        case .addUsername:
            commentsView.replyingToState = .doNotAdd
        case .doNotAdd:
            commentsView.replyingToState = .addUsername
        }
    }
    
    @objc func handleFilterContent(){
        if commentsViewModel.currentState == .normal{
            setupFilterMenu()
        }
    }
}

//MARK:- Network calls

extension CommentsViewController{
    
    func fetchParentComments(isRefreshed: Bool){
        fetchingMore = true
        commentsViewModel.fetchParentComments(isRefreshed: isRefreshed) { [weak self] (error,endReached)  in
            guard let self = self else { return }
            if isRefreshed{ self.commentsView.refreshControl.endRefreshing()}
            if error == nil{
                if self.commentsViewModel.commentData.isEmpty{
                    if !endReached{
                        self.fetchParentComments(isRefreshed: false)
                    }else{
                        self.commentsView.tableViewState = .noComments
                    }
                }else{
                    self.commentsView.tableViewState = .displayComments
                }
            }
            self.endReached = endReached
            self.commentsView.tableView.reloadData()
            self.fetchingMore = false
            self.commentsView.setupAfterAsyncTask()
        }
    }
    
    @objc func refreshComments(){
        if !fetchingMore && commentsViewModel.currentState == .normal{
            fetchParentComments(isRefreshed: true)
        }else{
            commentsView.refreshControl.endRefreshing()
        }
    }
    
    @objc func cancelAddingNewComment(){
        commentsView.newCommentTextView.resignFirstResponder()
        commentsView.newCommentTextView.text.removeAll()
        commentsView.resetAddComment()
        commentsViewModel.addingCommentState = .parent
    }
    
    func addNewComment(sender: UIButton, comment: String){
        if let error = commentsViewModel.validate(newComment: comment){
            presentCustomAlertOnMainThread(title: "Comment error", message: error.localizedDescription)
            commentsView.enableAddingNewComments()
        }else{
            guard let useruuid = UserService.shared.uid else { return }
            commentsViewModel.setStateToAddNewComment()
//            DispatchQueue.main.async {
////                if #available(iOS 13, *){
////                    QuickSetupSpinner.start(from: sender, style: .white, backgroundColor: UIColor.init(named: "SLAddCommentBackground")!, baseColor: .white)
////                }else{
//                    QuickSetupSpinner.start(from: sender, style: .white, backgroundColor: .systemGray, baseColor: .white)
////                }
            //}
            commentsView.prepareForAddingCommentTask()
            switch commentsViewModel.addingCommentState {
            case .parent:
                commentsViewModel.addNewParentComment(useruuid: useruuid, posteruuid: post.useruuid ?? "", comment: comment) { (error) in
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        if let _ = error{
                            self.presentCustomAlertOnMainThread(title: "Comment error", message: "We were not able to add your comment at this time. Please try again.")
                            self.commentsView.enableAddingNewComments()
                        }else{
                            
                            // MARK:- SCARY
                            
                            if !self.fetchingMore{
                                self.fetchParentComments(isRefreshed: false)
                            }
                            self.commentsView.resetAddComment()
                            self.commentsView.tableViewState = .displayComments
                            self.commentsViewModel.setStateToNormal()
                            self.commentsViewModel.addingCommentState = .parent
                        }
                        //QuickSetupSpinner.stop()
                    }
                }
            case .reply:
                guard let object = commentsView.replyingToObject else { return }
                commentsViewModel.addNewReplyComment(parentCommentuuid: object.parentCommentuuid, replyToUseruuid: object.RTPreplyingToUseruuid, needToGrabReplyingToUsername: commentsView.replyingToState == .addUsername ? true : false, useruuid: useruuid, posteruuid: post.useruuid ?? "", username: UserService.shared.username ?? "", comment: comment) { (error) in
                    DispatchQueue.main.async{ [weak self] in
                        guard let self = self else { return }
                        if let _ = error{
                            self.presentCustomAlertOnMainThread(title: "Comment error", message: "We were not able to add your comment at this time. Please try again.")
                            self.commentsView.enableAddingNewComments()
                        }else{
                            self.commentsView.resetAddComment()
                            self.commentsViewModel.setStateToNormal()
                            self.commentsView.tableView.reloadData()
                            self.commentsViewModel.addingCommentState = .parent
                        }
                        //QuickSetupSpinner.stop()
                    }
                }
                //break
            }
        }
    }
    
    func updateComment(cell: CommentsTableViewCell, newComment: String){
        if let error = commentsViewModel.validate(newComment: newComment){
            presentCustomAlertOnMainThread(title: "Editing error", message: error.localizedDescription)
            cell.resetCommentTextView()
            commentsViewModel.setStateToNormal()
            return
        }
        guard let indexPath = commentsView.tableView.indexPath(for: cell) else {
            cell.resetCommentTextView()
            commentsViewModel.setStateToNormal()
            return
        }
        commentsView.prepareForAsyncTask()
        if let commentDataModel = commentsViewModel.commentData[indexPath.row] as? CommentDataModel{
            commentsViewModel.updateParentComment(commentDataModel: commentDataModel, newComment: newComment) { [weak self] (error) in
                if let _ = error{
                    self?.presentCustomAlertOnMainThread(title: "Editing Error", message: "Sorry, we were not able to save your new comment.")
                }
                self?.commentsView.tableView.reloadData()
                self?.commentsView.setupAfterAsyncTask()
                self?.commentsViewModel.setStateToNormal()
            }
        }else if let replyDataModel = commentsViewModel.commentData[indexPath.row] as? ReplyCommentDataModel{
            commentsViewModel.updateReplyComment(replyDataModel: replyDataModel, newComment: newComment) { [weak self] (error) in
                if let _ = error{
                    self?.presentCustomAlertOnMainThread(title: "Editing error", message: "Sorry, we were not able to save your new comment.")
                }
                self?.commentsView.tableView.reloadData()
                self?.commentsView.setupAfterAsyncTask()
                self?.commentsViewModel.setStateToNormal()
            }
        }else{
            presentCustomAlertOnMainThread(title: "Editing error", message: CustomErrors.GeneralErrors.unknownError.localizedDescription)
            cell.resetCommentTextView()
            commentsViewModel.setStateToNormal()
        }
    }
    
    func deleteParentComment(commentDataModel: CommentDataModel){
        commentsView.prepareForAsyncTask()
        commentsViewModel.deleteParentComment(commentDataModel: commentDataModel) { [weak self] (error) in
            if error != nil{
                self?.presentCustomAlertOnMainThread(title: "Error", message: "Could not delete your comment. Please try again.")
            }else{
                DispatchQueue.main.async {
                    self?.commentsView.setupAfterAsyncTask()
                    self?.commentsView.tableView.reloadData()
                }
            }
        }
    }
    
    func deleteReplyComment(replyDataModel: ReplyCommentDataModel){
        commentsView.prepareForAsyncTask()
        commentsViewModel.deleteReplyComment(replyDataModel: replyDataModel) { [weak self] (error) in
            if error != nil{
                self?.presentCustomAlertOnMainThread(title: "Error", message: "Could not delete your comment. Please try again.")
            }else{
                DispatchQueue.main.async {
                    self?.commentsView.setupAfterAsyncTask()
                    self?.commentsView.tableView.reloadData()
                }
            }
        }
    }
}

// MARK:- CommentsTableViewCellProtocol

extension CommentsViewController: CommentsTableViewCellProtocol, ProfileSegueProtocol{
    
    func replyToPoster(cell: CommentsTableViewCell) {
        guard let indexPath = commentsView.tableView.indexPath(for: cell) else { return }
        commentsViewModel.addingCommentState = .reply
        if let commentDataModel = commentsViewModel.commentData[indexPath.row] as? CommentDataModel {
            commentsView.replyingToObject = commentDataModel
            commentsView.newCommentTextView.becomeFirstResponder()
        }else if let replyDataModel = commentsViewModel.commentData[indexPath.row] as? ReplyCommentDataModel{
            commentsView.replyingToObject = replyDataModel
            commentsView.newCommentTextView.becomeFirstResponder()
        }
    }
    
    func collapse(cell: CommentsTableViewCell, _ shouldCollapse: Bool) {
        guard let indexPath = commentsView.tableView.indexPath(for: cell), indexPath != commentsViewModel.indexPathToEdit else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if let indexPath = self.commentsView.tableView.indexPath(for: cell){
                if shouldCollapse{
                    self.collapsedCells.append(indexPath)
                }else{
                    self.collapsedCells = self.collapsedCells.filter { $0 != indexPath }
                }
                UIView.performWithoutAnimation {
                    self.commentsView.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    func viewCommentCreatorProfile(cell: CommentsTableViewCell) {
        guard let indexPath = commentsView.tableView.indexPath(for: cell), commentsViewModel.currentState != .editing else { return }
        if let commentDataModel = commentsViewModel.commentData[indexPath.row] as? CommentDataModel, let username = commentDataModel.username {
            segueToProfile(viewController: self, useruuid: commentDataModel.useruuid, username: username)
        }else if let replyDataModel = commentsViewModel.commentData[indexPath.row] as? ReplyCommentDataModel, let username = replyDataModel.username{
            segueToProfile(viewController: self, useruuid: replyDataModel.useruuid, username: username)
        }
    }
    
    func viewRepliedToProfile(cell: CommentsTableViewCell) {
        guard let indexPath = commentsView.tableView.indexPath(for: cell), commentsViewModel.currentState != .editing else { return }
        if let replyDataModel = commentsViewModel.commentData[indexPath.row] as? ReplyCommentDataModel, let repliedToUsername = replyDataModel.repliedToUsername{
            segueToProfile(viewController: self, useruuid: replyDataModel.repliedToUseruuid, username: repliedToUsername)
        }
    }
    
    func upvoteComment(cell: CommentsTableViewCell) {
        guard let useruuid = UserService.shared.uid, let indexPath = commentsView.tableView.indexPath(for: cell) else {
                return
        }
        
        cell.disableUpvoteButton()
        
        if let commentDataModel = commentsViewModel.commentData[indexPath.row] as? CommentDataModel{
            commentsViewModel.upvoteParentComment(useruuid: useruuid, comment: commentDataModel) { [weak self] (result) in
                guard let self = self else { return }
                cell.enableUpvoteButton()
                switch result{
                case .success(let newComment):
                    cell.updateUpvoteUI(comment: newComment)
                case .failure(_):
                    self.presentCustomAlertOnMainThread(title: "Upvote error", message: "We were not able to upvote this comment at the moment. Please try again.")
                }
            }
        }else if let replyDataModel = commentsViewModel.commentData[indexPath.row] as? ReplyCommentDataModel{
            commentsViewModel.upvoteReplyComment(useruuid: useruuid, reply: replyDataModel) { [weak self] (result) in
                guard let self = self else { return }
                cell.enableUpvoteButton()
                switch result{
                case .success(let newComment):
                    cell.updateUpvoteUI(comment: newComment)
                case .failure(_):
                    self.presentCustomAlertOnMainThread(title: "Upvote error", message: "We were not able to upvote this comment at the moment. Please try again.")
                }
            }
        }
    }
    
    func updateHeightOfRow(cell: CommentsTableViewCell) {
        updateCommentHeightHelper.updateHeight(textView: cell.commentTextView, tableView: commentsView.tableView, cell: cell, cellType: .Comment)
    }
    
    func didEndEditingComment(cell: CommentsTableViewCell, didChange: Bool) {
        IQKeyboardManager.shared.keyboardDistanceFromTextField = commentsView.customDistanceFromTextField
        if didChange{
            updateComment(cell: cell, newComment: cell.getComment())
        }else{
            commentsViewModel.setStateToNormal()
        }
        commentsView.enableAddingNewComments()
    }
}

// MARK:- Tableview delegate, datasouce

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return CommentsView.TableViewConstants.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section{
        case CommentsView.TableViewConstants.titleSection:
            return 1
        case CommentsView.TableViewConstants.opCommentSection:
            return 1
        case CommentsView.TableViewConstants.loadingSection:
            if commentsView.tableViewState == .inital { return 1 }
        case CommentsView.TableViewConstants.noCommentsSection:
            if commentsView.tableViewState == .noComments { return 1 }
        case CommentsView.TableViewConstants.commentSection:
            return commentsView.tableViewState == .displayComments ? commentsViewModel.commentData.count : 0
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch indexPath.section{
            
        case CommentsView.TableViewConstants.titleSection:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTitleTableViewCell") as? CommentsTitleTableViewCell{
                cell.titleLabel.text = post.title
                return cell
            }
        case CommentsView.TableViewConstants.opCommentSection:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "OPCommentTableViewCell") as? OPCommentTableViewCell {
                cell.configure(with: opCommentDataModel)
                cell.viewProfile = { [weak self] in
                    guard let self = self else { return }
                    self.segueToProfile(viewController: self, useruuid: self.opCommentDataModel.useruuid, username: self.opCommentDataModel.username)
                }
                return cell
            }
        case CommentsView.TableViewConstants.loadingSection:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCommentTableViewCell") as? LoadingCommentTableViewCell{
                cell.activityIndicator.startAnimating()
                return cell
            }
        case CommentsView.TableViewConstants.noCommentsSection:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "NoCommentTableViewCell"){
                return cell
            }
        case CommentsView.TableViewConstants.commentSection:
            if let commentModel = commentsViewModel.commentData[indexPath.row] as? CommentDataModel{
                if !commentModel.wasDeleted, let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTableViewCell") as? CommentsTableViewCell{
                    
                    if cell.commentsTableViewCellDelegate == nil{
                        cell.commentsTableViewCellDelegate = self
                    }
                    if UserService.shared.uid == nil{
                        cell.setupAnonymous()
                    }
                    var beginEditing = false
                    if commentsViewModel.currentState == .editing, indexPath == commentsViewModel.indexPathToEdit{ beginEditing = true }
                    if beginEditing{
                        if collapsedCells.contains(indexPath){
                            collapsedCells = collapsedCells.filter{ $0 != indexPath }
                        }
                    }
                    cell.setupCell(comment: commentModel, willBeginEditingComment: beginEditing, shouldBeCollapsed: collapsedCells.contains(indexPath))
                    return cell
                }else if let cell = tableView.dequeueReusableCell(withIdentifier: CommentDeletedTableViewCell.identifer) as? CommentDeletedTableViewCell{
                    cell.configure(indented: false, createdAt: commentModel.createdAt)
                    return cell
                }
            }else if let replyCommentDataModel = commentsViewModel.commentData[indexPath.row] as? ReplyCommentDataModel{
                
                if !replyCommentDataModel.wasDeleted, let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsTableViewCell") as? CommentsTableViewCell{
                    
                    if cell.commentsTableViewCellDelegate == nil{
                        cell.commentsTableViewCellDelegate = self
                    }
                    if UserService.shared.uid == nil{
                        cell.setupAnonymous()
                    }
                    var beginEditing = false
                    if commentsViewModel.currentState == .editing, indexPath == commentsViewModel.indexPathToEdit{ beginEditing = true }
                    if beginEditing{
                        if collapsedCells.contains(indexPath){
                            collapsedCells = collapsedCells.filter{ $0 != indexPath }
                        }
                    }
                    cell.setupCell(comment: replyCommentDataModel, willBeginEditingComment: beginEditing, shouldBeCollapsed: collapsedCells.contains(indexPath))
                    return cell
                }else if let cell = tableView.dequeueReusableCell(withIdentifier: CommentDeletedTableViewCell.identifer) as? CommentDeletedTableViewCell{
                    cell.configure(indented: true, createdAt: replyCommentDataModel.createdAt)
                    return cell
                }
            } else if let loadRepliesDataModel = commentsViewModel.commentData[indexPath.row] as? LoadRepliesDataModel, let cell = tableView.dequeueReusableCell(withIdentifier: LoadRepliesTableViewCell.storyboardIdentifier) as? LoadRepliesTableViewCell{
                cell.configure(loadData: loadRepliesDataModel)
                if cell.loadRepliesDelegate == nil{
                    cell.loadRepliesDelegate = self
                }
                if commentsViewModel.loadingReplies.contains(indexPath){
                    cell.shouldRunActivityIndicator()
                }
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let emptyAction = UISwipeActionsConfiguration(actions: [])
        return emptyAction
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let emptyAction = UISwipeActionsConfiguration(actions: [])
        guard let uuid = UserService.shared.uid, commentsViewModel.currentState == .normal else{
                return emptyAction
        }
        
        if let comment = commentsViewModel.commentData[indexPath.row] as? CommentDataModel{
            if comment.useruuid != uuid || comment.wasDeleted{
                return emptyAction
            }
        } else if let replyComment = commentsViewModel.commentData[indexPath.row] as? ReplyCommentDataModel{
            if replyComment.useruuid != uuid || replyComment.wasDeleted{
                return emptyAction
            }
        }else if commentsViewModel.commentData[indexPath.row] is LoadRepliesDataModel{
            return emptyAction
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, success) in
            self?.commentsView.disableAddingNewComments()
            IQKeyboardManager.shared.keyboardDistanceFromTextField = Constants.keyboardConstants.keyboardDistanceFromTextField
            self?.commentsViewModel.setCurrentIndexPathToEdit(indexPath)
            self?.commentsViewModel.setStateToEditing()
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    if let visibleRows = self?.commentsView.tableView.indexPathsForVisibleRows, !visibleRows.contains(indexPath){
                        self?.commentsView.tableView.scrollToRow(at: indexPath, at: .none , animated: false)
                    }
                })
            })
            self?.commentsView.tableView.reloadData()
            CATransaction.commit()
            success(true)
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, success) in
            guard let self = self else { return success(false) }
            if let comment = self.commentsViewModel.commentData[indexPath.row] as? CommentDataModel{
                self.deleteParentComment(commentDataModel: comment)
            } else if let replyComment = self.commentsViewModel.commentData[indexPath.row] as? ReplyCommentDataModel{
                self.deleteReplyComment(replyDataModel: replyComment)
            }
        }
        editAction.image = #imageLiteral(resourceName: "SwipeEdit")
        editAction.backgroundColor = #colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)
        deleteAction.image = #imageLiteral(resourceName: "SwipeDelete")
        let actions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return actions
    }
    
    // Prevent Jumpyness of the table view when reloading data --------
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == CommentsView.TableViewConstants.commentSection{
            cellHeights[indexPath] = cell.frame.size.height
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == CommentsView.TableViewConstants.commentSection{
            return cellHeights[indexPath] == nil ?  UITableView.automaticDimension : cellHeights[indexPath]!
        }else{
            return UITableView.automaticDimension
        }
    }
    //------------------------------------------------------------------
}

// MARK:- ProfileBlockProtocol

extension CommentsViewController : ProfileBlockProtocol{
    func didBlockUser() {
        guard let useruuid = UserService.shared.uid else { return }
        commentsViewModel.updateBlockInfo(useruuid: useruuid) { [weak self] in
            self?.commentsView.tableView.reloadData()
        }
    }
}

// MARK:- LoadRepliesProtocol
extension CommentsViewController : LoadRepliesProtocol{
    func startGettingReplies(cell: LoadRepliesTableViewCell) {
        if let indexPath = commentsView.tableView.indexPath(for: cell){
            if !commentsViewModel.loadingReplies.contains(indexPath){
                commentsViewModel.loadingReplies.append(indexPath)
            }
            if let loadRepliesDataModel = commentsViewModel.commentData[indexPath.row] as? LoadRepliesDataModel{
                commentsViewModel.fetchReplyComments(at: indexPath, parentCommentuuid: loadRepliesDataModel.parentCommentUuid) { [weak self] in
                    guard let self = self else { return }
                    self.commentsView.tableView.reloadData()
                }
            }
        }
    }
}

// MARK:- INFINITE SCROLL
extension CommentsViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let (offsetY,contentHeight, frameHeight) = (scrollView.contentOffset.y,scrollView.contentSize.height, scrollView.frame.size.height)
        shouldGetMore(scrollOffsetY: offsetY, scrollContentHeight: contentHeight, scrollFrameHeight: frameHeight) { [weak self] (confirm) in
            if confirm && self?.commentsViewModel.currentState != .editing{
                self?.fetchParentComments(isRefreshed: false)
            }
        }
    }
}

// MARK:- Setup
extension CommentsViewController: FilterMenuProtocol{
    func setupUI(){
        navigationItem.title = "Comments"
        IQKeyboardManager.shared.keyboardDistanceFromTextField = commentsView.customDistanceFromTextField
        commentsView.refreshControl.addTarget(self, action: #selector(refreshComments), for: .valueChanged)
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAddingNewComment))
        bar.items = [cancel]
        bar.sizeToFit()
        commentsView.newCommentTextView.inputAccessoryView = bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Sort"), style: .plain, target: self, action: #selector(handleFilterContent))
    }
    
    func setupFilterMenu(){
        setupFilterMenu(filterTitle: commentsViewModel.filterMenuTitle, filterTypes: [.oldest,.newest,.upvotes]) { [weak self] (filterType) in
            if let filterType = filterType{
                self?.changeFilterType(filterType: filterType)
            }
        }
    }
    
    func changeFilterType(filterType: FilterTypes){
        if commentsViewModel.filterType != filterType{
            commentsViewModel.filterType = filterType
            commentsView.prepareForAsyncTask()
            if !commentsViewModel.commentData.isEmpty{
                commentsView.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
            fetchParentComments(isRefreshed: true)
        }
    }
}

// MARK:- UITextViewDelegate For Adding New Comments
extension CommentsViewController: UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if commentsViewModel.currentState == .normal {
            commentsView.willBeginAddingComment()
            commentsViewModel.setStateToAddNewComment()
            navigationController?.setNavigationBarHidden(true, animated: false)
            return true
        }
        return false
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        commentsView.didEndAddingComment()
        commentsViewModel.setStateToNormal()
        textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        navigationController?.setNavigationBarHidden(false, animated: false)
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }else{
            return true
        }
    }
}
