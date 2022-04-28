//
//  CommentsTableViewCell.swift
//  SumLit
//
//  Created by Junior Etrata on 5/24/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

private struct CommentTextViewFontConstants {
    static let iphone: UIFont = UIFont(name: "Lato-Regular", size: 17)!
    static let ipad: UIFont = UIFont(name: "Lato-Regular", size: 24)!
}

private struct CommentSectionConstraintsConstants{
    static let iphoneLeadingParentConstraint: CGFloat = 16
    static let iphoneLeadingReplyConstraint: CGFloat = 40
    static let ipadLeadingParentConstraint: CGFloat = 32
    static let ipadLeadingReplyConstraint: CGFloat = 56
}

protocol CommentsTableViewCellProtocol: class{
    func viewCommentCreatorProfile(cell: CommentsTableViewCell)
    func viewRepliedToProfile(cell: CommentsTableViewCell)
    func upvoteComment(cell: CommentsTableViewCell)
    func updateHeightOfRow(cell: CommentsTableViewCell)
    func didEndEditingComment(cell: CommentsTableViewCell, didChange: Bool)
    func collapse(cell: CommentsTableViewCell, _ shouldCollapse: Bool)
    func replyToPoster(cell: CommentsTableViewCell)
}

private enum CommentSectionState{
    case collapsed
    case fully
}

private struct CommentFontSize {
    static let commentSize : CGFloat = DeviceDetection.isPhone ? 17 : 24
}

class CommentsTableViewCell: UITableViewCell {
    
    // MARK:- Outlets
    
    // StackViews
    @IBOutlet private weak var collapsableStackView: UIStackView!
    @IBOutlet private weak var bottomButtonsStackView: UIStackView!
    
    // Buttons
    @IBOutlet private weak var upvoteButton: UIButton!{
        didSet{
            upvoteButton.roundCorners(by: 5)
            upvoteButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
            upvoteButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
            if #available(iOS 13.0, *){
                upvoteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                upvoteButton.setImage(UIImage(named: "NotUpvoteDCommentButton")!, for: .normal)
                if DeviceDetection.isPhone{
                    upvoteButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
                }
            }
        }
    }
    @IBOutlet private weak var usernameButton: UIButton!
    @IBOutlet private weak var replyButton: UIButton!
    
    // Labels
    @IBOutlet private weak var commentCreatedLabel: UILabel!
    
    // TextViews
    @IBOutlet weak var commentTextView: UITextView!{
        didSet{
            commentTextView.addPadding(top: 0, bottom: 0, left: 0, right: 0)
            commentTextView.textContainer.lineFragmentPadding = 0
            commentTextView.delegate = self
            commentTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapComment(gesture:))))
        }
    }
    
    // View
    @IBOutlet private weak var indentIndicatorView: UIView!
    
    // Constraints
    @IBOutlet private weak var leadingCommentStackViewConstraint: NSLayoutConstraint!
    
    
    // Computed properties
    private var upvotes: Int = 0 {
        didSet{
            upvoteButton.setTitle("\(upvotes.formatUsingAbbrevation())", for: .normal)
        }
    }
    
    private var isUpvoted: Bool = false{
        didSet{
            if isUpvoted{
                upvoteButton.backgroundColor = UIColor.init(named: "SLUpvoteComment")!
                upvoteButton.layer.borderWidth = 0
                upvoteButton.tintColor = UIColor.white
                upvoteButton.setTitleColor(.white, for: .normal)
                if #available(iOS 13.0, *) {} else{
                    upvoteButton.setImage(UIImage(named: "UpvotedCommentButton"), for: .normal)
                }
            }else{
                if #available(iOS 13.0, *) {
                    upvoteButton.backgroundColor = UIColor.systemBackground
                } else {
                    upvoteButton.setImage(UIImage(named: "NotUpvoteDCommentButton")!, for: .normal)
                    upvoteButton.backgroundColor = UIColor.white
                }
                upvoteButton.layer.borderColor = UIColor.darkGray.cgColor
                upvoteButton.layer.borderWidth = 0.5
                upvoteButton.tintColor = UIColor.lightGray
                upvoteButton.setTitleColor(.lightGray, for: .normal)
            }
        }
    }
    
    private var editCommentHelper = EditCommentHelper()
    weak var commentsTableViewCellDelegate: CommentsTableViewCellProtocol?
    private var commentSectionState : CommentSectionState = .fully
    private var repliedToUsername : String?
    private var shouldBeIndented = false
    
    // MARK:- View lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchedBackground)))
        setCommentFont()
    }
    
    // Used to collapse/un-collapse a cell
    @objc private func touchedBackground(){
        switch commentSectionState {
        case .collapsed:
            commentsTableViewCellDelegate?.collapse(cell: self, false)
        case .fully:
            commentsTableViewCellDelegate?.collapse(cell: self, true)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        shouldBeIndented = false
        collapsableStackView.isHidden = false
        indentIndicatorView.isHidden = true
        if UIDevice.current.userInterfaceIdiom == .phone{
            leadingCommentStackViewConstraint.constant = CommentSectionConstraintsConstants.iphoneLeadingParentConstraint
        }else{
            leadingCommentStackViewConstraint.constant = CommentSectionConstraintsConstants.ipadLeadingParentConstraint
        }
        repliedToUsername = nil
//        setCommentFont()
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        if shouldBeIndented{
            if UIDevice.current.userInterfaceIdiom == .phone{
                leadingCommentStackViewConstraint.constant = CommentSectionConstraintsConstants.iphoneLeadingReplyConstraint
            }else{
                leadingCommentStackViewConstraint.constant = CommentSectionConstraintsConstants.ipadLeadingReplyConstraint
            }
        }
//        setCommentFont()
    }
    
    private func setCommentFont(){
        commentTextView.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont(name: SLFonts.regularFontName, size: CommentFontSize.commentSize)!)
        commentTextView.adjustsFontForContentSizeCategory = true
    }
}

