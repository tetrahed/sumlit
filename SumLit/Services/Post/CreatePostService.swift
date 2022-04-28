//
//  FinishUploadService.swift
//  SumLit
//
//  Created by Junior Etrata on 8/15/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import FirebaseDatabase

class CreatePostService
{
   typealias SavePostsHandler = ( (Result<Bool,Error>) -> Void )

   func savePost(useruuid: String, title: String, summary: String, comment: String, link: String, completion: @escaping SavePostsHandler)
   {
      let postRef = Constants.FirebaseRefs.postRef.childByAutoId()
      guard let key = postRef.key else{
         completion(.failure(CustomErrors.GeneralErrors.unknownError))
         return
      }

      let timeStamp: Any = [".sv":"timestamp"]

      guard let voteObject = createVoteObject(useruuid: useruuid) else {
         completion(.failure(CustomErrors.GeneralErrors.unknownError))
         return
      }

      let initialPostObject = createIntialPostObject(useruuid: useruuid, title: title, summary: summary, comment: comment, link: link, timeStamp: timeStamp)
      
      Constants.FirebaseRefs.postRef.child(key).setValue(initialPostObject) { (error, ref) in
         if let error = error{
            completion(.failure(error))
         }else{
            Constants.FirebaseRefs.postRef.child(key).observeSingleEvent(of: .value, with: { [weak self] (snapshot) in

               if let dict = snapshot.value as? [String:Any],
                  let timeStampAsDouble = dict["timeStamp"] as? Double{

                  guard let finalPostObject = self?.createFinalPostObject(useruuid: useruuid, title: title, summary: summary, comment: comment, link: link, timeStamp: timeStampAsDouble) else{
                     Constants.FirebaseRefs.postRef.child(key).setValue(nil)
                     completion(.failure(CustomErrors.GeneralErrors.unknownError))
                     return
                  }

                let postCreation : [String: Any] = ["postVote/\(key)": voteObject, "posts/\(key)": finalPostObject, "selfPosts/\(useruuid)/\(key)": finalPostObject]

                  Constants.FirebaseRefs.databaseRef.updateChildValues(postCreation) { (error, ref) in
                     if let error = error{
                        Constants.FirebaseRefs.postRef.child(key).setValue(nil)
                        completion(.failure(error))
                     }else{
                        completion(.success(true))
                     }
                  }

               }
            })
         }
      }
   }
}

fileprivate extension CreatePostService{
   
   func createIntialPostObject(useruuid: String, title:String, summary:String, comment: String, link: String, timeStamp: Any) -> [String:Any]?{
      return [
         "useruuid": useruuid,
         "title": title,
         "summary": summary,
         "comment": comment,
         "link": link,
         "timeStamp": timeStamp,
         "commentCount" : 0
      ]
   }
   
   func createFinalPostObject(useruuid: String, title:String, summary:String, comment: String, link: String, timeStamp: Double) -> [String:Any]?{
      
      let reverseTimeStamp = ((timeStamp ) * -1) as Any
      
      return [
         "useruuid": useruuid,
         "title": title,
         "summary": summary,
         "comment": comment,
         "link": link,
         "timeStamp": timeStamp as Any,
         "reverseTimeStamp": reverseTimeStamp,
        "commentCount" : 0
      ]
   }
   
   func createVoteObject(useruuid: String) -> [String:Any]?{
      return [
        "postersuuid" : useruuid,
         "upvotes": 1,
         "upvoters": [useruuid: true]
      ]
   }
}
