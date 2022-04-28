//
//  ShareOptionButton.swift
//  Sumlit Share Extension
//
//  Created by Junior Etrata on 12/3/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit

enum ShareOptionButtonState{
   case highlighted(UIImage?)
   case none(UIImage?)
}

protocol ShareOptionButtonProtocol: class {
   var shareState : ShareOptionButtonState { get set }
}

class ShareOptionButton: UIButton, ShareOptionButtonProtocol {
   var shareState: ShareOptionButtonState = .none(nil){
      didSet{
         switch shareState{
         case .highlighted(let image):
            setImage(image, for: .normal)
            UIView.animate(withDuration: 0.2) { [weak self] in
               self?.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
         case .none(let image):
            setImage(image, for: .normal)
            UIView.animate(withDuration: 0.2) { [weak self] in
               self?.transform = CGAffineTransform(scaleX: 0.85, y: 0.9)
            }
         }
      }
   }
}
