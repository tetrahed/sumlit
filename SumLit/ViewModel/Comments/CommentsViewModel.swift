//
//  CommentsViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/10/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

class CommentsViewModel {
    
    typealias endReached = Bool
    
    enum State {
        case normal
        case editing
        case addingComment
    }
    
    enum AddingCommentState {
        case parent
        case reply
    }
    
    private let commentService: CommentService
    private let commentUpvotesService: CommentUpvoteService
    private let addCommentService: AddCommentService
    private let blockService: BlockService
    private let commentDeletionService: CommentDeletionService
    private let postuuid : String
    private(set) var currentState : State = .normal
    var addingCommentState : AddingCommentState = .parent
    
    var filterType: FilterTypes = .oldest {
        didSet{
            switch filterType{
            case .oldest:
                filterMenuTitle = "Current Order: Oldest"
            case .newest:
                filterMenuTitle = "Current Order: Newest"
            case .upvotes:
                filterMenuTitle = "Current Order: Most Likes"
            }
        }
    }
    
    private(set) var filterMenuTitle : String = "Current Order: Oldest"
    private var comments = [CommentDataModel]()
    private(set) var commentData = [AnyObject]()
    private var block : BlockDataModel?
    private(set) var indexPathToEdit : IndexPath!
    var loadingReplies = [IndexPath]()
    
    // MARK:- Initializers
    
    init(commentService: CommentService = CommentService(), commentUpvoteService: CommentUpvoteService = CommentUpvoteService(), addCommentService: AddCommentService = AddCommentService(), blockService: BlockService = BlockService(), commentDeletionService: CommentDeletionService = CommentDeletionService(), postuuid: String) {
        self.commentService = commentService
        self.commentUpvotesService = commentUpvoteService
        self.addCommentService = addCommentService
        self.blockService = blockService
        self.commentDeletionService = commentDeletionService
        self.postuuid = postuuid
    }
}

// MARK:- Public APIs

extension CommentsViewModel{
    
    func fetchParentComments(isRefreshed: Bool, completion: @escaping ( (Error?, endReached) -> Void )){
        let lastComment = (isRefreshed) ? nil : comments.last
        let mostRecentLikes = (!isRefreshed && filterType == .upvotes) ? getMostRecentUpvotedComments() : nil
        if block == nil{
            // Get block information from database
            if let useruuid = UserService.shared.uid {
                blockService.getBlockInfo(useruuid: useruuid) { [weak self] (blockDataModel) in
                    guard let self = self else { return }
                    self.block = blockDataModel
                    self.performFetchingComments(isRefreshed: isRefreshed, lastComment: lastComment, mostRecentLikes: mostRecentLikes, insertAtZero: false, completion: completion)
                }
            }else{
                // User is anonymous. No filtering needed
                block = BlockDataModel(isBlocked: [], blocking: [], reportedPosts: [])
                performFetchingComments(isRefreshed: isRefreshed, lastComment: lastComment, mostRecentLikes: mostRecentLikes, insertAtZero: false, completion: completion)
            }
        }else{
            // Already have block information. Just fetch comments.
            performFetchingComments(isRefreshed: isRefreshed, lastComment: lastComment, mostRecentLikes: mostRecentLikes, insertAtZero: false, completion: completion)
        }
    }
    
    func fetchReplyComments(at indexPath: IndexPath, parentCommentuuid: String, completion: @escaping (() -> Void)){
        commentService.fetchReplyComments(postuuid: postuuid, parentCommentuuid: parentCommentuuid) { [weak self] (result) in
            guard let self = self else { return }
            if let index = self.loadingReplies.firstIndex(of: indexPath){
                self.loadingReplies.remove(at: index)
            }
            self.commentData.remove(at: indexPath.row)
            switch result{
            case .success(let dataModels):
                if let index = self.commentData.firstIndex(where: { (object) -> Bool in
                    if let commentObject = object as? CommentDataModel, commentObject.commentuuid == parentCommentuuid{
                        return true
                    }else{
                        return false
                    }
                }){
                    let filteredReplies = self.filterComments(dataModels as [AnyObject], insertAtZero: false)
                    self.commentData.insert(contentsOf: filteredReplies, at: index.advanced(by: 1))
                }
            case .failure(_):
                break
            }
            completion()
        }
    }
    
