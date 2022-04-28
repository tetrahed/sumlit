//
//  UploadViewModel.swift
//  SumLit
//
//  Created by Junior Etrata on 9/12/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

struct UploadViewModel {
   
   private let articleService: ArticleService
   
   init(articleService: ArticleService = ArticleService()) {
      self.articleService = articleService
   }
   
   func uploadArticle(websiteURL: String, completion: @escaping ArticleService.ArticleHandler){
      articleService.extractData(from: websiteURL) { (result) in
         completion(result)
      }
   }
}