// MARK:- UITextViewDelegate

extension CommentsTableViewCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        commentsTableViewCellDelegate?.updateHeightOfRow(cell: self)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        didFinishEditingComment()
        if editCommentHelper.previousComment != commentTextView.text{
            commentsTableViewCellDelegate?.didEndEditingComment(cell: self, didChange: true)
        }else{
            commentsTableViewCellDelegate?.didEndEditingComment(cell: self, didChange: false)
            var repliedToUsernameText : String = ""
            if let repliedToUsername = self.repliedToUsername{
                repliedToUsernameText = "\(repliedToUsername)"
            }else{
                return true
            }
            if UIDevice.current.userInterfaceIdiom == .phone{
                let attrString = NSMutableAttributedString(string: repliedToUsernameText, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.iphone, NSAttributedString.Key.foregroundColor: UIColor.systemOrange])
                if #available(iOS 13.0, *){
                    attrString.addText(commentTextView.attributedText.string, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.iphone, NSAttributedString.Key.foregroundColor: UIColor.label])
                }else{
                    attrString.addText(commentTextView.attributedText.string, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.iphone, NSAttributedString.Key.foregroundColor: UIColor.black])
                }
                commentTextView.attributedText = attrString
            }else{
                let attrString = NSMutableAttributedString(string: repliedToUsernameText, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.ipad, NSAttributedString.Key.foregroundColor: Constants.Colors.orangeColor])
                if #available(iOS 13.0, *) {
                    attrString.addText(commentTextView.attributedText.string, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.ipad, NSAttributedString.Key.foregroundColor: UIColor.label])
                } else {
                    // Fallback on earlier versions
                    attrString.addText(commentTextView.attributedText.string, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.ipad, NSAttributedString.Key.foregroundColor: UIColor.black])
                }
                commentTextView.attributedText = attrString
            }
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return editCommentHelper.handleShouldChangeTextIn(textView: textView, newText: text)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return editCommentHelper.handleTextViewShouldBeginEditing(textView: textView)
    }
}

// MARK:- Private action methods

private extension CommentsTableViewCell{
    
    @IBAction func replyToPoster(_ sender: UIButton) {
        commentsTableViewCellDelegate?.replyToPoster(cell: self)
    }
    
    @IBAction func upvotePost(_ sender: UIButton) {
        commentsTableViewCellDelegate?.upvoteComment(cell: self)
    }
    
    @IBAction func viewProfile(){
        commentsTableViewCellDelegate?.viewCommentCreatorProfile(cell: self)
    }
    
    @objc func tapComment(gesture: UITapGestureRecognizer){
        let text = (commentTextView.text)!
        let repliedToUsernameRange = (text as NSString).range(of: repliedToUsername ?? "")
        
        if gesture.didTapAttributedTextInLabel(label: commentTextView, inRange: repliedToUsernameRange) {
            commentsTableViewCellDelegate?.viewRepliedToProfile(cell: self)
        } else {
            commentsTableViewCellDelegate?.collapse(cell: self, true)
        }
    }
}

// MARK:- Private View methods

private extension CommentsTableViewCell{
    
    func configureCell(willBeginEditingComment: Bool, shouldBeCollapsed: Bool){
        if willBeginEditingComment{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.willEditComment()
            }
        }
        
        if shouldBeCollapsed && !willBeginEditingComment{
            collapsableStackView.isHidden = true
            commentSectionState = .collapsed
        }
    }
    
}

// MARK:- PUBLIC API

extension CommentsTableViewCell{
    
