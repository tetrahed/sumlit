//
//  HandleErrors+UIViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 5/4/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentCustomAlertOnMainThread(title: String? = nil, message: String? = nil, buttonTitle: String? = nil, completion: (() -> ())? = nil){
        DispatchQueue.main.async {
            let alertController = CustomBasicAlertViewController(title: title, message: message, buttonTitle: buttonTitle, completion: completion)
            alertController.modalPresentationStyle = .overFullScreen
            alertController.modalTransitionStyle = .crossDissolve
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
//    func presentAlertController(title: String, message : String) {
//        let alert = UIAlertController.create(title: title, message: message, alertStyle: .alert)
//        let button = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil)
//        alert.addAction(button)
//        DispatchQueue.main.async { [weak self] in
//            self?.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func presentAlertController(title: String, message : String, completion: @escaping (() -> ())) {
//        let alert = UIAlertController.create(title: title, message: message, alertStyle: .alert)
//        let button = UIAlertAction(title: "Okay", style: .default) { (_) in
//            completion()
//        }
//        alert.addAction(button)
//        DispatchQueue.main.async { [weak self] in
//            self?.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func presentAlertControllerBeforePopping(title: String, message : String) {
//        let alert = UIAlertController.create(title: title, message: message, alertStyle: .alert)
//        let button = UIAlertAction(title: "Okay", style: .default) { [weak self] (_) in
//            self?.navigationController?.popViewController(animated: true)
//        }
//        alert.addAction(button)
//        DispatchQueue.main.async { [weak self] in
//            self?.present(alert, animated: true, completion: nil)
//        }
//    }
    
//    func presentSimplePrompt(title: String?, message: String?, confirm: @escaping (() -> ()), decline: (() -> ())? = nil){
//        let alertController = UIAlertController.create(title: title, message: message, alertStyle: .alert)
//        let yesButton = UIAlertAction(title: "Yes", style: .destructive) { (_) in
//            confirm()
//        }
//        let noButton = UIAlertAction(title: "No", style: .cancel) { (_) in
//            decline?()
//        }
//        alertController.addAction(noButton)
//        alertController.addAction(yesButton)
//        DispatchQueue.main.async { [weak self] in
//            self?.present(alertController, animated: true, completion: nil)
//        }
//    }
    
    func presentCustomPrompt(promptTitle: String, message: String, acceptCompletion: (() -> ())? = nil, declineCompletion: (() -> ())? = nil, acceptButtonColor: UIColor? = nil){
        let promptController = CustomSimplePromptViewController(promptTitle: promptTitle, message: message, acceptCompletion: acceptCompletion, declineCompletion: declineCompletion, acceptButtonColor: acceptButtonColor)
        promptController.modalPresentationStyle = .overFullScreen
        promptController.modalTransitionStyle = .crossDissolve
        DispatchQueue.main.async { [weak self] in
            self?.present(promptController, animated: true, completion: nil)
        }
    }
}
