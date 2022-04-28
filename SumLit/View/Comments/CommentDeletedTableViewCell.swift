//
//  CommentDeletedTableViewCell.swift
//  SumLit
//
//  Created by Junior Etrata on 1/10/20.
//  Copyright © 2020 Sumlit. All rights reserved.
//

import UIKit

private struct CommentDeletedConstants {
    static let iphoneReplyTitleLeftInset : CGFloat = 25
    static let ipadReplyTitleLeftInset : CGFloat = 25
}

class CommentDeletedTableViewCell: UITableViewCell {

    static let identifer = "CommentDeletedTableViewCell"

    // MARK:- Outlets
    
    @IBOutlet private weak var messageButton: UIButton!
    @IBOutlet private weak var createdAtLabel: UILabel!
    @IBOutlet private weak var leadingSeparatorView: UIView!
    
    // MARK:- View lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageButton.titleEdgeInsets = .zero
        leadingSeparatorView.isHidden = true
    }
}

// MARK:- Public API

extension CommentDeletedTableViewCell{
    func configure(indented: Bool, createdAt: Date){
        messageButton.titleLabel?.numberOfLines = 1
        messageButton.titleLabel?.adjustsFontSizeToFitWidth = true
        createdAtLabel.text = createdAt.shortenCalenderTimeSinceNow()
        if indented{
            let isIphone = UIDevice.current.userInterfaceIdiom == .phone
            messageButton.titleEdgeInsets = .init(top: 0, left: isIphone ? CommentDeletedConstants.iphoneReplyTitleLeftInset : CommentDeletedConstants.ipadReplyTitleLeftInset, bottom: 0, right: 0)
            leadingSeparatorView.isHidden = false
        }
    }
}
