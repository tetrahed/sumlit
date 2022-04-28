//
//  UploadViewController.swift
//  Sumlit
//
//  Created by Robert Chung on 5/28/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import Untagger

class UploadViewController: UIViewController
{
   
   @IBOutlet weak var uploadView: UploadView!
   private let uploadViewModel = UploadViewModel()
   
   //MARK:- VIEW LIFECYCLE
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      if UserService.shared.uid == nil{
         uploadView.askToSignInView.delegate = self
         uploadView.displaySignInView()
      }
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      if uploadView.wasUploading{
         uploadView.continueButton.removeActivityIndicator()
         DispatchQueue.main.async { [weak self] in
            self?.uploadView.continueButton.addActivityIndicator()
         }
      }
   }
   
   //MARK:- BUTTON ACTIONS
   @IBAction func processLink(_ sender: UIButton)
   {
      view.endEditing(true)
      guard let websiteURL = uploadView.newsLinkTextField.text,
         !websiteURL.isEmpty else {
            presentCustomAlertOnMainThread(title: "Empty field", message: "In order to upload an article, copy and paste the website url here. Or you could use Sumlit's share extension instead.")
            return
      }
      DispatchQueue.main.async {
         sender.addActivityIndicator()
      }
      startUploadWork(websiteURL: websiteURL, sender: sender)
   }
   
   @IBAction func handleLinkButtonPressed(_ sender: UIButton) {
      moveLinkButtonAnimation()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
         self?.uploadView.newsLinkTextField.becomeFirstResponder()
      }
   }
}

//MARK:- NETWORK CALLS
extension UploadViewController{
   
   fileprivate func startUploadWork(websiteURL: String, sender: UIButton){
      uploadView.wasUploading = true
      uploadViewModel.uploadArticle(websiteURL: websiteURL) { [weak self] (result) in
         self?.uploadView.wasUploading = false
         DispatchQueue.main.async {
            sender.removeActivityIndicator()
         }
         switch result{
         case .success(let title, let body, let link):
            self?.navigateToFinishUpload(articleTitle: title, articleText: body, articleLink: link)
            break
         case .failure(let error):
            DispatchQueue.main.async { [weak self] in
                self?.presentCustomAlertOnMainThread(title: "Error", message: error.localizedDescription)
            }
         }
      }
   }
}

//MARK:- NAVIGATION
extension UploadViewController: AskToSignInProtocol {
   
   func navigateToLogin() {
      (tabBarController as? MainTabBarViewController)?.navigateToLogin()
   }
   
   func navigateToFinishUpload(articleTitle: String, articleText: String, articleLink: String){
      let finishUploadStoryBoard = UIStoryboard(name: "FinishUpload", bundle: nil)
      if let finishUpload = finishUploadStoryBoard.instantiateViewController(withIdentifier: "FinishUploadViewController") as? FinishUploadViewController{
         let prePostModel = PrePostDataModel(title: articleTitle, body: articleText, link: articleLink)
         finishUpload.prePostDataModel = prePostModel
         navigationController?.pushViewController(finishUpload, animated: true)
      }else{
        presentCustomAlertOnMainThread(title: "Navigation error", message: "Sorry, engineers need to fix a bug.")
      }
   }
}

//MARK:- UITextFieldDelegate
extension UploadViewController: UITextFieldDelegate{
   
   func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      moveLinkButtonAnimation()
      return true
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
      textField.resignFirstResponder()
      return true
   }
}

//MARK:- PRIVATE API
extension UploadViewController{
   func moveLinkButtonAnimation(){
      if !uploadView.hasMovedLinkButton{
         DispatchQueue.main.async{ [weak self] in
            self?.uploadView.moveLinkbutton()
         }
      }
   }
}
