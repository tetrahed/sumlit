//
//  FollowerViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/22/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

class FollowersViewModel {
   
   typealias endReached = Bool
   private let followersService : FollowersService
   private let blockService: BlockService
   
   init(followersService: FollowersService = FollowersService(), blockService: BlockService = BlockService()) {
      self.followersService = followersService
      self.blockService = blockService
   }
   
   private var followers = [FollowerDataModel]()
   private(set) var filteredFollowers = [FollowerDataModel]()
   private var block : BlockDataModel?
   private let filterType: FilterTypes = .newest
   
   func getFollowers(useruuid: String, completion: @escaping ((endReached) -> Void)){
      if block == nil{
         blockService.getBlockInfo(useruuid: useruuid) { [weak self] (blockDataModel) in
            guard let self = self else {
               return
            }
            self.block = blockDataModel
            self.followersService.getFollowers(useruuid: useruuid, lastFollower: self.followers.last, filterType: self.filterType) { [weak self] (followers) in
               guard let self = self else {
                  completion(true)
                  return
               }
               self.followers.append(contentsOf: followers)
               self.filteredFollowers.append(contentsOf: self.filterFollowers(followers: followers))
               completion(followers.count == 0)
            }
         }
      }else{
         followersService.getFollowers(useruuid: useruuid, lastFollower: followers.last, filterType: filterType) { [weak self] (followers) in
            guard let self = self else {
               completion(true)
               return
            }
            self.followers.append(contentsOf: followers)
            self.filteredFollowers.append(contentsOf: self.filterFollowers(followers: followers))
            completion(followers.count == 0)
         }
      }
   }
   
   func updateFollower(followerDataModel: FollowerDataModel, at index: Int){
      filteredFollowers[index] = followerDataModel
   }
   
   func updateBlockInfo(useruuid: String, completion: @escaping (() -> Void)){
      blockService.getBlockInfo(useruuid: useruuid) { [weak self] (blockDataModel) in
         guard let self = self else {
            completion()
            return
         }
         self.block = blockDataModel
         self.filteredFollowers = self.filterFollowers(followers: self.filteredFollowers)
         completion()
      }
   }
}

fileprivate extension FollowersViewModel{
   func filterFollowers(followers: [FollowerDataModel]) -> [FollowerDataModel]{
      var filteredFollowers = [FollowerDataModel]()
      guard let blockDataModel = block else{
         return []
      }
      for follower in followers{
         if !blockDataModel.blocking.contains(follower.useruuid) && !blockDataModel.isBlocked.contains(follower.useruuid){
            filteredFollowers.append(follower)
         }
      }
      return filteredFollowers
   }
}
