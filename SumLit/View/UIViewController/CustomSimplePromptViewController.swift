//
//  CustomSimplePromptViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 1/20/20.
//  Copyright © 2020 Sumlit. All rights reserved.
//

import UIKit

class CustomSimplePromptViewController: UIViewController {
    
    let containerView = UIView()
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    let declineButton = AnimatedButton()
    let acceptButton = AnimatedButton()
    let buttonStackView = UIStackView()
    
    var promptTitle: String
    var message: String
    var acceptButtonColor: UIColor?
    var acceptCompletion: (() -> ())?
    var declineCompletion: (() -> ())?
    
    let padding: CGFloat = 20
    
    init(promptTitle: String, message: String, acceptCompletion: (() -> ())?, declineCompletion: (() -> ())?, acceptButtonColor: UIColor?){
        self.promptTitle = promptTitle
        self.message = message
        self.acceptCompletion = acceptCompletion
        self.declineCompletion = declineCompletion
        self.acceptButtonColor = acceptButtonColor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.8)
        configureContainerView()
        configureTitleLabel()
        configureButtonStackView()
        configureMessageLabel()
    }
}

// MARK:- Configuration

private extension CustomSimplePromptViewController{
    
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
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    func configureTitleLabel(){
        containerView.addSubview(titleLabel)
        titleLabel.font = UIFont(name: "Lato-Bold", size: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = promptTitle
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configureMessageLabel(){
        containerView.addSubview(messageLabel)
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.font = UIFont(name: "Lato-Regular", size: 16)!
        messageLabel.minimumScaleFactor = 0.75
        messageLabel.lineBreakMode = .byWordWrapping
        if #available(iOS 13.0, *) {
            messageLabel.textColor = .secondaryLabel
        } else {
            // Fallback on earlier versions
            messageLabel.textColor = .lightGray
        }
        messageLabel.numberOfLines = 4
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -12)
        ])
    }
    
    func configureButtonStackView(){
        containerView.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 12
        
        acceptButton.backgroundColor = acceptButtonColor ?? UIColor.systemRed//Constants.Colors.orangeCo
        acceptButton.layer.cornerRadius = 5
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.setTitle("Yes", for: .normal)
        acceptButton.addTarget(self, action: #selector(acceptedAction), for: .touchUpInside)
        acceptButton.transformScale = 0.97
        
        declineButton.backgroundColor = UIColor.systemGray
        declineButton.layer.cornerRadius = 5
        declineButton.translatesAutoresizingMaskIntoConstraints = false
        declineButton.setTitle("No", for: .normal)
        declineButton.addTarget(self, action: #selector(declineAction), for: .touchUpInside)
        declineButton.transformScale = 0.97
        
        buttonStackView.addArrangedSubview(acceptButton)
        buttonStackView.addArrangedSubview(declineButton)
        
        NSLayoutConstraint.activate([
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

// MARK:- Button actions

private extension CustomSimplePromptViewController{
    @objc func acceptedAction(){
        acceptCompletion?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func declineAction(){
        declineCompletion?()
        dismiss(animated: true, completion: nil)
    }
}
