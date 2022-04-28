//
//  BlockedUsersTableViewCell.swift
//  SumLit
//
//  Created by Junior Etrata on 9/25/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol BlockedUsersTableViewCellProtocol: class {
   func viewProfile(cell: BlockedUsersTableViewCell)
   func unblockUser(cell: BlockedUsersTableViewCell)
}

class BlockedUsersTableViewCell: UITableViewCell {

   @IBOutlet fileprivate weak var usernameLabel: UILabel!{
      didSet{
         usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressOnUsernameLabel)))
      }
   }
   @IBOutlet fileprivate weak var unBlockButton: UIButton!{
      didSet{
         unBlockButton.addTarget(self, action: #selector(didPressOnUnblockButton), for: .touchUpInside)
         unBlockButton.roundCorners(by: 5)
      }
   }
   
   weak var blockedUsersDelegate : BlockedUsersTableViewCellProtocol?
   private(set) var hasSetDelegate = false
   private(set) var blockedUsers : BlockedUserDataModel?
}

//MARK:- PRIVATE API
fileprivate extension BlockedUsersTableViewCell{
   @objc func didPressOnUsernameLabel(){
      //blockedUsersDelegate?.viewProfile(cell: self)
   }
   
   @objc func didPressOnUnblockButton(){
      blockedUsersDelegate?.unblockUser(cell: self)
   }
}

//MARK:- PUBLIC API

extension BlockedUsersTableViewCell{
   func setupCell(blockedUsers : BlockedUserDataModel){
      self.blockedUsers = blockedUsers
      usernameLabel.text = blockedUsers.username
   }
   
   func didSetDelegate(){
      hasSetDelegate = true
   }
   
   func disableUnblockButton(){
      unBlockButton.isUserInteractionEnabled = false
      unBlockButton.alpha = 0.5
      UIView.animate(withDuration: 0.15) { [weak self] in
         self?.unBlockButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
      }
   }
   
   func enableUnblockButton(){
      unBlockButton.isUserInteractionEnabled = true
      unBlockButton.alpha = 1
      UIView.animate(withDuration: 0.15) { [weak self] in
         self?.unBlockButton.transform = CGAffineTransform.identity
      }
   }
}
