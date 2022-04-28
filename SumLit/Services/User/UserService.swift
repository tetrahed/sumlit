//
//  UserService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Firebase

class UserService{
    
    typealias LogoutHandler = ( (Error?) -> Void )
    
    static let shared = UserService()
    
    private var isBanned: Bool?
    
    typealias ResponseHandler = ((Bool) -> Void)
    
    private var getCurrentUser: User? {
        if let user = Auth.auth().currentUser,
            user.isEmailVerified,
            let bannedStatus = isBanned,
            bannedStatus != true{
            return user
        }else{
            return nil
        }
    }
    
    var username: String? = nil
    
    var uid : String? {
        if let user = getCurrentUser{
            return user.uid
        }else{
            return nil
        }
    }
    
    var isAnonymous: Bool{
        if let user = getCurrentUser{
            return user.isAnonymous
        }else{
            return false
        }
    }
    
    func logout(completion: @escaping LogoutHandler){
        do {
            try Auth.auth().signOut()
            setSharedData(useruuid: nil, username: nil)
            completion(nil)
        }catch{
            completion((CustomErrors.GeneralErrors.unknownError))
        }
    }
    
    func logout(){
        logout { (_) in }
    }
    
    func isValidSession(completion: @escaping ResponseHandler){
        if let user = Auth.auth().currentUser,
            user.isEmailVerified{
            let validUsersRef = Constants.FirebaseRefs.validUsersRef.child(user.uid)
            validUsersRef.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                guard let self = self else { return }
                if snapshot.exists(),
                    let username = snapshot.value as? String{
                    self.isBanned = false
                    self.username = username
                    self.setSharedData(useruuid: self.uid, username: self.username)
                    
                    completion(true)
                }else{
                    self.isBanned = true
                    self.setSharedData(useruuid: nil, username: nil)
                    completion(false)
                }
            }) { (_) in
                self.setSharedData(useruuid: nil, username: nil)
                completion(false)
            }
        }else{
            self.setSharedData(useruuid: nil, username: nil)
            completion(false)
        }
    }
    
    func signInAnonymousSessionIfNeeded(completion: @escaping ((Error?) -> ())){
        if let user = Auth.auth().currentUser, !user.isAnonymous{
            signInAsAnon(completion)
        }else if Auth.auth().currentUser == nil{
            signInAsAnon(completion)
        }else{
            completion(nil)
        }
    }
}

fileprivate extension UserService{
    func signInAsAnon(_ completion: @escaping ((Error?) -> ())) {
        Auth.auth().signInAnonymously { (result, error) in
            if error == nil{
                completion(nil)
            }else{
                completion(error)
            }
        }
    }
    
    func setSharedData(useruuid: String?, username: String?){
        let defaults = UserDefaults(suiteName: "group.com.RobbyApp.SumLit")
        defaults?.set(useruuid, forKey: "useruuid")
        defaults?.set(username, forKey: "username")
    }
}
