//
//  HighlightWords+UILabel.swift
//  SumLit
//
//  Created by Junior Etrata on 5/16/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

extension UILabel {
   
   func highlightWord(originalText: String, highlightedWord: String, color: UIColor = #colorLiteral(red: 1, green: 0.7521448731, blue: 0, alpha: 1)){
      let style = NSMutableParagraphStyle()
      style.alignment = .left
      let titleText = NSMutableAttributedString(string: originalText)
      let appNameRange = titleText.mutableString.range(of: highlightedWord)
      let fullRange = NSMakeRange(0, titleText.length)
      titleText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
      titleText.addAttributes([NSAttributedString.Key.foregroundColor : color], range: appNameRange)
      self.attributedText = titleText
   }
   
}
