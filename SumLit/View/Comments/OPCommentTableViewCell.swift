//
//  OPCommentTableViewCell.swift
//  SumLit
//
//  Created by Junior Etrata on 12/1/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit

class OPCommentTableViewCell: UITableViewCell {
   
   var viewProfile : ( () -> () )?

   @IBOutlet private weak var usernameButton: UIButton!
   @IBOutlet private weak var commentTextView: UITextView!{
      didSet{
         commentTextView.addPadding(top: 0, bottom: 8, left: 0, right: 0)
         commentTextView.textContainer.lineFragmentPadding = 0
      }
   }
   @IBOutlet private weak var timeStamp: UILabel!
   
   func configure(with opComment: OPCommentDataModel){
      usernameButton.setTitle(opComment.username, for: .normal)
      if opComment.comment.isEmpty {
         commentTextView.removeFromSuperview()
      }else{
         commentTextView.text = opComment.comment
      }
      timeStamp.text = opComment.createdAt.shortenCalenderTimeSinceNow()
   }
   
   @IBAction func handleUsernamePressed(_ sender: UIButton) {
      viewProfile?()
   }
}
