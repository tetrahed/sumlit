//
//  ViewBlockedUsersViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/25/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

class ViewBlockedUsersViewModel{
   
   typealias endReached = Bool
   private let blockedUsersService : BlockedUsersService
   
   init(blockedUsersService: BlockedUsersService = BlockedUsersService()) {
      self.blockedUsersService = blockedUsersService
   }
   
   private(set) var blockedUsers = [BlockedUserDataModel]()
   private let filterType : FilterTypes = .newest
   
   func getBlockedUsers(useruuid: String, completion: @escaping ((endReached) -> Void)){
      blockedUsersService.getBlockedUsers(useruuid: useruuid, filterType: filterType, lastBlockedUser: blockedUsers.last) { [weak self] (blockedUsersDataModel) in
         self?.blockedUsers.append(contentsOf: blockedUsersDataModel)
         completion(blockedUsersDataModel.count == 0)
      }
   }
   
   func unblockUser(useruuid: String, blockedUseruuid: String, completion: @escaping BlockedUsersService.UnblockUserHandler){
      blockedUsersService.unblockUser(useruuid: useruuid, blockedUseruuid: blockedUseruuid) { [weak self] (error) in
         guard let self = self else {
            completion(CustomErrors.GeneralErrors.unknownError)
            return
         }
         if let error = error{
            completion(error)
         }else{
            self.blockedUsers = self.blockedUsers.filter { $0.useruuid != blockedUseruuid}
            completion(nil)
         }
      }
   }
}
