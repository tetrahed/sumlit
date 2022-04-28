//
//  UpdateUsernameViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 1/20/20.
//  Copyright © 2020 Sumlit. All rights reserved.
//

import UIKit

class UpdateUsernameViewController: UIViewController {
    
    private let customInputViewController = CustomInputViewController(promptTitle: "Change username", textFieldPlaceholder: "e.g. Bob", textFieldCharacterLimit: Constants.Auth.usernameMax)
    private let usernameService: UsernameService = UsernameService()
    weak var editDelegate : EditUsernameProtocol?

    // MARK:- View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.8)
        customInputViewController.modalTransitionStyle = .crossDissolve
        customInputViewController.modalPresentationStyle = .overFullScreen
        customInputViewController.customInputDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        present(customInputViewController, animated: true, completion: nil)
    }
}

// MARK:- CustomInputProtocol

extension UpdateUsernameViewController : CustomInputProtocol{
    func cancel() {
        view.backgroundColor = .clear
        dismiss(animated: false, completion: nil)
    }
    
    func finishedAction(text: String) {
        let usernameText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let error = validateTextField(text: usernameText){
            customInputViewController.setMessage(error.localizedDescription, messageColor: UIColor.systemRed)
        }else{
            customInputViewController.removeMessage()
            performUsernameChange(newUsername: usernameText)
        }
    }
}

// MARK:- Text

private extension UpdateUsernameViewController {
    func validateTextField(text: String) -> Error?{
        if let forbiddenWord = text.hasForbiddenWord() {
            return CustomErrors.GeneralErrors.forbiddenWords(word: forbiddenWord)
        }
        
        if text.count > Constants.Auth.usernameMax{
            return CustomErrors.AuthValidationErrors.invalidMaxUsername(maxLength: Constants.Auth.usernameMax)
        }
        
        if text.count < Constants.Auth.usernameMin {
            return CustomErrors.AuthValidationErrors.invalidMinUsername(minLength: Constants.Auth.usernameMin)
        }
        
        return nil
    }
}

// MARK:- Network calls

private extension UpdateUsernameViewController{
    func performUsernameChange(newUsername: String){

        customInputViewController.addActivityIndicator()
        
        usernameService.update(username: newUsername) { [weak self] (result) in
            guard let self = self else { return }
            switch result{
            case .success(let newUsername):
                self.customInputViewController.setSuccessMessage("Success!")
                self.editDelegate?.didChangeField(text: newUsername)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.customInputViewController.dismiss(animated: true, completion: {
                        DispatchQueue.main.async{ [weak self] in
                            self?.view.backgroundColor = .clear
                            self?.dismiss(animated: false, completion: nil)
                        }
                    })
                }
            case .failure(let error):
                self.customInputViewController.setMessage(error.localizedDescription, messageColor: UIColor.systemRed)
            }
        }
    }
}
