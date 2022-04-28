//
//  OpenLinkProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 9/19/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import SafariServices

protocol OpenLinkProtocol {
   func openLink(url: String)
}

extension OpenLinkProtocol where Self: UIViewController{
   func openLink(url: String){
      if let url = URL(string: url) {
//         let vc = SFSafariViewController(url: url)
//         vc.configuration.entersReaderIfAvailable = true
//         present(vc, animated: false, completion: nil)
         UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
   }
}
