//
//  AddCommentViewController.swift
//  Sumlit Share Extension
//
//  Created by Junior Etrata on 11/23/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit

protocol AddCommentProtocol: class {
   func addNewComment(_ comment: String?)
}

class AddCommentViewController: UIViewController {

   @IBOutlet weak var addCommentTextView: UITextView!
   @IBOutlet weak var characterLimitLabel: UILabel!
   var initialComment : String?
   weak var addCommentDelegate : AddCommentProtocol?
   
   //MARK:- VIEW LIFECYCLE
   override func viewDidLoad() {
      super.viewDidLoad()
      addCommentTextView.text = initialComment ?? ""
      
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleAddingComment))
   }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addCommentTextView.becomeFirstResponder()
    }
}

extension AddCommentViewController{
   
   @objc func handleAddingComment(){
      let comment = addCommentTextView.text.trimmingCharacters(in: .whitespaces)
      if let forbidden = comment.hasForbiddenWord(){
        return presentCustomAlertOnMainThread(title: "Error", message: "Please refrain from using words like: \(forbidden).")
      }
      addCommentDelegate?.addNewComment( !comment.isEmpty ? comment : nil )
      navigationController?.popViewController(animated: true)
   }
}

//MARK:- UITextViewDelegate
extension AddCommentViewController : UITextViewDelegate {
   
   func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
      return false
   }
   
   func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
      if text == "\n"{
         return false
      }
      guard let preText = textView.text as NSString?,
         preText.replacingCharacters(in: range, with: text).count <= Constants.Comment.characterLimit else {
            return false
      }
      return true
   }
   
   func textViewDidChange(_ textView: UITextView) {
      characterLimitLabel.text = "\(textView.text.count)/200"
   }
}
