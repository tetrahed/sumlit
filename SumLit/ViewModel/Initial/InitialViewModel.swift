//
//  InitialViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/13/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

struct InitialViewModel {
   
   private let initialService: InitialService
   
   init(initialService: InitialService = InitialService()) {
      self.initialService = initialService
   }
   
   func checkIfUserSessionIsValid(completion: @escaping InitialService.ResponseHandler){
      initialService.isValidSession { (isValid) in
         completion(isValid)
      }
   }
}