    func setupCell(comment: CommentDataModel, willBeginEditingComment: Bool, shouldBeCollapsed: Bool){
        if UIDevice.current.userInterfaceIdiom == .phone{
            if #available(iOS 13.0, *) {
                commentTextView.attributedText = NSAttributedString(string: comment.comment, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.iphone, NSAttributedString.Key.foregroundColor: UIColor.label])
            } else {
                commentTextView.attributedText = NSAttributedString(string: comment.comment, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.iphone, NSAttributedString.Key.foregroundColor: UIColor.black])
                // Fallback on earlier versions
            }
        }else{
            if #available(iOS 13.0, *) {
                commentTextView.attributedText = NSAttributedString(string: comment.comment, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.ipad, NSAttributedString.Key.foregroundColor: UIColor.label])
            } else {
                // Fallback on earlier versions
                commentTextView.attributedText = NSAttributedString(string: comment.comment, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.ipad, NSAttributedString.Key.foregroundColor: UIColor.black])
            }
        }
        usernameButton.setTitle(comment.username, for: .normal)
        updateUpvoteUI(comment: comment)
        commentCreatedLabel.text = comment.createdAt.shortenCalenderTimeSinceNow()
        configureCell(willBeginEditingComment: willBeginEditingComment, shouldBeCollapsed: shouldBeCollapsed)
    }
    
    func setupCell(comment: ReplyCommentDataModel, willBeginEditingComment: Bool, shouldBeCollapsed: Bool){
        var repliedToUsernameText : String = ""
        if let repliedToUsername = comment.repliedToUsername {
            repliedToUsernameText = "@\(repliedToUsername) "
        }
        if UIDevice.current.userInterfaceIdiom == .phone{
            let attrString = NSMutableAttributedString(string: repliedToUsernameText, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.iphone, NSAttributedString.Key.foregroundColor: UIColor.systemOrange])
            if #available(iOS 13.0, *) {
                attrString.addText(comment.comment, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.iphone, NSAttributedString.Key.foregroundColor: UIColor.label])
            } else {
                // Fallback on earlier versions
                attrString.addText(comment.comment, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.iphone, NSAttributedString.Key.foregroundColor: UIColor.black])
            }
            commentTextView.attributedText = attrString
         }else{
            let attrString = NSMutableAttributedString(string: repliedToUsernameText, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.ipad, NSAttributedString.Key.foregroundColor: UIColor.systemOrange])
            if #available(iOS 13.0, *) {
                attrString.addText(comment.comment, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.ipad, NSAttributedString.Key.foregroundColor: UIColor.label])
            } else {
                // Fallback on earlier versions
                attrString.addText(comment.comment, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.ipad, NSAttributedString.Key.foregroundColor: UIColor.black])
            }
            commentTextView.attributedText = attrString
        }
        usernameButton.setTitle(comment.username, for: .normal)
        updateUpvoteUI(comment: comment)
        commentCreatedLabel.text = comment.createdAt.shortenCalenderTimeSinceNow()
        configureCell(willBeginEditingComment: willBeginEditingComment, shouldBeCollapsed: shouldBeCollapsed)
        if UIDevice.current.userInterfaceIdiom == .phone{
            leadingCommentStackViewConstraint.constant = CommentSectionConstraintsConstants.iphoneLeadingReplyConstraint
        }else{
            leadingCommentStackViewConstraint.constant = CommentSectionConstraintsConstants.ipadLeadingReplyConstraint
        }
        shouldBeIndented = true
        indentIndicatorView.isHidden = false
        repliedToUsername = repliedToUsernameText
        
    }
    
    func setupAnonymous(){
        replyButton.alpha = 0
        replyButton.isEnabled = false
        upvoteButton.isUserInteractionEnabled = false
//        replyButton.isHidden = true
//        bottomButtonsStackView.isHidden = true
    }
    
    //use to change the like button, likes count text color, and likes count
    func updateUpvoteUI(comment: CommentDataModel){
        self.upvotes = comment.upvotes
        self.isUpvoted = comment.isUpvoted
    }
    
    func updateUpvoteUI(comment: ReplyCommentDataModel){
           self.upvotes = comment.upvotes
           self.isUpvoted = comment.isUpvoted
       }
    
    func disableUpvoteButton(){
        upvoteButton.isEnabled = false
    }
    
    func enableUpvoteButton(){
        upvoteButton.isEnabled = true
    }
    
    //Editing comments ----------------------------------------------------
    
    func willEditComment(){
        editCommentHelper.willEditComment(textView: commentTextView, repliedToUsername: repliedToUsername ?? "")
    }
    
    func didFinishEditingComment(){
        editCommentHelper.didFinishEditingComment(textView: commentTextView)
    }
    
    func getComment() -> String{
        return editCommentHelper.getComment(textView: commentTextView)
    }
    
    func resetCommentTextView(){
        editCommentHelper.resetCommentTextView(textView: commentTextView)
        var repliedToUsernameText : String = ""
        if let repliedToUsername = self.repliedToUsername{
            repliedToUsernameText = "\(repliedToUsername)"
        }else{
            return
        }
        if UIDevice.current.userInterfaceIdiom == .phone{
            let attrString = NSMutableAttributedString(string: repliedToUsernameText, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.iphone, NSAttributedString.Key.foregroundColor: UIColor.systemOrange])
            attrString.addText(commentTextView.attributedText.string, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.iphone])
            commentTextView.attributedText = attrString
        }else{
            let attrString = NSMutableAttributedString(string: repliedToUsernameText, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.ipad, NSAttributedString.Key.foregroundColor: UIColor.systemOrange])
            attrString.addText(commentTextView.attributedText.string, attributes: [NSAttributedString.Key.font: CommentTextViewFontConstants.ipad])
            commentTextView.attributedText = attrString
        }
    }
    
    //----------------------------------------------------------------------
}
