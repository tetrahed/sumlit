//
//  FeedTableViewCell.swift
//  SumLit
//
//  Created by Robert Chung on 5/4/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

private let commentCharacterLimit = 200
private let upvoteBoxCornerRadius: CGFloat = 15
private let maximumLineCount = 4
private let maximumCharacterPerLine = 44

protocol FeedTableViewCellProtocol : class{
    func upvotePost(cell: FeedTableViewCell)
    func downvotePost(cell: FeedTableViewCell)
    func commentOnPost(cell: FeedTableViewCell)
    func linkToArticle(cell: FeedTableViewCell)
    func viewProfile(cell: FeedTableViewCell)
    func updatedDisplay(cell: FeedTableViewCell)
}

protocol EditFeedCommentProtocol: class {
    func updateHeightOfRow(cell: FeedTableViewCell)
    func didEndEditingComment(cell: FeedTableViewCell, didChange: Bool)
}

private struct FeedFontSizes{
    static let articleSize : CGFloat = DeviceDetection.isPhone ? 20 : 28
    static let summarySize: CGFloat = DeviceDetection.isPhone ? 18 : 23
    static let commentSize : CGFloat = DeviceDetection.isPhone ? 16 : 21
    static let usernameSize : CGFloat = DeviceDetection.isPhone ? 16 : 21
}

