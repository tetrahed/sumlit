//
//  ProfileView.swift
//  SumLit
//
//  Created by Junior Etrata on 9/18/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class ProfileView: UIView {
   
   struct TableViewConstants{
      static let profileIndexPath: IndexPath = IndexPath(row: 0, section: 0)
      static let profileSection = 0
      static let feedSection = 1
   }
   
   var refreshControl = UIRefreshControl()
   
   @IBOutlet weak var tableView: UITableView!{
      didSet{
         tableView.separatorColor = .clear
      }
   }
   
   fileprivate let asyncBackgroundView : UIView = {
      let view = UIView()
      view.backgroundColor = Constants.Colors.loadingColor
      view.isUserInteractionEnabled = true
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
   }()
   
   let askToSignInView = AskToSignInView.instantiate(signInText: "Sign in is required before viewing your profile.")
   
   var profileImage: UIImage?
   
   override func awakeFromNib() {
      super.awakeFromNib()
      if #available(iOS 10.0, *){
         tableView.refreshControl = refreshControl
      }else{
         tableView.addSubview(refreshControl)
      }
   }
}

//MARK:- PUBLIC API
extension ProfileView{
   func prepareForAsyncTask(){
      addSubview(asyncBackgroundView)
      asyncBackgroundView.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
      asyncBackgroundView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
      asyncBackgroundView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
      asyncBackgroundView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true
      QuickSetupSpinner.start(from: asyncBackgroundView, style: .whiteLarge, backgroundColor: Constants.Colors.loadingColor, baseColor: .white)
   }
   
   func setupAfterAsyncTask(){
      QuickSetupSpinner.stop()
      asyncBackgroundView.removeFromSuperview()
   }
   
   func displaySignInView(){
      self.addSubview(askToSignInView)
      askToSignInView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
      askToSignInView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
      askToSignInView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
      askToSignInView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
   }
}
