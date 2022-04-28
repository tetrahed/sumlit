//
//  TextViewProtocol.swift
//  SumLit
//
//  Created by Junior Etrata on 9/4/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

protocol TextViewProtocol{
   func addButton(originalText: String, buttonText: String, textColor: UIColor, buttonColor: UIColor, fontSize: CGFloat)
   func addPadding(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat)
   func scrollToTop()
}

extension TextViewProtocol where Self: UITextView{

   fileprivate var buttonFont: String {
      return "Lato-Bold"
   }

   fileprivate var regularFont: String {
      return "Lato-Regular"
   }
   
   var defaultFontSize: CGFloat{
      return 18
   }
   
   var ipadFontSize: CGFloat{
      return 23
   }
   
   func addButton(originalText: String, buttonText: String, textColor: UIColor = .black, buttonColor: UIColor = .black, fontSize: CGFloat) {
      
      let style = NSMutableParagraphStyle()
      style.alignment = .left
      let attributedOriginalText = NSMutableAttributedString(string: originalText)
      let linkRange = attributedOriginalText.mutableString.range(of: buttonText)
      let fullRange = NSMakeRange(0, (originalText as NSString).length)
      attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: "link", range: linkRange)
      attributedOriginalText.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: fullRange)
      attributedOriginalText.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: fullRange)
      attributedOriginalText.addAttribute(NSAttributedString.Key.foregroundColor, value: buttonColor, range: linkRange)
      attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: regularFont, size: fontSize)!, range: fullRange)
      attributedOriginalText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: buttonFont, size: fontSize)!, range: linkRange)
      
      self.linkTextAttributes = [
         kCTForegroundColorAttributeName: UIColor.black,
         ] as [NSAttributedString.Key : Any]
      
      self.attributedText = attributedOriginalText
   }
   
   func addPadding(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat){
      self.textContainerInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
   }
   
   func scrollToTop(){
      self.setContentOffset(.zero, animated: false)
   }
}

extension UITextView : TextViewProtocol { }
