//
//  NSMutableAttributedString+.swift
//  SumLit
//
//  Created by Junior Etrata on 9/26/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
   @discardableResult func addText(_ text: String, attributes: [NSAttributedString.Key:Any]) -> NSMutableAttributedString {
      let attributedString = NSMutableAttributedString(string:text, attributes: attributes)
      append(attributedString)
      return self
   }
}
