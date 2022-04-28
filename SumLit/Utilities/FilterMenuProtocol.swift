//
//  FilterMenuProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 9/19/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol FilterMenuProtocol {
   func setupFilterMenu(filterTitle: String, filterTypes: [FilterTypes], completion: @escaping ((FilterTypes?) -> Void))
}

extension FilterMenuProtocol where Self: UIViewController{
   func setupFilterMenu(filterTitle: String, filterTypes: [FilterTypes], completion: @escaping ((FilterTypes?) -> Void)){
      let filterMenu = UIAlertController.create(title: filterTitle, message: nil, alertStyle: .actionSheet)
      for filterType in filterTypes{
         switch filterType{
         case .oldest:
            let oldestAction = UIAlertAction(title: "Oldest", style: .default) { (_) in
               completion(.oldest)
            }
            oldestAction.setValue(UIImage(named: "outline_trending_up_black_36pt_1x"), forKey: "image")
//            oldestAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            filterMenu.addAction(oldestAction)
         case .newest:
            let newestAction = UIAlertAction(title: "Newest", style: .default) { (_) in
               completion(.newest)
            }
            newestAction.setValue(UIImage(named: "outline_trending_down_black_36pt_1x"), forKey: "image")
            filterMenu.addAction(newestAction)
         case .upvotes:
            let upvotesAction = UIAlertAction(title: "Upvotes", style: .default) { (_) in
               completion(.upvotes)
            }
            upvotesAction.setValue(UIImage(named: "outline_arrow_upward_black_36pt_1x"), forKey: "image")
            filterMenu.addAction(upvotesAction)
         }
      }
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
         completion(nil)
      }
    cancelAction.setValue(Constants.Colors.orangeColor, forKey: "titleTextColor")
      filterMenu.addAction(cancelAction)
      present(filterMenu, animated: true, completion: nil)
   }
}

enum FilterTypes {
   case oldest
   case newest
   case upvotes
}
