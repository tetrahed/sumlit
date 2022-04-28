//
//  ProfileTableViewCell.swift
//  SumLit
//
//  Created by Junior Etrata on 6/3/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol ProfileProtocol : class {
    func didPressOnProfileImage(cell: ProfileTableViewCell)
    func didPressOnFollowButton(cell: ProfileTableViewCell)
    func didPressOnFollowersButton(cell: ProfileTableViewCell)
}

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var profileImageView: UIImageView!{
        didSet{
            profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressOnProfileImage)))
            profileImageView.layer.masksToBounds = true
            profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        }
    }
       @IBOutlet fileprivate weak var usernameLabel: UILabel!
    @IBOutlet fileprivate weak var followerCountLabel: UILabel!
    @IBOutlet fileprivate weak var viewFollowerButton: UIButton!{
        didSet{
            viewFollowerButton.addTarget(self, action: #selector(didPressOnViewFollowersButton), for: .touchUpInside)
        }
    }
    @IBOutlet fileprivate weak var followButton: UIButton!{
        didSet{
            if followButton != nil{
                followButton.addTarget(self, action: #selector(didPressOnFollowButton), for: .touchUpInside)
                followButton.alpha = 0.2
                followButton.isUserInteractionEnabled = false
                followButton.roundCorners(by: 5)
            }
        }
    }
    @IBOutlet weak var followersStackView: UIStackView!
    @IBOutlet weak var profileWidthConstraint: NSLayoutConstraint!{
        didSet{
            if UIDevice.current.userInterfaceIdiom == .pad{
                profileWidthConstraint.constant = 200
                self.setNeedsUpdateConstraints()
            }
        }
    }
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet private weak var karmaCountLabel: UILabel!
    
    weak var profileDelegate: ProfileProtocol?
    private var currentUsernameDisplayed: String!
    
    fileprivate var profileImage : UIImage? {
        didSet{
            profileImageView.image = profileImage
            profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        }
    }
    
    @IBOutlet weak var mainStack: UIStackView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if profileImage == nil{
            QuickSetupSpinner.stop()
            QuickSetupSpinner.start(from: profileImageView, style: .whiteLarge, backgroundColor: .clear, baseColor: .white)
        }
    }
}

//PRIVATE API
extension ProfileTableViewCell{
    @objc private func didPressOnProfileImage(){
        profileDelegate?.didPressOnProfileImage(cell: self)
    }
    
    @objc private func didPressOnFollowButton(){
        prepareFollowButtonForAsyncTask()
        profileDelegate?.didPressOnFollowButton(cell: self)
    }
    
    @objc private func didPressOnViewFollowersButton(){
        profileDelegate?.didPressOnFollowersButton(cell: self)
    }
    
    private func setFollowButton(isFollowing: Bool){
        followButton.alpha = 1
        followButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.followButton.transform = CGAffineTransform.identity
        }
        switch isFollowing {
        case true:
            followButton.setTitle("Followed", for: .normal)
            followButton.setTitleColor(.white, for: .normal)
            followButton.backgroundColor = UIColor.init(named: "SLOrange")!//Constants.Colors.orangeColor
        case false:
            followButton.setTitle("Follow", for: .normal)
            followButton.setTitleColor(.white, for: .normal)
            followButton.backgroundColor = Constants.Colors.darkColor
        }
    }
    
    private func prepareFollowButtonForAsyncTask(){
        followButton.isUserInteractionEnabled = false
        followButton.alpha = 0.2
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.followButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
}

//PUBLIC API
extension ProfileTableViewCell{
    
    func setupCell(profileImage: UIImage?, username: String, followerCount: String, karmaCount: String, isFollowing: Bool?){
        if profileImage != nil{
            QuickSetupSpinner.stop()
            self.profileImage = profileImage
        }
        
        if followButton != nil, let state = isFollowing{
            setFollowButton(isFollowing: state)
        }
        
        usernameLabel.text = username
        followerCountLabel.text = followerCount
        karmaCountLabel.text = karmaCount
    }
    
    func removeFollowButton(){
        if followButton != nil, followButton.isDescendant(of: self){
            followButton.removeFromSuperview()
        }
    }
}
