//
//  FinishUploadViewController.swift
//  SumLit
//
//  Created by Macbook on 5/29/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol FinishUploadProtocol: class {
   func didFinishUploadingNewPost()
}

class FinishUploadViewController: UIViewController
{
   @IBOutlet weak var finishUploadView: FinishUploadView!
   private var finishUploadViewModel = FinishUploadViewModel()
   
   //MARK:- DECLARED VARIABLES
   var prePostDataModel : PrePostDataModel!
   weak var didFinishUploadingDelegate: FinishUploadProtocol?
   
   //MARK:- VIEW LIFECYCLE
   override func viewDidLoad()
   {
      super.viewDidLoad()
      guard let prePostDataModel = self.prePostDataModel else {
        presentCustomAlertOnMainThread(title: "Error", message: "There seems to be some unknown issue. Please try again.") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
         return
      }
      setupUI(title: prePostDataModel.title)
      if let mainTabBarController = tabBarController as? MainTabBarViewController{
         didFinishUploadingDelegate = mainTabBarController
      }
   }
   
   //MARK:- BUTTON ACTIONS
   func handleCreatePost()
   {
      let comment = finishUploadView.hasChangedComment ? finishUploadView.commentText : ""
      createPost(title: finishUploadView.articleTitleText, summary: finishUploadViewModel.summary, comment: comment, link: prePostDataModel.link)
   }
}

//MARK:- NETWORK CALLS
extension FinishUploadViewController{
   
   func createPost(title: String, summary: String, comment: String, link: String){
      
      guard let useruuid = UserService.shared.uid,
            let username = UserService.shared.username else { return }
      
      if let error = finishUploadViewModel.validate(comment: comment){
        presentCustomAlertOnMainThread(title: "Comment error", message: error.localizedDescription)
         return
      }
      
      prepareForAsyncTask()
      
      finishUploadViewModel.createPost(useruuid: useruuid, username: username, title: title, summary: summary
      , comment: comment, link: link) { [weak self] (result) in
         switch result{
         case .success(_):
            self?.didFinishUploadingDelegate?.didFinishUploadingNewPost()
            self?.presentCustomAlertOnMainThread(title: "Success!", message: "Your post has been created.")
//            self?.presentAlertControllerBeforePopping(title: "Success!", message: "Your post has been created!")
            self?.tabBarController?.selectedIndex = 0
         case .failure(_):
            self?.setupAfterFailedAsyncTask()
            self?.presentCustomAlertOnMainThread(title: "Error", message: "We were not able to save your post. Please try again.")
         }
      }
   }
}

//MARK:- SETUP and SUMMARIZATION
extension FinishUploadViewController
{
   func setupUI(title: String) {
      navigationItem.title = "Finish Upload"
      finishUploadViewModel.performSummarization(text: prePostDataModel.body)
      finishUploadView.setupView(title: title, summary: setupSummary(finishUploadViewModel.summary))
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(displayConfirmationMessage))
      navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0.9739639163, green: 0.7061158419, blue: 0.1748842001, alpha: 1)
   }
   
   func setupSummary(_ text: String) -> String{
      let split = text.splitSentence()
      var newText = ""
      for sentence in split{
         newText += "\u{2022} \(sentence)\n\n"
      }
      return newText.trimmingCharacters(in: .whitespacesAndNewlines)
   }
   
   @objc func displayConfirmationMessage(){
      view.endEditing(true)
      let alert = UIAlertController.create(title: "Confirmation", message: "Are you sure you want to post this article?", alertStyle: .alert)
      let yesButton = UIAlertAction(title: "Yes", style: .destructive) { [weak self] (_) in
         self?.handleCreatePost()
      }
      let noButton = UIAlertAction(title: "No", style: .cancel, handler: nil)
      alert.addAction(yesButton)
      alert.addAction(noButton)
      self.present(alert, animated: true, completion: nil)
   }
   
   func prepareForAsyncTask(){
      finishUploadView.disableCommentTextView()
      navigationItem.rightBarButtonItem?.hideButton()
      navigationItem.setHidesBackButton(true, animated: false)
      navigationItem.title = "Posting..."
   }
   
   func setupAfterFailedAsyncTask(){
      finishUploadView.enableCommentTextView()
      navigationItem.rightBarButtonItem?.showButton(color: #colorLiteral(red: 0.9739639163, green: 0.7061158419, blue: 0.1748842001, alpha: 1))
      navigationItem.setHidesBackButton(false, animated: false)
      navigationItem.title = "Finish Upload"
   }
}

//MARK:- UITextViewDelegate
extension FinishUploadViewController: UITextViewDelegate{
   func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      if text == "\n"{
         textView.resignFirstResponder()
         return false
      }
      guard let preText = textView.text as NSString?,
            preText.replacingCharacters(in: range, with: text).count <= Constants.Comment.characterLimit else {
         return false
      }
      return true
   }
   
   func textViewDidChangeSelection(_ textView: UITextView) {
      finishUploadView.setCharacterCount(characterCount: textView.text.count)
   }
   
   func textViewDidBeginEditing(_ textView: UITextView) {
      finishUploadView.willChangeComment()
   }
   
   func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
      textView.text = textView.text.trimmingCharacters(in: .whitespaces)
      finishUploadView.willStopEditingComment()
      return true
   }
}
