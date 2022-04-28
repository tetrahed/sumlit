//
//  CustomInputViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 1/20/20.
//  Copyright © 2020 Sumlit. All rights reserved.
//

import UIKit

protocol CustomInputProtocol: class {
    func cancel()
    func finishedAction(text: String)
}

class CustomInputViewController: UIViewController {
    
    // Views
    private let containerView = UIView()
    let textField = UITextField()
    private var messageLabel : UILabel!
    private let buttonStackView = UIStackView()
    private var activityIndicator: UIActivityIndicatorView!
    private let mainStack = UIStackView()
    
    //properties
    private var promptTitle: String
    private var textFieldPlaceholder: String?
    private var textFieldCharacterLimit: Int?
    private var canEditTextField : Bool = true
    weak var customInputDelegate : CustomInputProtocol?
    
    //Constants
    private let padding: CGFloat = 20
    
    // MARK:- Initializers
    
    init(promptTitle: String, textFieldPlaceholder: String?, textFieldCharacterLimit: Int?){
        self.promptTitle = promptTitle
        self.textFieldPlaceholder = textFieldPlaceholder
        self.textFieldCharacterLimit = textFieldCharacterLimit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        configureContainerView()
        configureStackViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
}

// MARK:- Configuration

private extension CustomInputViewController{
    func configureContainerView(){
        view.addSubview(containerView)
        if #available(iOS 13.0, *) {
            containerView.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            containerView.backgroundColor = .white
        }
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
        ])
    }
    
    func configureStackViews(){
        mainStack.axis = .vertical
        mainStack.spacing = 24
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(mainStack)
        
        let titleLabel = configureTitleLabel()
        mainStack.addArrangedSubview(titleLabel)
        
        configureTextField()
        mainStack.addArrangedSubview(textField)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        mainStack.addArrangedSubview(buttonStackView)
        
        let doneButton = configureButton(buttonTitle: "Done", buttonColor: Constants.Colors.orangeColor)
        doneButton.addTarget(self, action: #selector(finishedAction), for: .touchUpInside)
        
        let cancelButton = configureButton(buttonTitle: "Cancel", buttonColor: UIColor.systemGray)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        buttonStackView.addArrangedSubview(doneButton)
        buttonStackView.addArrangedSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 28),
            textField.heightAnchor.constraint(equalToConstant: 44),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configureTitleLabel() -> UILabel{
        let label = UILabel()
        label.font = UIFont(name: "Lato-Bold", size: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = promptTitle
        return label
    }
    
    func configureMessageLabel() -> UILabel{
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 4
        label.font = UIFont(name: "Lato-Regular", size: 17)
        return label
    }
    
    func configureTextField(){
        textField.delegate = self
        textField.placeholder = textFieldPlaceholder
        textField.font = UIFont(name: "Lato-Regular", size: 17)
        textField.minimumFontSize = 14
        textField.backgroundColor = UIColor.init(named: "SLPostOpinion")!
        textField.layer.cornerRadius = 5
        textField.translatesAutoresizingMaskIntoConstraints = false
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 5, height: 1))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.tintColor = Constants.Colors.orangeColor
        textField.clearButtonMode = .whileEditing
    }
    
    func configureButton(buttonTitle: String, buttonColor: UIColor) -> AnimatedButton{
        let button = AnimatedButton()
        button.backgroundColor = buttonColor
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(buttonTitle, for: .normal)
        button.transformScale = 0.97
        return button
    }
    
    func configureActivityIndicator() -> UIActivityIndicatorView{
        if #available(iOS 13.0, *) {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.color = UIColor.label
            return indicator
        } else {
            // Fallback on earlier versions
            let indicator = UIActivityIndicatorView(style: .white)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            if #available(iOS 13.0, *) {
                indicator.color = UIColor.label
            } else {
                indicator.color = UIColor.black
                // Fallback on earlier versions
            }
            return indicator
        }
    }
}

// MARK:- Button actions

private extension CustomInputViewController{
    
    @objc func finishedAction(){
        textField.resignFirstResponder()
        canEditTextField = false
        customInputDelegate?.finishedAction(text: textField.text ?? "")
    }
    
    @objc func cancelAction(){
        dismiss(animated: true, completion: nil)
        customInputDelegate?.cancel()
    }
}

// MARK:- UITextfieldDelegate

extension CustomInputViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let limit = textFieldCharacterLimit {
            guard let preText = textField.text as NSString?,
                preText.replacingCharacters(in: range, with: string).count <= limit else {
                    return false
            }
        }
        
        return canEditTextField
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        removeMessage()
        return canEditTextField
    }
}

// MARK:- Public api

extension CustomInputViewController{
    func setMessage(_ message: String?, messageColor: UIColor){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.removeActivityIndicator()
            if self.messageLabel == nil{
                self.messageLabel = self.configureMessageLabel()
                self.messageLabel.textColor = messageColor
                self.mainStack.insertArrangedSubview(self.messageLabel, at: 2)
            }
            
            self.messageLabel.text = message
        }
    }
    
    func setSuccessMessage(_ message: String?){
        DispatchQueue.main.async{ [weak self] in
            guard let self = self else { return }
            if self.activityIndicator != nil{
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.mainStack.removeArrangedSubview(self.activityIndicator)
                    self.activityIndicator.removeFromSuperview()
                }
            }
            
            if self.messageLabel == nil{
                self.messageLabel = self.configureMessageLabel()
                self.messageLabel.textColor = Constants.Colors.orangeColor
                self.mainStack.insertArrangedSubview(self.messageLabel, at: 2)
            }
            
            self.messageLabel.font = UIFont(name: "Lato-Bold", size: 18)
            
            self.messageLabel.text = message
        }
    }
    
    func addActivityIndicator(){
        activityIndicator = configureActivityIndicator()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.buttonStackView.isHidden = true
            self.mainStack.addArrangedSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
        }
    }
    
    func removeActivityIndicator(){
        if activityIndicator != nil{
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.mainStack.removeArrangedSubview(self.activityIndicator)
                self.activityIndicator.removeFromSuperview()
                self.buttonStackView.isHidden = false
            }
        }
        canEditTextField = true
    }
    
    func removeMessage(){
        guard messageLabel != nil else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mainStack.removeArrangedSubview(self.messageLabel)
            self.messageLabel.removeFromSuperview()
            self.messageLabel = nil
        }
    }
}
