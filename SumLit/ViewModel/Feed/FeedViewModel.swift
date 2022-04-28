//
//  FeedViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

class FeedViewModel{
   
   typealias endReached = Bool
   
   private let voteService: PostVoteService
   private let postService: PostService
   private let blockService: BlockService
   private let commentService: CommentService
   private let postDeletionService: PostDeletionService
   
   enum State {
      case normal
      case editing
   }
   
   private(set) var currentState : State = .normal
   
   init(voteService: PostVoteService = PostVoteService(), postService: PostService = PostService(), blockService: BlockService = BlockService(), commentService: CommentService = CommentService(), postDeletionService : PostDeletionService = PostDeletionService()) {
      self.voteService = voteService
      self.postService = postService
      self.blockService = blockService
      self.commentService = commentService
      self.postDeletionService = postDeletionService
   }
   
   var filterType : FilterTypes = .newest{
      didSet{
         switch filterType {
         case .oldest:
            filterTitle = "Order by: Oldest"
         case .newest:
            filterTitle = "Order by: Newest"
         default:
            break
         }
      }
   }
   
   private var block : BlockDataModel?
   private var posts : [PostDataModel] = []
   private(set) var filteredPosts : [PostDataModel] = []
   var fullyDisplayedPosts : [IndexPath: Bool] = [:]
   var upvoteCount : [IndexPath: (PostVoteService.VoteState, Int)] = [:]
   private(set) var editIndexPath : IndexPath!

   private(set) var filterTitle = "Order by: Newest"
   
   func getPosts(useruuid: String? = nil, isRefreshed: Bool, isSelfPost: Bool, completion: @escaping ( (Error?, endReached) -> Void )){
      let lastPost = (isRefreshed) ? nil : posts.last
      if block == nil{
         if let useruuid = useruuid{
            blockService.getBlockInfo(useruuid: useruuid) { [weak self] (blockDataModel) in
               guard let self = self else {
                  completion(CustomErrors.GeneralErrors.unknownError, true)
                  return
               }
               self.block = blockDataModel
               self.postService.getPosts(useruuid: useruuid , filterType: self.filterType, lastPost: lastPost, isSelfPost: isSelfPost) { [weak self] (result) in
                  guard let self = self else {
                     completion(CustomErrors.GeneralErrors.unknownError, true)
                     return
                  }
                  switch result{
                  case .success(let postsDataModel):
                     if isRefreshed {
                        self.posts.removeAll()
                        self.filteredPosts.removeAll()
                     }
                     self.posts.append(contentsOf: postsDataModel)
                     self.filteredPosts.append(contentsOf: self.filterPosts(posts: postsDataModel))
                     completion(nil, postsDataModel.count == 0)
                  case .failure(let error):
                     completion(error, true)
                  }
               }
            }
         }else{
            block = BlockDataModel(isBlocked: [], blocking: [], reportedPosts: [])
            self.postService.getPosts(useruuid: useruuid ?? "", filterType: self.filterType, lastPost: lastPost, isSelfPost: isSelfPost) { [weak self] (result) in
               guard let self = self else {
                  completion(CustomErrors.GeneralErrors.unknownError, true)
                  return
               }
               switch result{
               case .success(let postsDataModel):
                  if isRefreshed {
                     self.posts.removeAll()
                     self.filteredPosts.removeAll()
                  }
                  self.posts.append(contentsOf: postsDataModel)
                  self.filteredPosts.append(contentsOf: self.filterPosts(posts: postsDataModel))
                  completion(nil, postsDataModel.count == 0)
               case .failure(let error):
                  completion(error, true)
               }
            }
         }
      }else{
         postService.getPosts(useruuid: useruuid ?? "", filterType: filterType, lastPost: lastPost, isSelfPost: isSelfPost) { [weak self] (result) in
            guard let self = self else {
               completion(CustomErrors.GeneralErrors.unknownError,true)
               return
            }
            switch result{
            case .success(let postsDataModel):
               if isRefreshed {
                  self.posts.removeAll()
                  self.filteredPosts.removeAll()
               }
               self.posts.append(contentsOf: postsDataModel)
               self.filteredPosts.append(contentsOf: self.filterPosts(posts: postsDataModel))
               completion(nil, postsDataModel.count == 0)
            case .failure(let error):
               completion(error, true)
            }
         }
      }
   }
   
   func upvotePost(useruuid: String, postuuid: String, completion: @escaping PostVoteService.UpvotePostHandler){
      voteService.upvotePost(useruuid: useruuid, postuuid: postuuid) { (result) in
         completion(result)
      }
   }
   
