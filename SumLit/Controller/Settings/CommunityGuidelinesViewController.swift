//
//  ViewRulesViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 9/25/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class CommunityGuidelinesViewController: UIViewController {
   
   @IBOutlet weak var communityGuidelinesView: CommunityGuidelinesView!
   private struct CustomFonts{
      static let largeBold = UIFont(name: SLFonts.boldFontName, size: 19)!
      static let bold = UIFont(name: SLFonts.boldFontName, size: 17)!
      static let regular = UIFont(name: SLFonts.regularFontName, size: 17)!
      static let largeBoldiPad = UIFont(name: SLFonts.boldFontName, size: 23)!
      static let boldiPad = UIFont(name: SLFonts.boldFontName, size: 21)!
      static let regulariPad = UIFont(name: SLFonts.regularFontName, size: 21)!
   }

   //MARK:- VIEW LIFECYCLE
   override func viewDidLoad() {
      super.viewDidLoad()
      communityGuidelinesView.setTextView(text: createRuleText())
   }
   
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      communityGuidelinesView.scrollTextViewToTop()
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      setupInitialView()
   }
   
   override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      setupWhenViewDisappears()
   }
}

//MARK:- SETUP
extension CommunityGuidelinesViewController{
   
   func setupInitialView(){
      navigationItem.title = "Community guidelines"
   }
   
   func setupWhenViewDisappears(){
      navigationItem.title = ""
   }
}

//MARK:- Create Rule Text
extension CommunityGuidelinesViewController{
   func createRuleText() -> NSMutableAttributedString{
      let ruleText = NSMutableAttributedString()
      var (largeBold, bold, regular) = (CustomFonts.largeBold, CustomFonts.bold, CustomFonts.regular)
      if UIDevice.current.userInterfaceIdiom == .pad{
         (largeBold, bold, regular) = (CustomFonts.largeBoldiPad, CustomFonts.boldiPad, CustomFonts.regulariPad)
      }
    
    var textColor : UIColor!
    
    if #available(iOS 13, *){
        textColor = UIColor.label
    }else{
        textColor = .black
    }
    ruleText.addText("TL;DR\n\n", attributes: [.font: largeBold, NSAttributedString.Key.foregroundColor: textColor!])
    ruleText.addText("We want Sumlit to be a place to read breaking news or interesting articles and share it with the community. Respect everyone on Sumlit, so don't spam or harass other users. Period.\n\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
    ruleText.addText("Rules\n\n", attributes: [.font: largeBold, NSAttributedString.Key.foregroundColor: textColor!])
    ruleText.addText("\t1. ", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!]).addText("Violence", attributes: [.font: bold, NSAttributedString.Key.foregroundColor: textColor!]).addText(": You may not threaten violence against an individual or a group of people. We also prohibit the glorification of violence.\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
    ruleText.addText("\t2. ", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!]).addText("Abuse and Harassment", attributes: [.font: bold, NSAttributedString.Key.foregroundColor: textColor!]).addText(": Harassment of any kind is prohibited. This includes wishing physical harm on somebody.\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
    ruleText.addText("\t3. ", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!]).addText("Fake news/Online manipulation", attributes: [.font: bold, NSAttributedString.Key.foregroundColor: textColor!]).addText(": You may not use Sumlit to summarize and spread fake or otherwise malicious content. We reserve the right to remove content that we deem to be inappropriate.\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
    ruleText.addText("\t4. ", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!]).addText("Spam", attributes: [.font: bold, NSAttributedString.Key.foregroundColor: textColor!]).addText(": No spam. Seriously. Repeated offenses will cause your account to be banned.\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
    ruleText.addText("\t5. ", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!]).addText("Impersonation", attributes: [.font: bold, NSAttributedString.Key.foregroundColor: textColor!]).addText(": You may not use Sumlit to pose as an individual or organization for the purposes of confusion, disruption, or deceit.\n\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
      
    ruleText.addText("Appeals\n\n", attributes: [.font: largeBold, NSAttributedString.Key.foregroundColor: textColor!])
    ruleText.addText("We will do everything in our power to ensure that our moderation of Sumlit will be fair, swift, and accountable. We aren't perfect of course, and if you feel that our judgement call is unfair, you can send an appeal by emailing us at: sumlitmodteam@gmail.com\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
      
      return ruleText
   }
}
