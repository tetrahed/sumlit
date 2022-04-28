//
//  ProfilePictureService.swift
//  SumLit
//
//  Created by Junior Etrata on 9/20/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import FirebaseStorage

class ProfilePictureService{
   
   typealias PhotoHandler = ((UIImage) -> Void)
   typealias UploadHandler = ((Result<UIImage?,Error>) -> Void)
   
   private let imagePicker = ImagePickerManager()
   private let maxSize: Int64 = 1*1024*1024
   private let compressionQuality: CGFloat = 0.33
   
   func getProfileImage(profileuuid: String, completion: @escaping PhotoHandler){
      let defaultPhoto = Constants.Images.defaultProfilePhoto
      let storageRef = Storage.storage().reference().child(profileuuid).child("profilePicture")
      storageRef.getData(maxSize: maxSize) { (data, error) in
         if let _  = error {
            completion(defaultPhoto)
         }else{
            if let data = data,
               let profileImage = UIImage(data: data){
               completion(profileImage)
            }else{
               completion(defaultPhoto)
            }
         }
      }
   }
   
   func uploadPhoto(profileuuid: String, profilePhoto: UIImage, completion: @escaping UploadHandler){
      let storageRef = Storage.storage().reference().child(profileuuid).child("profilePicture")
      if let uploadData = profilePhoto.jpegData(compressionQuality: compressionQuality){
         storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error{
               completion(.failure(error))
            }else{
               if let image = UIImage(data: uploadData){
                  completion(.success(image))
               }else{
                  completion(.success(nil))
               }
            }
         }
      }
   }
}
