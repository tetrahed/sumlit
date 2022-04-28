//
//  UsernameService.swift
//  SumLit
//
//  Created by Junior Etrata on 12/5/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import FirebaseAuth

class UsernameService {
    
    typealias UpdateUsernameHandler = (Result<String,Error>) -> Void
    
    func update(username newUsername: String, completion: @escaping UpdateUsernameHandler ){
        guard let useruuid = UserService.shared.uid, let username = UserService.shared.username else { return }
        Constants.FirebaseRefs.usernamesRef.child(newUsername).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(){
                completion(.failure(CustomErrors.AuthServiceErrors.usernameAlreadyTaken))
            }else{
                print(newUsername, username)
                guard newUsername != username else { return }
                let postCreation : [String: Any?] = ["usernames/\(newUsername)":true, "usernames/\(username)":nil, "users/\(useruuid)/username":newUsername,"validUsers/\(useruuid)":newUsername]
                Constants.FirebaseRefs.databaseRef.updateChildValues(postCreation as [AnyHashable : Any]) { [weak self] (error, ref) in
                    if let _ = error{
                        completion(.failure(CustomErrors.GeneralErrors.unknownError))
                    }else{
                        UserService.shared.username = newUsername
                        self?.setUsernameSharedData(username: newUsername)
                        completion(.success(newUsername))
                    }
                }
            }
        }
    }
    
    private func setUsernameSharedData(username: String){
       let defaults = UserDefaults(suiteName: "group.com.RobbyApp.SumLit")
       defaults?.set(username, forKey: "username")
    }
}
