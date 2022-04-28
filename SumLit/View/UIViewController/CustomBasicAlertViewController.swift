//
//  CustomBasicAlertViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 1/19/20.
//  Copyright © 2020 Sumlit. All rights reserved.
//

import UIKit

class CustomBasicAlertViewController: UIViewController {
    
    let containerView = UIView()
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    let actionButton = AnimatedButton()
    
    var alertTitle: String?
    var message: String?
    var buttonTitle: String?
    var completion: (() -> ())?
    var defaultFont: Bool = true
    
    let padding: CGFloat = 20
    
    init(title: String?, message: String?, defaultFont: Bool = true, buttonTitle: String?, completion: (() -> ())? = nil){
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.completion = completion
        self.defaultFont = defaultFont
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.8)
        configureContainerView()
        configureTitleLabel()
        configureActionButton()
        configureMessageLabel()
    }
}

// MARK:- View Configuration

private extension CustomBasicAlertViewController{
    
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
        titleLabel.text = alertTitle ?? "Something went wrong"
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
        messageLabel.text = message ?? "Unable to complete request"
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.font = defaultFont ? UIFont(name: "Lato-Regular", size: 16)! : UIFont.systemFont(ofSize: 16)
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
            messageLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -12)
        ])
    }
    
    func configureActionButton(){
        containerView.addSubview(actionButton)
        actionButton.backgroundColor = Constants.Colors.orangeColor
        actionButton.layer.cornerRadius = 5
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle(buttonTitle ?? "Okay", for: .normal)
        actionButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        actionButton.transformScale = 0.97
        
        NSLayoutConstraint.activate([
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            actionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

// MARK:- Button actions

private extension CustomBasicAlertViewController{
    @objc func dismissViewController(){
        completion?()
        dismiss(animated: true, completion: nil)
    }
}
