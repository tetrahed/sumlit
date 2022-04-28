//
//  AddCommentViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/10/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

struct AddCommentViewModel {
   
   private let addCommentService: AddCommentService
   
   init(addCommentService: AddCommentService = AddCommentService()) {
      self.addCommentService = addCommentService
   }
   
   func addComment(postuuid: String, comment: String, completion: @escaping ((Error?) -> Void)){
      guard let useruuid = UserService.shared.uid else {
         completion(CustomErrors.GeneralErrors.unknownError)
         return
      }
      addCommentService.addParentComment(useruuid: useruuid, postuuid: postuuid, comment: comment) { (result) in
         switch result{
         case .success(_):
            completion(nil)
         case .failure(let error):
            completion(error)
         }
      }
   }
}
