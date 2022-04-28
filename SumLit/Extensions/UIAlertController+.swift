//
//  UIAlertController+.swift
//  SumLit
//
//  Created by Junior Etrata on 9/30/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

extension UIAlertController
{
   class func create(title: String?, message: String?, alertStyle: UIAlertController.Style) -> UIAlertController
   {
      let _alertStyle : UIAlertController.Style = ( UIDevice.current.userInterfaceIdiom == .pad) ? .alert : alertStyle
      return UIAlertController(title: title, message: message, preferredStyle: _alertStyle);
   }
}
