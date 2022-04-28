//
//  String+SplitSentence.swift
//  SumLit
//
//  Created by Junior Etrata on 10/26/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import Foundation

extension String{
   
   func splitSentence() -> [String]{
      let s = self
      var r = [Range<String.Index>]()
      let t = s.linguisticTags(
         in: s.startIndex..<s.endIndex, scheme:    NSLinguisticTagScheme.lexicalClass.rawValue,
         options: [], tokenRanges: &r)
      var result = [String]()
      
      let ixs = t.enumerated().filter{
         $0.1 == "SentenceTerminator"
         }.map {r[$0.0].lowerBound}
      var prev = s.startIndex
      for ix in ixs {
         var ixx = ix
         let afterix = self.index(after: ix)
         if self[exist: afterix] != nil, self[afterix].isPunctuation{
            ixx = self.index(after: ix)
         }
         let r = prev...ixx
         result.append(
            s[r].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
         prev = self.index(after: ixx)
      }
      return result
   }
}
