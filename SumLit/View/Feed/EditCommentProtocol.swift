//
//  EditCommentProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 10/12/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit

protocol EditCommentHelperProtocol {
   var previousComment: String { get set }
    func willEditComment(textView: UITextView, repliedToUsername: String)
   func didFinishEditingComment(textView: UITextView)
   func getComment(textView: UITextView) -> String
   func resetCommentTextView(textView: UITextView)
   func handleTextViewShouldBeginEditing(textView: UITextView) -> Bool
   func handleShouldChangeTextIn(textView: UITextView, newText: String) -> Bool
}

class EditCommentHelper: EditCommentHelperProtocol {
   
   var previousComment: String = ""
   
    func willEditComment(textView: UITextView, repliedToUsername : String) {
        print(repliedToUsername)
        let attrStr = NSMutableAttributedString(attributedString: textView.attributedText)
        if !repliedToUsername.isEmpty { attrStr.deleteCharacters(in: (attrStr.string as NSString).range(of: repliedToUsername)) }
        textView.attributedText = attrStr
        textView.isEditable = true
        if !textView.isFirstResponder{
            textView.becomeFirstResponder()
        }
    }
   
   func didFinishEditingComment(textView: UITextView) {
      textView.text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
      textView.isEditable = false
      textView.isSelectable = false
      textView.resignFirstResponder()
   }
   
   func getComment(textView: UITextView) -> String {
      return textView.text
   }
   
   func resetCommentTextView(textView: UITextView) {
      textView.text = previousComment
   }
   
   func handleTextViewShouldBeginEditing(textView: UITextView) -> Bool {
      previousComment = textView.text
      return true
   }
   
   func handleShouldChangeTextIn(textView: UITextView, newText: String) -> Bool {
      if newText == "\n"{
         textView.resignFirstResponder()
         return false
      }
      return true
   }
}

class UpdateCommentHeightHelper{
   
   enum CellType {
      case Feed
      case Comment
   }
   
   func updateHeight(textView: UITextView, tableView: UITableView, cell: Any, cellType: CellType){
      let size = textView.bounds.size
      let newSize = tableView.sizeThatFits(CGSize(width: size.width,
                                                               height: CGFloat.greatestFiniteMagnitude))
      let cellWithType = (cellType == .Feed ? cell as! FeedTableViewCell : cell as! CommentsTableViewCell)
      if size.height != newSize.height {
         UIView.setAnimationsEnabled(false)
         tableView.beginUpdates()
         tableView.endUpdates()
         UIView.setAnimationsEnabled(true)
         if let thisIndexPath = tableView.indexPath(for: cellWithType) {
            tableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
         }
      }
   }
}
