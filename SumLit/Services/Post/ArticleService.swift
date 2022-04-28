//
//  ArticleService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/12/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Untagger

private let forbiddenStatusCodeMin = 400

class ArticleService {
   
   typealias ArticleHandler = ( (Result<((String,String,String)),Error>) -> Void )
   
   func extractData(from websiteURL: String, completion: @escaping ArticleHandler){
      
      WebHelpers.getWebsiteStatusCode(url: websiteURL)
      { [weak self] (statusCode) in
         guard let self = self else { return }
         guard statusCode < forbiddenStatusCodeMin else {
            completion(.failure(CustomErrors.ArticleParserError.deadlink))
            return
         }
         self.performExtraction(websiteURL: websiteURL, completion: completion)
      }
   }
   
   func extractDataWithValidURL(_ websiteURL: String, completion: @escaping ArticleHandler){
      self.performExtraction(websiteURL: websiteURL, completion: completion)
   }
}

fileprivate extension ArticleService{
   
   func checkIfLinkIsARedirect(websiteURL: String, contents: String, isRedirectedSite: inout Bool, realWebsiteURL: inout String?) {
      if let websiteJavaScriptCode = WebHelpers.checkForJavascript(html: contents){
         if websiteJavaScriptCode.contains("location.replace") || websiteJavaScriptCode.contains(".location = ")
         {
            isRedirectedSite = true
            realWebsiteURL = WebHelpers.getRealWebsiteLink(html: contents)
         }
         else
         {
            realWebsiteURL = websiteURL
         }
      }
   }
   
   func performExtraction(websiteURL: String, completion: @escaping ArticleHandler){
      var isRedirectedSite = false
      var realWebsiteURL : String? = nil
      
      guard var contents = WebHelpers.linkToHTML(link: websiteURL) else {
         completion(.failure(CustomErrors.ArticleParserError.brokenLink))
         return
      }
      self.checkIfLinkIsARedirect(websiteURL: websiteURL, contents: contents, isRedirectedSite: &isRedirectedSite, realWebsiteURL: &realWebsiteURL)
      
      if isRedirectedSite{
         guard let realLink = realWebsiteURL,
            let realContents = WebHelpers.linkToHTML(link: realLink) else {
               completion(.failure(CustomErrors.ArticleParserError.brokenLink))
               return
         }
         contents = realContents
      }
      
      let finalHTML = UntaggerManager.sharedInstance.stripScriptTags(contents)
      
      UntaggerManager.sharedInstance.getText(htmlString: finalHTML, { (result) in
         if let _ = result.error{
            completion(.failure(CustomErrors.GeneralErrors.unknownError))
         }else if let title = result.title, let body = result.body{
            if title.isEmpty || body.isEmpty || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
               completion(.failure(CustomErrors.GeneralErrors.unknownError))
            }else{
               completion(.success((title,body, isRedirectedSite ? realWebsiteURL! : websiteURL)))
            }
         }else{
            completion(.failure(CustomErrors.GeneralErrors.unknownError))
         }
      })
   }
}

