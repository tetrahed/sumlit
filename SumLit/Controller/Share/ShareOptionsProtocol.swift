//
//  ShareOptionsProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 12/8/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import MessageUI

protocol ShareOptionsProtocol {
    func shareThroughEmail(url: String?, title: String?, summary: String?, comment: String?)
    func shareThroughMessage(url: String?, title: String?, summary: String?, comment: String?)
}

extension ShareOptionsProtocol where Self: UIViewController, Self: MFMailComposeViewControllerDelegate, Self: MFMessageComposeViewControllerDelegate {
    func shareThroughEmail(url: String?, title: String?, summary: String?, comment: String?){
        if !MFMailComposeViewController.canSendMail(){
            return presentCustomAlertOnMainThread(title: "Error", message: "Currently not signed in in your Mail app. Please sign in so you can share through email.")
        }
        
        guard let url = url, let title = title, let summary = summary else { return }
        var commentText = ""
        if comment != nil, !comment!.isEmpty{
            commentText = "</br></br>Comment from sender: \(comment!)"
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self

        composeVC.setSubject(title)
        composeVC.setMessageBody("\(url)</br></br>\(setupSummary(summary, newLineCharacter: "</br>"))\(commentText)</br></br>Post created and shared using Sumlit", isHTML: true)
        
        present(composeVC, animated: true, completion: nil)
    }
    
    func shareThroughMessage(url: String?, title: String?, summary: String?, comment: String?){
        if !MFMessageComposeViewController.canSendText() {
            return presentCustomAlertOnMainThread(title: "Error", message: "SMS services are not available.")
        }
        
        guard let url = url, let title = title, let summary = summary else { return }
        
        var commentText = ""
        if comment != nil, !comment!.isEmpty{
            commentText = "\n\nComment from sender: \(comment!)"
        }
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        composeVC.body = "\(title)\n\n\(url)\n\n\(summary)"
        composeVC.body = composeVC.body! + (commentText)
        composeVC.body = composeVC.body! + "\n\nPost created and shared using Sumlit"
        
        present(composeVC, animated: true, completion: nil)
    }
    
    private func setupSummary(_ text: String, newLineCharacter: String) -> String{
       let split = text.splitSentence()
       var newText = ""
       for sentence in split{
          newText += "\u{2022} \(sentence)\(newLineCharacter)\(newLineCharacter)"
       }
       return newText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

protocol ShareOptionsViewProtocol{
    func openShareOptionsSheet(with post: PostDataModel)
}

extension ShareOptionsViewProtocol where Self: UIViewController, Self: ShareOptionsProtocol{

    func openShareOptionsSheet(with post: PostDataModel){
        let menuController = UIAlertController.create(title: "Share Options", message: nil, alertStyle: .actionSheet)
        let emailOption = UIAlertAction(title: "Email", style: .default) { [weak self] (_) in
            self?.shareThroughEmail(url: post.link, title: post.title, summary: post.summary, comment: post.comment)
        }
        let mailOption = UIAlertAction(title: "Message", style: .default) { [weak self] (_) in
            self?.shareThroughMessage(url: post.link, title: post.title, summary: post.summary, comment: post.comment)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        menuController.addAction(emailOption)
        menuController.addAction(mailOption)
        menuController.addAction(cancelButton)
        present(menuController, animated: true, completion: nil)
    }
}