class FeedTableViewCell: UITableViewCell
{
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet fileprivate weak var articleTitleTextView: UITextView!
    @IBOutlet fileprivate weak var usernameButton: UIButton!
    @IBOutlet fileprivate weak var timeStampLabel: UILabel!
    @IBOutlet fileprivate weak var upvoteButton: UIButton!
    @IBOutlet fileprivate weak var upvoteCountLabel: UILabel!
    @IBOutlet fileprivate weak var downvoteButton: UIButton!
    @IBOutlet fileprivate weak var commentButton: UIButton!{
        didSet{
            commentButton.roundCorners(by: 5)
            commentButton.setTitle("-", for: .normal)
            commentButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            commentButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -15)
            commentButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 25)
        }
    }
    @IBOutlet fileprivate weak var upvoteBoxImageView: UIImageView!
    @IBOutlet fileprivate weak var upvoteBoxWidthConstraint: NSLayoutConstraint!{
        didSet{
            if UIDevice.current.userInterfaceIdiom == .pad{
                upvoteBoxWidthConstraint.constant = 90
                self.layoutIfNeeded()
            }
        }
    }
    
    @IBOutlet fileprivate weak var borderShadowView: UIView!
    @IBOutlet fileprivate weak var commentBackgroundView: UIView!{
        didSet{
            commentBackgroundView.roundCorners(by: 5)
        }
    }
    
    @IBOutlet fileprivate weak var linkButton: UIButton!{
        didSet{
            linkButton.roundCorners(by: 5)
        }
    }
    
    @IBOutlet weak var commentTextView: UITextView!{
        didSet{
            commentTextView.textContainer.lineFragmentPadding = 0
            commentTextView.addPadding(top: 0, bottom: 8, left: 0, right: 0)
            commentTextView.delegate = self
        }
    }
    @IBOutlet fileprivate weak var commentCharacterCountLabel: UILabel!
    @IBOutlet fileprivate var gradientRelatedViews: [UIView]!
    @IBOutlet weak var showMoreButton: UIButton!
    
    //MARK:- BUTTON ACTIONS
    @IBAction func handleShowMore(_ sender: UIButton) {
        guard displayState != .alwaysFully, displayState != .fully else { return }
        changeDisplay(fully: (displayState == .shorten) ? true : false )
    }
    
    //MARK:- DECLARED VARIABLES
    private(set) var post : PostDataModel?
    
    fileprivate var upvoteSpinner : Spinner?
    fileprivate let upvoteBoxView : UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.8
        view.image = #imageLiteral(resourceName: "upvoteBox")
        view.isUserInteractionEnabled = false
        return view
    }()
    
    fileprivate var isUpvoted: Bool = false {
        didSet{
            if isUpvoted{
                upvoteButton.setImage(#imageLiteral(resourceName: "upvote"), for: .normal)
                downvoteButton.setImage(#imageLiteral(resourceName: "downvoteDefault"), for: .normal)
            }else{
                upvoteButton.setImage(#imageLiteral(resourceName: "upvoteDefault"), for: .normal)
            }
        }
    }
    
    fileprivate var isDownvoted: Bool = false{
        didSet{
            if isDownvoted{
                downvoteButton.setImage(#imageLiteral(resourceName: "downvote"), for: .normal)
                upvoteButton.setImage(#imageLiteral(resourceName: "upvoteDefault"), for: .normal)
            }else{
                downvoteButton.setImage(#imageLiteral(resourceName: "downvoteDefault"), for: .normal)
            }
        }
    }
    
    fileprivate var upvoteCount: Int = 0{
        didSet{
            if upvoteCount < 0{
                var formattedNumberString = (upvoteCount * -1).formatUsingAbbrevation()
                formattedNumberString.insert("-", at: formattedNumberString.startIndex)
                upvoteCountLabel.text = "\(formattedNumberString)"
            }else{
                upvoteCountLabel.text = "\(upvoteCount.formatUsingAbbrevation())"
            }
        }
    }
    
    fileprivate var commentCharacterCount: Int = 0 {
        didSet{
            commentCharacterCountLabel.text = "\(commentCharacterCount)/200 characters"
        }
    }
        
    enum Display {
        case fully
        case shorten
        case alwaysFully
    }
    
    private var displayState : Display = .alwaysFully {
        didSet{
            switch displayState{
            case .fully, .alwaysFully:
                guard UIDevice.current.userInterfaceIdiom == .phone else { return }
                gradientRelatedViews.forEach({$0.isHidden = true})
            default:
                break
            }
        }
    }
    private var shortenDisplayMaximum: Int {
        return maximumCharacterPerLine * maximumLineCount
    }
    weak var actionDelegate: FeedTableViewCellProtocol?
    weak var editFeedCommentDelegate: EditFeedCommentProtocol?
    
    private var editCommentHelper = EditCommentHelper()
    
    //MARK:- LIFECYCLE
    override func awakeFromNib()
    {
        super.awakeFromNib()
        setupInteractions()
//        setFeedFont()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageViewFrame = upvoteBoxImageView.frame
        let imageFrame = UIBezierPath(rect: CGRect(x: imageViewFrame.minX-10, y: imageViewFrame.minY-10, width: imageViewFrame.width, height: 35))
        summaryTextView.textContainer.exclusionPaths = [imageFrame]
        
//        setFeedFont()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        commentTextView.text = ""
        upvoteCountLabel.text = "-"
        gradientRelatedViews.forEach({$0.isHidden = false})
        if let spinner = self.upvoteSpinner{
            spinner.stop()
            spinner.start(from: upvoteBoxView, style: .whiteLarge, backgroundColor: .clear, baseColor: .white)
        }
//        setFeedFont()
    }
    
    private func setFeedFont(){
        articleTitleTextView.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont(name: SLFonts.boldFontName, size: FeedFontSizes.articleSize)!)
        articleTitleTextView.adjustsFontForContentSizeCategory = true
        
        summaryTextView.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: UIFont(name: SLFonts.regularFontName, size: FeedFontSizes.summarySize)!)
        summaryTextView.adjustsFontForContentSizeCategory = true
    }
}

//MARK:- UITextViewDelegate
extension FeedTableViewCell: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        commentCharacterCount = textView.text.count
        editFeedCommentDelegate?.updateHeightOfRow(cell: self)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        didFinishEditingComment()
        let didChange = editCommentHelper.previousComment != commentTextView.text
        if !didChange && commentTextView.text.isEmpty { commentTextView.isHidden = true}
        editFeedCommentDelegate?.didEndEditingComment(cell: self, didChange: didChange)
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if !editCommentHelper.handleShouldChangeTextIn(textView: textView, newText: text) {
            return false
        }
        guard let preText = textView.text as NSString?,
            preText.replacingCharacters(in: range, with: text).count <= commentCharacterLimit else {
                return false
        }
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if commentTextView.isHidden{
            commentTextView.isHidden = false
        }
        commentCharacterCountLabel.isHidden = false
        commentCharacterCount = textView.text.count
        editFeedCommentDelegate?.updateHeightOfRow(cell: self)
        return editCommentHelper.handleTextViewShouldBeginEditing(textView: textView)
    }
}

//MARK:- PRIVATE APIs
fileprivate extension FeedTableViewCell
{
    func setupInteractions(){
        upvoteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressedUpvoteButton)))
        downvoteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressedDownvoteButton)))
        commentButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressedCommentButton)))
        usernameButton.addTarget(self, action: #selector(pressedUsernameButton), for: .touchUpInside)
        linkButton.addTarget(self, action: #selector(pressedLinkButton), for: .touchUpInside)
        summaryTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeDisplay)))
    }
    
    @objc func pressedUpvoteButton(){
        disableVoteButton()
        actionDelegate?.upvotePost(cell: self)
    }
    
    @objc func pressedDownvoteButton(){
        disableVoteButton()
        actionDelegate?.downvotePost(cell: self)
    }
    
    @objc func pressedCommentButton(){
        actionDelegate?.commentOnPost(cell: self)
    }
    
    @objc func pressedLinkButton(){
        actionDelegate?.linkToArticle(cell: self)
    }
    
    @objc func pressedUsernameButton(){
        actionDelegate?.viewProfile(cell: self)
    }
    
    func disableVoteButton(){
        upvoteButton.isUserInteractionEnabled = false
        downvoteButton.isUserInteractionEnabled = false
    }
    
    func enableVoteButton(){
        upvoteButton.isUserInteractionEnabled = true
        downvoteButton.isUserInteractionEnabled = true
    }
    
    func setupSummary(_ text: String) -> String{
        let split = text.splitSentence()
        var newText = ""
        for sentence in split{
            newText += "\u{2022} \(sentence)\n\n"
        }
        return newText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @objc func handleChangeDisplay(){
        guard displayState != .alwaysFully else { return }//, displayState != .fully else { return }
        changeDisplay(fully: (displayState == .shorten) ? true : false )
//        if displayState == .shorten{
//            summaryTextView.textContainer.maximumNumberOfLines = 0
//            displayState = .fully
//        }else{
//            displayState = .shorten
//            summaryTextView.textContainer.maximumNumberOfLines = maximumLineCount
//        }
    }
    
    func changeDisplay(fully: Bool){
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        actionDelegate?.updatedDisplay(cell: self)
    }
    
    func displayCommentIfNeeded(_ comment: String){
        if comment.isEmpty{
            commentTextView.isHidden = true
        }else{
            commentTextView.isHidden = false
            commentTextView.text = comment
        }
    }
    
    func updateTextConstraints(){
        if DeviceDetection.isPhone{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) { [weak self] in
                self?.commentTextView.setNeedsUpdateConstraints()
                self?.summaryTextView.setNeedsUpdateConstraints()
                self?.commentTextView.setNeedsUpdateConstraints()
                self?.commentBackgroundView.setNeedsUpdateConstraints()
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) { [weak self] in
                self?.commentTextView.setNeedsUpdateConstraints()
                self?.summaryTextView.setNeedsUpdateConstraints()
                self?.commentTextView.setNeedsUpdateConstraints()
//                self?.setNeedsLayout()
//                self?.layoutIfNeeded()
//                self?.commentTextView.setNeedsUpdateConstraints()
//                self?.summaryTextView.setNeedsUpdateConstraints()
////                self?.commentTextView.setNeedsUpdateConstraints()
//                self?.commentBackgroundView.setNeedsUpdateConstraints()
//                self?.summaryTextView.setNeedsUpdateConstraints()
//                self?.commentBackgroundView.setNeedsUpdateConstraints()
//                self?.setNeedsUpdateConstraints()
//                self?.updateConstraints()
            }
        }
    }
    
    func shouldChangeDisplay(for summary: String) -> Bool{
        let alwaysFullyDisplay = summary.count <= shortenDisplayMaximum
        if alwaysFullyDisplay{ displayState = .alwaysFully }
        return !alwaysFullyDisplay
    }
}

