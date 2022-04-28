//
//  FollowerTableViewCell.swift
//  SumLit
//
//  Created by Junior Etrata on 9/22/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol FollowersTableViewCellProtocol: class {
   func viewProfile(cell: FollowersTableViewCell)
}

class FollowersTableViewCell: UITableViewCell{
   
   @IBOutlet private weak var profilePictureImageView: UIImageView!{
      didSet{
         QuickSetupSpinner.start(from: profilePictureImageView, style: .whiteLarge, backgroundColor: .clear, baseColor: .white)
         profilePictureImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewProfile)))
         profilePictureImageView.layer.masksToBounds = true
         profilePictureImageView.layer.cornerRadius = profilePictureImageView.bounds.width / 2
         profilePictureImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewProfile)))
      }
   }
   @IBOutlet fileprivate weak var usernameLabel: UILabel!{
      didSet{
         usernameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewProfile)))
      }
   }
   @IBOutlet fileprivate weak var followedTimeStampLabel: UILabel!
   
   @IBOutlet weak var profileWidthConstraint: NSLayoutConstraint!{
      didSet{
         if UIDevice.current.userInterfaceIdiom == .pad{
            profileWidthConstraint.constant = 75
            self.layoutIfNeeded()
         }
      }
   }
   weak var followersCellProtocol: FollowersTableViewCellProtocol?
   private(set) var didSetDelegate = false
   private(set) var follower : FollowerDataModel?
   
   fileprivate var profilePicture: UIImage?{
      didSet{
         profilePictureImageView.image = profilePicture
         profilePictureImageView.layer.masksToBounds = true
         profilePictureImageView.layer.cornerRadius = profilePictureImageView.bounds.width / 2
      }
   }
   
   //MARK:- VIEW LIFECYCLE
   override func prepareForReuse() {
      super.prepareForReuse()
      if profilePicture == nil{
         QuickSetupSpinner.stop()
         QuickSetupSpinner.start(from: profilePictureImageView, style: .whiteLarge, backgroundColor: .clear, baseColor: .white)
      }
   }
}

//MARK:- PRIVATE API
extension FollowersTableViewCell{
   @objc func viewProfile(){
      followersCellProtocol?.viewProfile(cell: self)
   }
}

//MARK:- PUBLIC API
extension FollowersTableViewCell{
   
   func setupCell(follower: FollowerDataModel){
      self.follower = follower
      usernameLabel.text = follower.username
      followedTimeStampLabel.text = follower.followedAt.calenderTimeSinceNow()
      if follower.profilePicture != nil{
         QuickSetupSpinner.stop()
         profilePicture = follower.profilePicture
      }
   }
   
   func delegateHasBeenSet(){
      didSetDelegate = true
   }
}
