//
//  CommentsView.swift
//  SumLit
//
//  Created by Junior Etrata on 9/4/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class CommentsView: UIView {
    
    struct CommentViewConstants{
        static let newCommentInitialText = "Add a comment."
        static let loadingErrorMessage = "There appears to be no comments available for this post."
        static let distanceFromTextField: CGFloat = 5
    }
    
    struct TableViewConstants{
        static let numberOfSections = 5
        static let titleSection = 0
        static let opCommentSection = 1
        static let commentSection = 2
        static let loadingSection = 3
        static let noCommentsSection = 4
        
        static let newCommentHeightInitial: CGFloat = 45
        static let newCommentHeightEditing: CGFloat = 75
        static let newCommentHeightInitialiPad: CGFloat = 50
        static let newCommentHeightEditingiPad: CGFloat = 90
    }
    
    enum TableViewState{
        case inital
        case displayComments
        case noComments
    }
    
    enum ReplyingToState{
        case addUsername
        case doNotAdd
    }
    
    // MARK:- Outlets
    
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private weak var newCommentViewContainer: UIView!
    
    @IBOutlet private weak var addCommentActivityIndicator: UIActivityIndicatorView!
    @IBOutlet private(set) weak var newCommentTextView: UITextView!{
        didSet{
            newCommentTextView.addPadding(top: 10, bottom: 10, left: 10, right: 10)
            if #available(iOS 13.0, *) {
                newCommentTextView.tintColor = UIColor.label
            } else {
                // Fallback on earlier versions
                newCommentTextView.tintColor = UIColor.black
            }//Constants.Colors.l
            newCommentTextView.roundCorners(by: 5)
        }
    }
    @IBOutlet fileprivate weak var addCommentButton: UIButton!{
        didSet{
            addCommentButton.roundCorners(by: 5)
        }
    }
    @IBOutlet fileprivate weak var newCommentHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var replyingToButton: UIButton!
    @IBOutlet private weak var topAddCommentViewContainerConstraint: NSLayoutConstraint!
    
    var tableViewState : TableViewState = .inital
    var replyingToObject : ReplyingToProtocol? = nil
    
    var replyingToState : ReplyingToState = .addUsername {
        didSet{
            switch replyingToState{
            case .addUsername:
                replyingToButton.backgroundColor = Constants.Colors.orangeColor//UIColor.init(named: "SLOrange")!//UIColor.systemOrange
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.replyingToButton.alpha = 1
                }
            case .doNotAdd:
                replyingToButton.backgroundColor = UIColor.darkGray
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.replyingToButton.alpha = 0.6
                }
            }
        }
    }
    
    var customDistanceFromTextField: CGFloat{
        return CommentViewConstants.distanceFromTextField
    }
    
    fileprivate let asyncBackgroundView : UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Colors.loadingColor
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let refreshControl = UIRefreshControl()
    private(set) var didBeginAddComment = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 10.0, *){
            tableView.refreshControl = refreshControl
        }else{
            tableView.addSubview(refreshControl)
        }
        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = UITableView.automaticDimension
//        replyingToButton.isHidden = true
    }
}

//MARK:- PUBLIC API
extension CommentsView{
    
    func hideReplyToButton(){
        replyingToButton.isHidden = true
    }
    
    func showReplyToButton(){
        replyingToButton.isHidden = false
    }
    
    func resetReplyToButton(){
        hideReplyToButton()
        replyingToButton.setTitle("", for: .normal)
        replyingToState = .addUsername
        replyingToObject = nil
        topAddCommentViewContainerConstraint.constant = 8
    }
    
    func willBeginAddingComment(){
        if !didBeginAddComment{
            didBeginAddComment = true
            newCommentTextView.text = ""
            if #available(iOS 13.0, *) {
                newCommentTextView.textColor = .label
            } else {
                // Fallback on earlier versions
                newCommentTextView.textColor = .black
            }
        }
        if UIDevice.current.userInterfaceIdiom == .pad{
            newCommentHeightConstraint.constant = TableViewConstants.newCommentHeightEditingiPad
        }else{
            newCommentHeightConstraint.constant = TableViewConstants.newCommentHeightEditing
        }
        if let replyingToObject = replyingToObject{
            showReplyToButton()
            replyingToButton.setTitle("Replying to: \(replyingToObject.username ?? "")", for: .normal)
            topAddCommentViewContainerConstraint.constant = 0
        }else{
            topAddCommentViewContainerConstraint.constant = 8
        }
    }
    
    func didEndAddingComment(){
        if UIDevice.current.userInterfaceIdiom == .pad{
            newCommentHeightConstraint.constant = TableViewConstants.newCommentHeightInitialiPad
        }else{
            newCommentHeightConstraint.constant = TableViewConstants.newCommentHeightInitial
        }
        newCommentTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func resetAddComment(){
        didBeginAddComment = false
        newCommentTextView.textColor = Constants.Colors.placeHolderColor
        newCommentTextView.text = CommentViewConstants.newCommentInitialText
        enableAddingNewComments()
        resetReplyToButton()
        resetAddingCommentButton()
    }
    
    func enableAddingNewComments(){
        newCommentTextView.isUserInteractionEnabled = true
    }
    
    func disableAddingNewComments(){
        newCommentTextView.isUserInteractionEnabled = false
        if newCommentTextView.isFirstResponder{
            newCommentTextView.resignFirstResponder()
        }
    }
    
    func prepareForAddingCommentTask(){
        DispatchQueue.main.async{ [weak self] in
            guard let self = self else { return }
            self.addCommentButton.isHidden = true
            self.addCommentActivityIndicator.isHidden = false
        }
    }
    
    func resetAddingCommentButton(){
        DispatchQueue.main.async{ [weak self] in
            guard let self = self else { return }
            self.addCommentButton.isHidden = false
            self.addCommentActivityIndicator.isHidden = true
        }
    }
        
    func prepareForAsyncTask(){
        addSubview(asyncBackgroundView)
        asyncBackgroundView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        asyncBackgroundView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        asyncBackgroundView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
        asyncBackgroundView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
        QuickSetupSpinner.start(from: asyncBackgroundView, style: .whiteLarge, backgroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0), baseColor: .white)
    }
    
    func setupAfterAsyncTask(){
        QuickSetupSpinner.stop()
        asyncBackgroundView.removeFromSuperview()
    }
    
    func hideAddingComments(){
        if newCommentViewContainer != nil{
            newCommentViewContainer.removeFromSuperview()
        }
    }
}
