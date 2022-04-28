//
//  FeedViewModelProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 9/19/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol FeedViewModelProtocol: OpenLinkProtocol, FeedNavigationProtocol {
   var feedViewModel : FeedViewModel { get set}
   func upvote(cell: FeedTableViewCell)
   func downvote(cell: FeedTableViewCell)
   func getCurrentVoteState(postuuid: String, cell: FeedTableViewCell, tag: Int, indexPath: IndexPath)
//   func getCommentCount(postuuid: String, cell: FeedTableViewCell, tag: Int)
   func updateCommentFor(post: PostDataModel, newComment: String)
   func _updateDisplay(_ cell: FeedTableViewCell, tableView: UITableView, isProfile: Bool)
}

extension FeedViewModelProtocol where Self: UIViewController{
   
   func upvote(cell: FeedTableViewCell){
      guard let cellPost = cell.post, let useruuid = UserService.shared.uid, feedViewModel.currentState != .editing else { return }
      cell.startUpvoteSpinnerIfNeeded()
      feedViewModel.upvotePost(useruuid: useruuid, postuuid: cellPost.postuuid) { [weak self] (result) in
         switch result{
         case .success(let voteState, let upvotes):
            cell.updateVoteUI(vote: voteState, upvotes: upvotes)
         case .failure(let error):
            self?.presentCustomAlertOnMainThread(title: "Upvote error", message: error.localizedDescription)            
         }
      }
   }
   
   func downvote(cell: FeedTableViewCell){
      guard let cellPost = cell.post, let useruuid = UserService.shared.uid, feedViewModel.currentState != .editing else { return }
      cell.startUpvoteSpinnerIfNeeded()
      feedViewModel.downvotePost(useruuid: useruuid, postuuid: cellPost.postuuid) { [weak self] (result) in
         switch result{
         case .success(let voteState, let upvotes):
            cell.updateVoteUI(vote: voteState, upvotes: upvotes)
         case .failure(let error):
            self?.presentCustomAlertOnMainThread(title: "Upvote error", message: error.localizedDescription)
         }
      }
   }
   
   func getCurrentVoteState(postuuid: String, cell: FeedTableViewCell, tag: Int, indexPath: IndexPath){
      if let (upvoteState, upvoteCount) = feedViewModel.upvoteCount[indexPath]{
         cell.updateVoteUI(vote: upvoteState, upvotes: upvoteCount)
      }else{
         cell.startUpvoteSpinnerIfNeeded()
      }
      feedViewModel.getCurrentVoteState(useruuid: UserService.shared.uid ?? "", postuuid: postuuid) { [weak self] (result) in
         switch result{
         case .success(let voteState, let upvotes):
            self?.feedViewModel.upvoteCount[indexPath] = (voteState, upvotes)
            if cell.tag != tag { return }
            cell.updateVoteUI(vote: voteState, upvotes: upvotes)
         case .failure(_):
            break
         }
      }
   }
   
   func updateCommentFor(post: PostDataModel, newComment: String){
      feedViewModel.update(post: post, newComment: newComment)
   }
   