    func upvoteParentComment(useruuid: String, comment: CommentDataModel, completion: @escaping CommentUpvoteService.CommentUpvoteHandler) {
        commentUpvotesService.upvoteParentComment(postuuid: postuuid, useruuid: useruuid, comment: comment) { [weak self] (result) in
            guard let self = self else { return completion(.failure(CustomErrors.GeneralErrors.unknownError)) }
            switch result{
            case .success(let newComment):
                for (index, data) in self.commentData.enumerated(){
                    if let commentDataModel = data as? CommentDataModel, commentDataModel == comment{
                        self.commentData[index] = newComment as AnyObject
                    }
                }
                
                if let index = self.comments.firstIndex(of: comment){
                    self.comments[index] = newComment
                }
                completion(.success(newComment))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func upvoteReplyComment(useruuid: String, reply: ReplyCommentDataModel, completion: @escaping ((Result<ReplyCommentDataModel,Error>) -> Void)) {
        commentUpvotesService.upvoteReplyComment(reply: reply, postuuid: postuuid, useruuid: useruuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let newReply):
                for (index, data) in self.commentData.enumerated(){
                    if let replyDataModel = data as? ReplyCommentDataModel, replyDataModel == reply{
                        self.commentData[index] = newReply as AnyObject
                    }
                }
                
                completion(.success(newReply))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func validate(newComment: String) -> Error?{
        if newComment.isEmpty{
            return CustomErrors.AddNewCommentError.emptyComment
        }
        
        if let word = newComment.hasForbiddenWord(){
            return CustomErrors.GeneralErrors.forbiddenWords(word: word)
        }
        return nil
    }
    
    func addNewParentComment(useruuid: String, posteruuid: String, comment: String, completion: @escaping ((Error?) -> Void)){
        addCommentService.addParentComment(useruuid: useruuid, postuuid: postuuid, comment: comment) { [weak self] (result) in
            switch result{
            case .success(_):
                self?.updateBlockInfo(useruuid: useruuid, completion: { })
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func addNewReplyComment(parentCommentuuid: String, replyToUseruuid: String, needToGrabReplyingToUsername: Bool, useruuid: String, posteruuid: String, username: String, comment: String, completion: @escaping ((Error?) -> Void)){
        addCommentService.addReplyComment(parentCommentuuid: parentCommentuuid, replyingToUseruuid: replyToUseruuid, needToGrabReplyingToUsername: needToGrabReplyingToUsername, useruuid: useruuid, postuuid: postuuid, username: username, comment: comment) { [weak self] (result) in
            guard let self = self else { return }
            switch result{
            case .success(let newReply):
                if let index = self.commentData.firstIndex(where: { (object) -> Bool in
                    if let comment = object as? CommentDataModel, comment.commentuuid == parentCommentuuid{
                        return true
                    }else{
                        return false
                    }
                }){
                    if var comment = self.commentData[index] as? CommentDataModel{
                        if !comment.hasReplies{
                            comment.hasReplies = true
                            self.commentData[index] = comment as AnyObject
                            self.commentData.insert(newReply as AnyObject, at: index.advanced(by: 1))
                        }else{
                            var nextIndex = index.advanced(by: 1)
                            if nextIndex == self.commentData.endIndex {
                                self.commentData.insert(newReply as AnyObject, at: nextIndex)
                            }
                            if !(self.commentData[nextIndex] is LoadRepliesDataModel){
                                while self.commentData[nextIndex] is ReplyCommentDataModel {
                                    nextIndex = nextIndex.advanced(by: 1)
                                    if nextIndex == self.commentData.endIndex {
                                        break
                                    }
                                }
                                self.commentData.insert(newReply as AnyObject, at: nextIndex)
                            }
                        }
                    }
                }
                self.updateBlockInfo(useruuid: useruuid, completion: { })
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func updateBlockInfo(useruuid: String, completion: @escaping (() -> Void)){
        blockService.getBlockInfo(useruuid: useruuid) { [weak self] (blockDataModel) in
            guard let self = self else { return }
            self.block = blockDataModel
            self.commentData = self.filterComments(self.commentData, insertAtZero: false)
            completion()
        }
    }
    
    func deleteParentComment(commentDataModel: CommentDataModel, completion: @escaping ((Error?) -> Void)){
        commentDeletionService.deleteParentComment(postuuid: postuuid, commentuuid: commentDataModel.commentuuid) { [weak self] (error) in
            guard let self = self else { return }
            if let error = error{
                completion(error)
            }else{
                var newCommentDataModel = commentDataModel
                newCommentDataModel.wasDeleted = true
                
                if let index = self.comments.firstIndex(of: commentDataModel){
                    self.comments[index] = newCommentDataModel
                }
                
                if let index = self.commentData.firstIndex(where: { (object) -> Bool in
                    if let comment = object as? CommentDataModel, comment == commentDataModel{
                        return true
                    }else{
                        return false
                    }
                }){
                    self.commentData[index] = newCommentDataModel as AnyObject
                }
                completion(nil)
            }
        }
    }
    
    func deleteReplyComment(replyDataModel: ReplyCommentDataModel, completion: @escaping ((Error?) -> Void)){
        commentDeletionService.deleteReplyComment(postuuid: postuuid, parentCommentuuid: replyDataModel.parentCommentuuid, commentuuid: replyDataModel.commentuuid) { (error) in
            if let error = error {
                completion(error)
            }else{
                var newReplyDataModel = replyDataModel
                newReplyDataModel.wasDeleted = true
                
                if let index = self.commentData.firstIndex(where: { (object) -> Bool in
                    if let reply = object as? ReplyCommentDataModel, reply == replyDataModel{
                        return true
                    }else{
                        return false
                    }
                }){
                    self.commentData[index] = newReplyDataModel as AnyObject
                }
                completion(nil)
            }
        }
    }
    
    // Editing comment ---------------------------------------------------
    
    func setStateToNormal(){
        currentState = .normal
        indexPathToEdit = nil
    }
    
    func setStateToEditing(){
        currentState = .editing
    }
    
    func setStateToAddNewComment(){
        currentState = .addingComment
    }
    
    func setCurrentIndexPathToEdit(_ indexPath: IndexPath){
        indexPathToEdit = indexPath
    }
    
    func updateParentComment(commentDataModel: CommentDataModel, newComment: String, completion: @escaping CommentService.ChangeCommentHandler){
        commentService.updateParentComment(postuuid: postuuid, commentuuid: commentDataModel.commentuuid, newComment: newComment) { [weak self] (error) in
            guard let self = self else { return completion(CustomErrors.GeneralErrors.unknownError) }
            if error != nil{
                completion(error)
            }else{
                if let index = self.comments.firstIndex(of: commentDataModel){
                    self.comments[index].comment = newComment
                }
                for (index, data) in self.commentData.enumerated(){
                    if var comment = data as? CommentDataModel, comment == commentDataModel{
                        comment.comment = newComment
                        self.commentData[index] = comment as AnyObject
                        break
                    }
                }
                completion(nil)
            }
        }
    }
    
    func updateReplyComment(replyDataModel: ReplyCommentDataModel, newComment: String, completion: @escaping CommentService.ChangeCommentHandler){
        commentService.updateReplyComment(postuuid: postuuid, parentCommentuuid: replyDataModel.parentCommentuuid, commentuuid: replyDataModel.commentuuid, newComment: newComment) { [weak self] (error) in
            guard let self = self else { return }
            if error != nil{
                completion(error)
            }else{
                for (index, data) in self.commentData.enumerated(){
                    if var reply = data as? ReplyCommentDataModel, reply == replyDataModel{
                        reply.comment = newComment
                        self.commentData[index] = reply as AnyObject
                        break
                    }
                }
                completion(nil)
            }
        }
    }
    //--------------------------------------------------------------
}

// MARK:- Private APIs

private extension CommentsViewModel{
    func performFetchingComments(isRefreshed: Bool, lastComment: CommentDataModel?, mostRecentLikes: [CommentDataModel]?, insertAtZero: Bool, completion: @escaping ( (Error?, endReached) -> Void )){
        commentService.fetchParentComments(filterType: self.filterType, lastComment: lastComment, postuuid: postuuid, recentLikesComments: mostRecentLikes) { [weak self] (result) in
            guard let self = self else { return completion(CustomErrors.GeneralErrors.unknownError,true) }
            switch result{
            case .success(let commentDataModels):
                if isRefreshed{
                    self.comments.removeAll()
                    self.commentData.removeAll()
                    self.loadingReplies.removeAll()
                }
                self.comments.append(contentsOf: commentDataModels)
                let commentsAndReplyObjects = self.addLoadReplyObjectIfNecessary(comments: commentDataModels)
                self.commentData.append(contentsOf: self.filterComments(commentsAndReplyObjects, insertAtZero: insertAtZero))
                completion(nil, commentDataModels.count == 0)
            case .failure(let error):
                completion(error, true)
            }
        }
    }
    
    func filterComments(_ commentData: [AnyObject], insertAtZero: Bool) -> [AnyObject]{
        var filteredComments = [AnyObject]()
        var canAddReplyButtonAndReplies = true
        guard let blockDataModel = block else{
            return []
        }
        for comment in commentData{
            if let parentComment = comment as? CommentDataModel{
                
                if !blockDataModel.isBlocked.contains(parentComment.useruuid) && !blockDataModel.blocking.contains(parentComment.useruuid){
                    insertAtZero ? filteredComments.insert(parentComment as AnyObject, at: 0) : filteredComments.append(parentComment as AnyObject)
                    canAddReplyButtonAndReplies = true
                }else{
                    canAddReplyButtonAndReplies = false
                }
            }else if let replyComment = comment as? ReplyCommentDataModel{
                if canAddReplyButtonAndReplies, !blockDataModel.isBlocked.contains(replyComment.useruuid) && !blockDataModel.blocking.contains(replyComment.useruuid){
                    insertAtZero ? filteredComments.insert(replyComment as AnyObject, at: 0) : filteredComments.append(replyComment as AnyObject)
                }
            }else{
                if canAddReplyButtonAndReplies{
                    insertAtZero ? filteredComments.insert(comment, at: 0) : filteredComments.append(comment as AnyObject)
                }
            }
        }
        return filteredComments
    }
    
    func getMostRecentUpvotedComments() -> [CommentDataModel]?{
        if let lastComment = comments.last{
            return comments.filter{ $0.upvotes == lastComment.upvotes}
        }else{
            return nil
        }
    }
    
    func addLoadReplyObjectIfNecessary(comments: [CommentDataModel]) -> [AnyObject]{
        var finalCommentData = [AnyObject]()
        for comment in comments{
            finalCommentData.append(comment as AnyObject)
            if comment.hasReplies {
                finalCommentData.append(LoadRepliesDataModel(parentCommentUuid: comment.commentuuid, postuuid: postuuid, replyCount: comment.replyCount) as AnyObject)
            }
        }
        return finalCommentData
    }
}
