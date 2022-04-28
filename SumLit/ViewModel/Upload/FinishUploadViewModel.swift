//
//  FinishUploadViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/14/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

struct FinishUploadViewModel {
   
   private let createPostService: CreatePostService
   
   init(createPostService: CreatePostService = CreatePostService()) {
      self.createPostService = createPostService
   }
   
   var commentCharacterCount: Int = 0 {
      didSet{
         commentCharacterText = "\(commentCharacterCount)/200 characters"
      }
   }
   private(set) var commentCharacterText: String = "0/200 characters"
   private(set) var summary: String!
   
   func validate(comment: String) -> Error?{
      if let word = comment.hasForbiddenWord(){
         return CustomErrors.GeneralErrors.forbiddenWords(word: word)
      }
      return nil
   }
   
   func createPost(useruuid: String, username: String, title: String, summary: String, comment: String, link: String, completion: @escaping CreatePostService.SavePostsHandler){
      createPostService.savePost(useruuid: useruuid, title: title, summary: summary, comment: comment, link: link) { (result) in
         completion(result)
      }
   }
   
   mutating func performSummarization(text: String) {
      let summary = Summary()
      self.summary = summary.getSummary(text: text, numberOfSentences: getNumberOfSentences(text: text))
   }
}

//MARK:- Private API
fileprivate extension FinishUploadViewModel{
   func getNumberOfSentences(text: String) -> Int {
      let numberOfWords = getNumberOfWords(text: text)
      if numberOfWords <= 700 {
         return 3
      }
      else if numberOfWords > 700 && numberOfWords <= 1100 {
         return 4
      }
      else {
         return 5
      }
   }
   
   //less than 700 words: 0.80
   //700-1000 words: 0.85
   //1000-2000 words: 0.92
   //>2000 words: 0.96
   func getNumberOfWords(text: String) -> Int
   {
      let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
      let components = text.components(separatedBy: chararacterSet)
      let words = components.filter { !$0.isEmpty }
      
      return words.count
   }
}