    func _updateDisplay(_ cell: FeedTableViewCell, tableView: UITableView, isProfile: Bool = false) {
        if let indexPath = tableView.indexPath(for: cell){
            var isBeingDisplayedFully = true
            if let _ = feedViewModel.fullyDisplayedPosts[indexPath]{
                isBeingDisplayedFully = false
                cell.setInitialDisplay(fully: false)
                cell.summaryTextView.setNeedsUpdateConstraints()
                feedViewModel.fullyDisplayedPosts.removeValue(forKey: indexPath)
            }else{
                cell.setInitialDisplay(fully: true)
                cell.summaryTextView.setNeedsUpdateConstraints()
                feedViewModel.fullyDisplayedPosts[indexPath] = true
            }
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
            if #available(iOS 13, *){
                tableView.scrollToRow(at: indexPath, at: .top , animated: true)
            }else{
                if !isBeingDisplayedFully && feedViewModel.filteredPosts.count == 1{
                    tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }else{
                    UIView.animate(withDuration: 0.25, animations: {
                        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    }) { (_) in }
                }
            }
                
                
//                let s = tableView.rectForRow(at: indexPath)
//                print("minY: \(s.minY)")
//                //        tableView.reloadData()
//                UIView.performWithoutAnimation {
//                    tableView.reloadRows(at: [indexPath], with: .none)
//                }
//                //        tableView.reloadRows(at: [indexPath], with: .none)
//                //                tableView.layoutIfNeeded()
//                let b = tableView.rectForRow(at: indexPath)
//                print("b: \(b.minY)")
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
//                    if let filteredPosts = self?.feedViewModel.filteredPosts{
//                        if filteredPosts.count > 2 && filteredPosts.count - 1 != indexPath.row{
//                            tableView.setContentOffset(CGPoint(x: 0, y: b.minY), animated: true)
//                        }else{
//                            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//                        }
//                    }
//                }
//                print("MinY: \(tableView.rectForRow(at: indexPath).minY)")
//                if !isProfile{
//                    tableView.scrollToRow(at: indexPath, at: .top , animated: true)
//                    print("After: \(tableView.contentOffset.y)")
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//                        print("Inside: \(tableView.contentOffset.y)")
////                        tableView.scrollToRow(at: indexPath, at: .top , animated: true)
////                         print("After after: \(tableView.contentOffset)")
//                    }
//                }else if tableView.contentOffset != CGPoint(x: 0, y: 0){
//                    tableView.scrollToRow(at: indexPath, at: .top , animated: true)
//                }else{
//                    tableView.scrollToRow(at: indexPath, at: .middle , animated: true)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        tableView.scrollToRow(at: indexPath, at: .top , animated: true)
////                        tableView.scrollToRow(at: indexPath, at: .top , animated: animatedScroll)
////                        let b = tableView.rectForRow(at: indexPath)
////                        tableView.setContentOffset(CGPoint(x: 0, y: b.minY), animated: true)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
////                            tableView.scrollToRow(at: indexPath, at: .top , animated: animatedScroll)
//                        }
////                        tableView.scrollToRow(at: indexPath, at: .top , animated: animatedScroll)
//                    }
////                    let b = tableView.rectForRow(at: indexPath)
////                    tableView.setContentOffset(CGPoint(x: 0, y: b.minY), animated: true)
//                }
////                let b = tableView.rectForRow(at: indexPath)
////                tableView.setContentOffset(CGPoint(x: 0, y: b.minY), animated: true)
//            }
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
//            tableView.beginUpdates()
//            tableView.endUpdates()
            
//            if #available(iOS 13, *) {
//
//                let offset = tableView.contentOffset
//                //        DispatchQueue.main.async{
//                CATransaction.begin()
//                CATransaction.setCompletionBlock({
//                    if offset == tableView.contentOffset{
//                        DispatchQueue.main.async {
//                            //                        tableView.setContentOffset(CGPoint(x: 0, y: s.minY), animated: true)
//                            tableView.scrollToRow(at: indexPath, at: .top , animated: animatedScroll)
//                        }
//                    }
//                })
//                UIView.performWithoutAnimation {
//                    tableView.reloadRows(at: [indexPath], with: .none)
//                    //                    tableView.reloadData()
//                }
//                //            tableView.reloadData()
//                CATransaction.commit()
//                //                        }
//            }else{
//
//
//                let s = tableView.rectForRow(at: indexPath)
//                print("minY: \(s.minY)")
//                //        tableView.reloadData()
//                UIView.performWithoutAnimation {
//                    tableView.reloadRows(at: [indexPath], with: .none)
//                }
//                //        tableView.reloadRows(at: [indexPath], with: .none)
//                //                tableView.layoutIfNeeded()
//                let b = tableView.rectForRow(at: indexPath)
//                print("b: \(b.minY)")
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
//                    if let filteredPosts = self?.feedViewModel.filteredPosts{
//                        if filteredPosts.count > 2 && filteredPosts.count - 1 != indexPath.row{
//                            tableView.setContentOffset(CGPoint(x: 0, y: b.minY), animated: true)
//                        }else{
//                            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//                        }
//                    }
//                }
//            }
        }
    }
}
