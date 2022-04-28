//
//  FeedView.swift
//  SumLit
//
//  Created by Junior Etrata on 8/14/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class FeedView: UIView
{
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet fileprivate weak var loadingLabel: UILabel!
   
   var refreshControl = UIRefreshControl()
   
   fileprivate let asyncBackgroundView : UIView = {
      let view = UIView()
      view.backgroundColor = Constants.Colors.loadingColor
      view.isUserInteractionEnabled = true
      view.translatesAutoresizingMaskIntoConstraints = false
      return view
   }()
   
   override func awakeFromNib()
   {
      if #available(iOS 10.0, *){
         tableView.refreshControl = refreshControl
      }else{
         tableView.addSubview(refreshControl)
      }
    tableView.estimatedRowHeight = 350
   }
}

//MARK:- PUBLIC API
extension FeedView{
   func setEmptyTableViewMessage(){
      loadingLabel.text = "No post has been created at this moment of time. Maybe you can help with that..."
   }
   
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
}
