//
//  WebHelpers.swift
//  SumLit
//
//  Created by Junior Etrata on 9/9/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Untagger
import SwiftSoup

private let forbiddenStatusCodeMin = 400

struct WebHelpers
{
   //functions to get status code, scrape the JavaScript if it exists, then get the HTML
   static func getWebsiteStatusCode(url: String, completion: @escaping ((Int) -> Void))
   {
      guard let link = URL(string: url) else {
         completion(forbiddenStatusCodeMin)
         return
      }
      let task = URLSession.shared.dataTask(with: link)
      {(data, response, error) in
         if error != nil || data == nil
         {
            completion(forbiddenStatusCodeMin)
         }
         else if let response = response as? HTTPURLResponse
         {
            completion(response.statusCode)
         }
      }
      task.resume()
   }
   
   //use SwiftSoup to get the JavaScript script and use Javascript context to detect redirect.  Then use websiteStatusCode to cover the rest of the edge cases.
   //if the JavaScript code contains "window.location" or something, use this link to get the link that first appears in the head.
   static func getRealWebsiteLink(html: String) -> String?
   {
      do
      {
         let doc: Document = try SwiftSoup.parse(html)
         let link: Element = try doc.select("a").first()!
         return try link.attr("href")
      }
      catch let error
      {
         print(error.localizedDescription)
         return nil
      }
   }
   
   //needs to include case where there is no javascript. Made return value an optional string.
   static func checkForJavascript(html: String) -> String?
   {
      //So if there is no javascript, it would return nil.
      var scriptRef = ""
      do
      {
         let doc: Document = try SwiftSoup.parse(html)
         let script: Elements = try doc.select("script")
         for link: Element in script.array()
         {
            scriptRef = link.data()
         }
         return scriptRef
      }
      catch Exception.Error( _, _)
      {
         return nil
      }
      catch
      {
         return nil
      }
   }
   
   static func linkToHTML(link: String) -> String?
   {
      if let url = URL(string: link)
      {
         do
         {
            let contents = try String(contentsOf: url)
            return contents
         }
         catch
         {
            return nil
         }
      }
      return nil
   }
}
