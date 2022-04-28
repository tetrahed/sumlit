//
//  InfiniteScrollProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 9/19/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol InfiniteScrollProtocol {
   var cellHeights: [IndexPath : CGFloat] { get set}
   var fetchingMore: Bool { get set}
   var endReached: Bool { get set}
   var leadingScreensForBatching: CGFloat { get }
   func shouldGetMore(scrollOffsetY: CGFloat, scrollContentHeight: CGFloat, scrollFrameHeight: CGFloat, completion: @escaping ((Bool) -> Void))
}

extension InfiniteScrollProtocol where Self: UIViewController{

   func shouldGetMore(scrollOffsetY: CGFloat, scrollContentHeight: CGFloat, scrollFrameHeight: CGFloat, completion: @escaping ((Bool) -> Void)){
      if scrollOffsetY > scrollContentHeight - scrollFrameHeight * leadingScreensForBatching {
         if !fetchingMore && !endReached {
            completion(true)
         }else{
            completion(false)
         }
      }
   }
}
