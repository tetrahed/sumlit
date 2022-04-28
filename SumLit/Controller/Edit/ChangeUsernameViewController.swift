//
//  SmallEditViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 12/6/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol EditUsernameProtocol: class {
    func didChangeField(text: String)
}

class ChangeUsernameViewController: UIViewController {
    
    let editTextField : UITextField = {
       let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .done
        textField.clearButtonMode = .always
        return textField
    }()
    
    let editTextFieldBackground : UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "ChangeUsernameBackground")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let updateUsernameBackground : UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let backgroundView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.alpha = 0.95
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(cancelEdit), for: .touchUpInside)
        return button
    }()
        
    let usernameService: UsernameService
    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    var canEditTextField = true
    weak var editProtocol : EditUsernameProtocol?
    
    init(usernameService : UsernameService = UsernameService(), placeHolder: String?) {
        self.usernameService = usernameService
        self.editTextField.placeholder = placeHolder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editTextField.delegate = self
        
        view.addSubview(backgroundView)
        view.addSubview(editTextFieldBackground)
        view.addSubview(editTextField)
        view.addSubview(cancelButton)
                
        let aspectRatioConstraint = NSLayoutConstraint(item: editTextFieldBackground ,attribute: .height,relatedBy: .equal,toItem: editTextFieldBackground,attribute: .width, multiplier: (62 / 234), constant: 0)
        
        editTextFieldBackground.addConstraint(aspectRatioConstraint)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            editTextFieldBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editTextFieldBackground.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -16),
            editTextFieldBackground.heightAnchor.constraint(equalToConstant: 70),
            
            editTextField.topAnchor.constraint(equalTo: editTextFieldBackground.topAnchor, constant: 8),
            editTextField.leadingAnchor.constraint(equalTo: editTextFieldBackground.leadingAnchor, constant: 16),
            editTextField.trailingAnchor.constraint(equalTo: editTextFieldBackground.trailingAnchor, constant: -8),
            editTextField.bottomAnchor.constraint(equalTo: editTextFieldBackground.bottomAnchor, constant: -16),
            
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
        backgroundView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        editTextFieldBackground.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        editTextField.isHidden = true
        cancelButton.isHidden = true
        
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.backgroundView.transform = CGAffineTransform.identity
        }) { (_) in
        }

        UIView.animate(withDuration: 0.3, delay: 0.1, animations: { [weak self] in
            self?.editTextFieldBackground.transform = CGAffineTransform.identity
        }) { [weak self] (_) in
            self?.editTextField.isHidden = false
            self?.cancelButton.isHidden = false
            self?.editTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
}

//MARK:- UITextFieldDelegate
extension ChangeUsernameViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let preText = textField.text as NSString?,
              preText.replacingCharacters(in: range, with: string).count <= Constants.Auth.usernameMax else {
           return false
        }
        
        return canEditTextField
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return false }
        
        if let error = validateTextField(text: text){
            presentCustomAlertOnMainThread(title: "Error", message: error.localizedDescription)
            return false
        }
        performUsernameChange(newUsername: text)
        canEditTextField = false
        return true
    }
    
    private func validateTextField(text: String) -> Error?{
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

//MARK:- Network Calls
extension ChangeUsernameViewController{
    
    func performUsernameChange(newUsername: String){
        
        editTextField.resignFirstResponder()
        
        view.addSubview(updateUsernameBackground)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            updateUsernameBackground.topAnchor.constraint(equalTo: view.topAnchor),
            updateUsernameBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            updateUsernameBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            updateUsernameBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        
        usernameService.update(username: newUsername) { [weak self] (result) in
            switch result{
            case .success(let newUsername):
                self?.editProtocol?.didChangeField(text: newUsername)
                self?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                self?.presentCustomAlertOnMainThread(title: "Error", message: error.localizedDescription)
//                self?.presentAlertController(title: "Error", message: error.localizedDescription)
                self?.canEditTextField = true
                self?.activityIndicator.removeFromSuperview()
                self?.updateUsernameBackground.removeFromSuperview()
                self?.editTextField.becomeFirstResponder()
            }
        }
    }
}

//MARK:- Button Actions
extension ChangeUsernameViewController{
    @objc func cancelEdit(){
        dismiss(animated: true, completion: nil)
    }
}
