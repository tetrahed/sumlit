//
//  ShareOptionsViewController.swift
//  Sumlit Share Extension
//
//  Created by Junior Etrata on 12/3/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit

protocol SelectShareOptionProtocol: class {
    func didSelectShareType(_ type: ShareOptionTypes)
}

private struct ShareButtonImages {
   static let highlighted: [ShareOptionTypes:UIImage] = [ .sumlit: #imageLiteral(resourceName: "SumlitShareIcon"), .email: UIImage(named: "MailHighlighted")!, .message : UIImage(named: "MessageHighlighted")!]
   static let none: [ShareOptionTypes:UIImage] = [.sumlit: #imageLiteral(resourceName: "SumlitShareIconHighlighted"), .email: UIImage(named: "Mail")!, .message: UIImage(named: "Message")!]
}

class ShareOptionsViewController: UIViewController {
    
    static let segueIdentifier = "ShareOptionsSegue"
    
    //MARK:- OUTLETS
    @IBOutlet var shareOptionButtons: [ShareOptionButton]!
    
    private var selectedType : ShareOptionTypes = .sumlit
    weak var shareOptionDelegate : SelectShareOptionProtocol?
    
    //MARK:- VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setShareOptionButtonImages()
    }
}

//MARK:- SETUP
fileprivate extension ShareOptionsViewController{
   
   func setShareOptionButtonImages() {
      DispatchQueue.main.async { [unowned self] in

         for (index, type) in ShareOptionTypes.allCases.enumerated(){
            if type == self.selectedType{
               self.shareOptionButtons[index].shareState = .highlighted(ShareButtonImages.highlighted[type])
            }else{
               self.shareOptionButtons[index].shareState = .none(ShareButtonImages.none[type])
            }
         }
      }
   }
}

//MARK:- BUTTON ACTIONS
extension ShareOptionsViewController{
    
    @IBAction func handleShareOptionButton(_ sender: ShareOptionButton) {
        guard let buttonIndex = shareOptionButtons.firstIndex(of: sender) else { return }
        
        selectedType = ShareOptionTypes.allCases[buttonIndex]
        setShareOptionButtonImages()
        shareOptionDelegate?.didSelectShareType(selectedType)
    }
}
