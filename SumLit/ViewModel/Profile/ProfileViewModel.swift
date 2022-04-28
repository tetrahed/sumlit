//
//  ProfileViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/18/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

class ProfileViewModel {

    private let followInfoService: FollowInfoService
    private let followService: FollowService
    private let blockService: BlockService
    private let usernameService: UsernameService
    private let creditsService: CreditsService
    
    init(followInfoService: FollowInfoService = FollowInfoService(), followService: FollowService = FollowService(), blockService: BlockService = BlockService(), usernameService: UsernameService = UsernameService(), creditsService: CreditsService = CreditsService()) {
        self.followInfoService = followInfoService
        self.followService = followService
        self.blockService = blockService
        self.usernameService = usernameService
        self.creditsService = creditsService
    }
    
    fileprivate var followerCount : Int = 0{
        didSet{
            if followerCount < 0 { followerCount = 0}
            followerCountText = "\(followerCount.formatUsingAbbrevation())"
        }
    }
    
    private(set) var followerCountText : String = "-"
    private(set) var isFollowing : Bool?
    private(set) var karmaCountText : String = "-"
    
    func getFollowStatus(profileuuid: String, completion: @escaping ( () -> Void)){
        guard let useruuid = UserService.shared.uid else {
            isFollowing = false
            completion()
            return
        }
        followInfoService.isFollowing(useruuid: useruuid, profileuuid: profileuuid) { [weak self] (status) in
            self?.isFollowing = status
            completion()
        }
    }
    
    func getFollowCount(useruuid: String, completion: @escaping ( () -> Void )){
        followInfoService.getFollowerCount(useruuid: useruuid) { [weak self] (count) in
            self?.followerCount = count
            completion()
        }
    }
    
    func updateFollowState(useruuid: String, username: String, profileuuid: String, completion: @escaping FollowService.FollowerHandler){
        
        guard let isFollowing = isFollowing else{
            completion(CustomErrors.GeneralErrors.unknownError)
            return
        }
        
        if isFollowing{
            followService.removeFollowFromSelf(selfuuid: useruuid, profileuuid: profileuuid) { [weak self] (error) in
                if let error = error {
                    completion(error)
                }else{
                    self?.isFollowing = false
                    completion(nil)
                }
            }
        }else{
            blockService.getBlockInfo(useruuid: useruuid) { [weak self] (blockDataModel) in
                if !blockDataModel.isBlocked.contains(profileuuid) && !blockDataModel.blocking.contains(profileuuid){
                    self?.followService.addFollower(selfuuid: useruuid, selfusername: username, profileuuid: profileuuid) { [weak self] (error) in
                        if let error = error{
                            completion(error)
                        }else{
                            self?.isFollowing = true
                            completion(nil)
                        }
                    }
                }else{
                    completion(CustomErrors.FollowError.blocked)
                    return
                }
            }
        }
    }
    
    func update(username newUsername: String, completion: @escaping UsernameService.UpdateUsernameHandler){
        usernameService.update(username: newUsername, completion: completion)
    }
    
    func fetchCredits(useruuid: String, completion: @escaping (() -> Void)){
        creditsService.fetchKarma(useruuid: useruuid) { [weak self] (result) in
            guard let self = self else { return }
            switch result{
            case .success(let karmaDataModel):
                self.karmaCountText = "\(karmaDataModel.creditsCount)"
                completion()
            case .failure(_):
                self.karmaCountText = "\(-1)"
                completion()
            }
        }
    }
}