   func downvotePost(useruuid: String, postuuid: String, completion: @escaping PostVoteService.UpvotePostHandler){
      voteService.downvotePost(useruuid: useruuid, postuuid: postuuid) { (result) in
         completion(result)
      }
   }
   
   func getCurrentVoteState(useruuid: String, postuuid: String, completion: @escaping PostVoteService.UpvotePostHandler){
      voteService.getCurrentVoteState(useruuid: useruuid, postuuid: postuuid) { (result) in
         completion(result)
      }
   }
   
   func updateBlockInfo(useruuid: String, completion: @escaping (() -> Void)){
      blockService.getBlockInfo(useruuid: useruuid) { [weak self] (blockDataModel) in
         guard let self = self else { return }
         self.block = blockDataModel
         self.filteredPosts = self.filterPosts(posts: self.filteredPosts)
         completion()
      }
   }
   
   func blockPost(useruuid: String, post: PostDataModel, message: String, completion: @escaping BlockService.BlockPostHandler){
      blockService.blockPost(message: message, selfuuid: useruuid, postuuid: post.postuuid, posterusername: post.username ?? "", postTitle: post.title ?? "") { [weak self] (error) in
         guard let self = self else {
            completion(CustomErrors.GeneralErrors.unknownError)
            return
         }
         if error == nil{
            self.filteredPosts = self.filteredPosts.filter{ $0.postuuid != post.postuuid}
            self.block?.reportedPosts.append(post.postuuid)
         }
         completion(error)
      }
   }
   
   func blockUser(useruuid: String, username: String, blockedUseruuid: String, blockedUsername: String, completion: @escaping BlockService.BlockUserHandler){
      blockService.blockUser(selfuuid: useruuid, selfusername: username, blockedUseruuid: blockedUseruuid, blockedUsername: blockedUsername) { [weak self] (error) in
         guard let self = self else {
            completion(CustomErrors.GeneralErrors.unknownError)
            return
         }
         if error != nil{
            completion(error)
         }else{
            self.block?.blocking.append(blockedUseruuid)
            self.filteredPosts = self.filteredPosts.filter { $0.useruuid != blockedUseruuid}
            completion(nil)
         }
      }
   }
   
   func willBeginEditingComment(){
      currentState = .editing
   }
   
   func didFinishEditing(){
      currentState = .normal
   }
   
   func setEditIndexPath(_ indexPath: IndexPath){
      editIndexPath = indexPath
   }
   
   func validatePostComment(newComment: String) -> Error?{
      guard let forbiddenWord = newComment.hasForbiddenWord() else {
         return nil
      }
      return CustomErrors.GeneralErrors.forbiddenWords(word: forbiddenWord)
   }
   
   func updateWithService(post: PostDataModel, newComment: String, completion: @escaping PostService.UpdateCommentHandler){
      postService.updateComment(postuuid: post.postuuid, newComment: newComment) { [weak self] (error) in
         guard let self = self else { return }
         if error != nil{
            completion(error)
         }else{
            if let index = self.posts.firstIndex(of: post){
               self.posts[index].comment = newComment
            }
            if let index = self.filteredPosts.firstIndex(of: post){
               self.filteredPosts[index].comment = newComment
            }
            completion(nil)
         }
      }
   }
   
   func update(post: PostDataModel, newComment: String){
      if let index = self.posts.firstIndex(of: post){
         self.posts[index].comment = newComment
      }
      if let index = self.filteredPosts.firstIndex(of: post){
         self.filteredPosts[index].comment = newComment
      }
   }
   
   func delete(_ post: PostDataModel, completion: @escaping PostDeletionService.DeletePostHandler){
      postDeletionService.deletePost(post) { [weak self] (error) in
         if error == nil{
            self?.removePostIfNecessary(post)
         }
         completion(error)
      }
   }
   
   func removePostIfNecessary(_ post: PostDataModel){
      if let index = self.posts.firstIndex(of: post){
         self.posts.remove(at: index)
      }
      if let index = self.filteredPosts.firstIndex(of: post){
         self.filteredPosts.remove(at: index)
      }
   }
}

fileprivate extension FeedViewModel{
   func filterPosts(posts: [PostDataModel]) -> [PostDataModel]{
      var filteredPosts = [PostDataModel]()
      guard let blockDataModel = block else{
         return []
      }
      for post in posts{
         if !blockDataModel.isBlocked.contains(post.useruuid ?? "") && !blockDataModel.blocking.contains(post.useruuid ?? "") && !blockDataModel.reportedPosts.contains(post.postuuid) && !post.wasDeleted{
            filteredPosts.append(post)
         }
      }
      return filteredPosts
   }
}
