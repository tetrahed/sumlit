//
//  ImagePickerManager.swift
//  SumLit
//
//  Created by Junior Etrata on 6/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation
import UIKit


class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
   var picker = UIImagePickerController();
   var alert = UIAlertController.create(title: nil, message: nil, alertStyle: .actionSheet)
   var viewController: UIViewController?
   var pickImageCallback : ((UIImage?) -> ())?;
   
   override init(){
      super.init()
   }
   
   func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage?) -> ())) {
      pickImageCallback = callback;
      if self.viewController == nil{
         self.viewController = viewController;
         
         let cameraAction = UIAlertAction(title: "Camera", style: .default){
            UIAlertAction in
            self.openCamera()
         }
         let galleryAction = UIAlertAction(title: "Gallery", style: .default){
            UIAlertAction in
            self.openGallery()
         }
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ UIAlertAction in
            self.dismissAlert()
         }
         
         // Add the actions
         picker.delegate = self
         alert.addAction(cameraAction)
         alert.addAction(galleryAction)
         alert.addAction(cancelAction)
      }
      viewController.present(alert, animated: true, completion: nil)
   }
   func openCamera(){
      alert.dismiss(animated: true, completion: nil)
      if(UIImagePickerController .isSourceTypeAvailable(.camera)){
         picker.sourceType = .camera
         picker.allowsEditing = true
         self.viewController!.present(picker, animated: true, completion: nil)
      } else {
         let alertWarning = UIAlertController(title: "Warning", message: "You don't have a camera.", preferredStyle: .alert)
         self.viewController!.present(alertWarning, animated: true, completion: nil)
      }
   }
   func openGallery(){
      alert.dismiss(animated: true, completion: nil)
      picker.sourceType = .photoLibrary
      picker.allowsEditing = true
      self.viewController!.present(picker, animated: true, completion: nil)
   }
   
   func dismissAlert(){
      alert.dismiss(animated: true, completion: nil)
      pickImageCallback?(nil)
   }
   
   
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true, completion: nil)
   }
   
     // For Swift 4.2
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      
      var userImage : UIImage?
      if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
      {
         userImage = img
         
      }
      else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
      {
         userImage = img
      }
      
      picker.dismiss(animated: true, completion: nil)
      pickImageCallback?(userImage)
   }
   
   
   
   @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
   }
   
}

extension UIImage {
   var isPortrait:  Bool    { return size.height > size.width }
   var isLandscape: Bool    { return size.width > size.height }
   var breadth:     CGFloat { return min(size.width, size.height) }
   var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
   var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
   var circleMasked: UIImage? {
      UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
      defer { UIGraphicsEndImageContext() }
      guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
      UIBezierPath(ovalIn: breadthRect).addClip()
      UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
      return UIGraphicsGetImageFromCurrentImageContext()
   }
}