//MARK:- PUBLIC API
extension FeedTableViewCell {
    
    func setupCell(post: PostDataModel, shouldFullyDisplay: Bool, willBeginEditingComment: Bool = false){
        self.post = post
        articleTitleTextView.text = post.title
        if shouldChangeDisplay(for: post.summary ?? ""){ setInitialDisplay(fully: shouldFullyDisplay) }
        summaryTextView.text = setupSummary(post.summary ?? "")
        usernameButton.setTitle(post.username, for: .normal)
        timeStampLabel.text = post.createdAt?.shortenCalenderTimeSinceNow()
        displayCommentIfNeeded(post.comment ?? "")
        updateTextConstraints()
        linkButton.setTitle(post.link, for: .normal)
        setCommentCount(to: post.commentCount)
        if willBeginEditingComment{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.willEditComment()
            }
        }
    }
    
    func setupAnonymous(){
        upvoteButton.isEnabled = false
        downvoteButton.isEnabled = false
    }
    
    func setInitialDisplay(fully: Bool){
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            summaryTextView.isScrollEnabled = false
            return
        }
        if fully{
            summaryTextView.textContainer.maximumNumberOfLines = 0
            displayState = .fully
        }else{
            summaryTextView.textContainer.maximumNumberOfLines = maximumLineCount
            summaryTextView.textContainer.lineBreakMode = .byTruncatingTail
            displayState = .shorten
        }
    }
    
    func setCommentCount(to count: Int){
        commentButton.setTitle(count.formatUsingAbbrevation(), for: .normal)
    }
    
    func updateVoteUI(vote: PostVoteService.VoteState, upvotes: Int){
        upvoteCount = upvotes
        switch vote {
        case .upvoted:
            isUpvoted = true
        case .downvoted:
            isDownvoted = true
        case .none:
            isUpvoted = false
            isDownvoted = false
        }
        enableVoteButton()
        upvoteBoxView.removeFromSuperview()
        upvoteSpinner?.stop()
        upvoteSpinner = nil
    }
    
    func startUpvoteSpinnerIfNeeded(){
        if upvoteSpinner == nil{
            upvoteSpinner = Spinner()
            addSubview(upvoteBoxView)
            upvoteBoxView.topAnchor.constraint(equalTo: upvoteBoxImageView.topAnchor).isActive = true
            upvoteBoxView.leadingAnchor.constraint(equalTo: upvoteBoxImageView.leadingAnchor).isActive = true
            upvoteBoxView.bottomAnchor.constraint(equalTo: upvoteBoxImageView.bottomAnchor).isActive = true
            upvoteBoxView.widthAnchor.constraint(equalToConstant: upvoteBoxImageView.frame.width+1).isActive = true
            upvoteSpinner?.start(from: upvoteBoxView, style: .whiteLarge, backgroundColor: .clear, baseColor: .gray)
        }
    }
    
    func willEditComment(){
        editCommentHelper.willEditComment(textView: commentTextView, repliedToUsername: "")
        summaryTextView.isUserInteractionEnabled = false
        if showMoreButton != nil, displayState != .alwaysFully{
            showMoreButton.isUserInteractionEnabled = false
        }
    }
    
    func didFinishEditingComment(){
        commentCharacterCountLabel.isHidden = true
        editCommentHelper.didFinishEditingComment(textView: commentTextView)
        summaryTextView.isUserInteractionEnabled = true
        if showMoreButton != nil, displayState != .alwaysFully{
            showMoreButton.isUserInteractionEnabled = true
        }
    }
    
    func getComment() -> String{
        return editCommentHelper.getComment(textView: commentTextView)
    }
    
    func resetCommentTextView(){
        editCommentHelper.resetCommentTextView(textView: commentTextView)
    }
}
