//
//  ForbiddenWords+String.swift
//  SumLit
//
//  Created by Junior Etrata on 9/15/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

extension String {
   func hasForbiddenWord() -> String?{
      let forbiddenWords = "bitch|nigga|nigger|dick|penis|pussy"
      if let s = self.range(of: forbiddenWords, options: [.regularExpression, .caseInsensitive], range: self.startIndex..<self.endIndex, locale:nil){
         return String(self[s])
      }else{
         return nil
      }
   }
}
