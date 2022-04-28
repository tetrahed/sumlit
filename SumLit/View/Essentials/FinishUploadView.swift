//
//  FinishUploadView.swift
//  SumLit
//
//  Created by Junior Etrata on 8/15/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class FinishUploadView: UIView
{
   @IBOutlet fileprivate weak var articleTitleLabel: UILabel!
   @IBOutlet fileprivate weak var summaryTextView: UITextView!
   @IBOutlet fileprivate weak var commentBackgroundView: UIView!{
      didSet{
         commentBackgroundView.roundCorners(by: 10)
      }
   }
   @IBOutlet fileprivate weak var commentTextView: UITextView!{
      didSet{
         commentTextView.addPadding(top: 10, bottom: 10, left: 10, right: 10)
        if #available(iOS 13.0, *) {
            commentTextView.tintColor = .label
        } else {
            // Fallback on earlier versions
            commentTextView.tintColor = .black
        }
         if UIDevice.current.userInterfaceIdiom == .pad{
            commentTextView.autocorrectionType = .no
         }
      }
   }
   @IBOutlet fileprivate weak var characterLimitLabel: UILabel!{
      didSet{
         characterLimitLabel.text = "0/200 characters"
      }
   }
   private(set) var hasChangedComment = false
   
   var commentText : String {
      return commentTextView.text
   }
   
   var articleTitleText: String {
      return articleTitleLabel.text ?? ""
   }
   
   var summaryText: String {
      return summaryTextView.text
   }
}

//MARK:- PUBLIC API
extension FinishUploadView{
   
   func willChangeComment(){
      if !hasChangedComment{
         hasChangedComment = true
         commentTextView.text = ""
        if #available(iOS 13.0, *) {
            commentTextView.textColor = .label
        } else {
            commentTextView.textColor = .black
            // Fallback on earlier versions
        }
      }
      
      if characterLimitLabel.isHidden{
         UIView.animate(withDuration: 0.2) { [weak self] in
            self?.characterLimitLabel.isHidden = false
         }
      }
   }
   
   func willStopEditingComment(){
      if !characterLimitLabel.isHidden{
         UIView.animate(withDuration: 0.2) { [weak self] in
            self?.characterLimitLabel.isHidden = true
         }
      }
   }
   
   func setCharacterCount(characterCount: Int){
      characterLimitLabel.text = "\(characterCount)/200 characters"
   }
   
   func setupView(title: String, summary: String){
      articleTitleLabel.text = title
      summaryTextView.text = summary
   }
   
   func disableCommentTextView(){
      commentTextView.isEditable = false
   }
   
   func enableCommentTextView(){
      commentTextView.isEditable = true
   }
}
