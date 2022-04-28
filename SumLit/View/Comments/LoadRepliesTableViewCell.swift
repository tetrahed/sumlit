//
//  LoadRepliesTableViewCell.swift
//  SumLit
//
//  Created by Junior Etrata on 1/3/20.
//  Copyright © 2020 Sumlit. All rights reserved.
//

import UIKit

protocol LoadRepliesProtocol : class {
    func startGettingReplies(cell: LoadRepliesTableViewCell)
}

class LoadRepliesTableViewCell: UITableViewCell {
    
    static let storyboardIdentifier = "LoadRepliesTableViewCell"
    
    weak var loadRepliesDelegate : LoadRepliesProtocol?

    // MARK:- Outlets
    
    @IBOutlet private weak var loadRepliesStackView: UIStackView!
    @IBOutlet private weak var activityIndicatorStackView: UIStackView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var loadRepliesButton: UIButton!
    @IBOutlet private weak var loadRepliesLabel: UILabel!
    @IBOutlet private weak var loadRepliesImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 13, *){} else{
            loadRepliesImageView.image = UIImage(named: "LoadMoreDownArrow")
            if DeviceDetection.isPhone{
                loadRepliesImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadRepliesStackView.isHidden = false
        activityIndicatorStackView.isHidden = true
        loadRepliesButton.isUserInteractionEnabled = true
    }
    
    // MARK:- Button actions
    
    @IBAction private func pressedLoadReplies(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        loadRepliesStackView.isHidden = true
        activityIndicatorStackView.isHidden = false
        activityIndicator.startAnimating()
        loadRepliesDelegate?.startGettingReplies(cell: self)
    }
}

// MARK:- Public API

extension LoadRepliesTableViewCell{
    func shouldRunActivityIndicator(){
        loadRepliesStackView.isHidden = true
        activityIndicatorStackView.isHidden = false
        loadRepliesButton.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }
    
    func configure(loadData : LoadRepliesDataModel){
        loadRepliesLabel.text = "Load \(loadData.replyCount) " + (loadData.replyCount != 1 ? "replies" : "reply")
    }
}
