//
//  ConfirmPolicyViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 9/25/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit

class ConfirmPolicyViewController: UIViewController, PolicyProtocol {

   @IBOutlet weak var confirmPolicyView: ConfirmPolicyView!
   
   private struct CustomFonts{
      static let bold = UIFont(name: SLFonts.boldFontName, size: 19)!
      static let regular = UIFont(name: SLFonts.regularFontName, size: 19)!
      static let boldiPad = UIFont(name: SLFonts.boldFontName, size: 23)!
      static let regulariPad = UIFont(name: SLFonts.regularFontName, size: 23)!
   }
   
   //MARK:- VIEW LIFECYCLE
   override func viewDidLoad() {
      super.viewDidLoad()
      setupView()
   }
   
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      confirmPolicyView.scrollTextViewToTop()
   }
   
   //MARK:- BUTTON ACTIONS
   @IBAction func agreeToPolicy(_ sender: UIButton) {
      didAcceptPolicy()
      navigateTo(storyboard: "Auth", identifier: "NavigationController")
   }
}

//MARK:- SETUP
extension ConfirmPolicyViewController{
   func setupView(){
      createEULAText()
   }
   
   func createEULAText(){
      let EULAText = NSMutableAttributedString()
      var (regular, bold) = (CustomFonts.regular, CustomFonts.bold)
      if UIDevice.current.userInterfaceIdiom == .pad{
         regular = CustomFonts.regulariPad
         bold = CustomFonts.boldiPad
      }
    
    var textColor : UIColor!
    if #available(iOS 13, *){
        textColor = UIColor.label
    }else{
        textColor = .black
    }
    EULAText.addText("Sumlit\nCopyright (c) 2019 Junior Etrata and Robert Chung\n\n*** END USER LICENSE AGREEMENT ***\n\nIMPORTANT: PLEASE READ THIS LICENSE CAREFULLY BEFORE USING THIS SOFTWARE.\n\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
    EULAText.addText("Sumlit is an app that will not tolerate objectionable content or abusive users. Abusive users will be deleted from the application if found to be abusive to users of this platform. Users who post objectionable content will also be banned immediately. By signing up, you would adhere to the following: Content may not be submitted to Sumlit in conjunction with, or alongside any, objectionable content.  Objectionable content includes, but is not limited to: (i) sexually explicit materials; (ii) obscene, defamatory, libelous, slanderous, violent and/or unlawful content or profanity; (iii) content that infringes upon the rights of any third party, including copyright, trademark, privacy, publicity or other personal or proprietary right, or that is deceptive or fraudulent; (iv) content that promotes the use or sale of illegal or regulated substances, tobacco products, ammunition and/or firearms; and (v) gambling, including without limitation, any online casino, sports books, bingo or poker. Sumlit encourages users to report objectionable content to help yours and other's experience when using the application and to alert our administrators of objectionable content in the application.\n\n", attributes: [.font: bold, NSAttributedString.Key.foregroundColor: textColor!])
    EULAText.addText(" 1. LICENSE\n\nBy receiving, opening the file package, and/or using Sumlit (“Software”) containing this software, you agree that this End User User License Agreement(EULA) is a legally binding and valid contract and agree to be bound by it. You agree to abide by the intellectual property laws and all of the terms and conditions of this Agreement.\n\nUnless you have a different license agreement signed by Junior Etrata and Robert Chung, your use of Sumlit indicates your acceptance of this license agreement and warranty.\n\nSubject to the terms of this Agreement, Junior Etrata and Robert Chung grants to you a limited, non-exclusive, non-transferable license, without right to sub-license, to use Sumlit in accordance with this Agreement and any other written agreement with Junior Etrata and Robert Chung. Junior Etrata and Robert Chung does not transfer the title of Sumlit to you; the license granted to you is not a sale. This agreement is a binding legal agreement between Junior Etrata and Robert Chung and the purchasers or users of Sumlit.\n\nIf you do not agree to be bound by this agreement, remove Sumlit from your smartphone now.\n\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
    EULAText.addText(" 1. DISTRIBUTION\n\nSumlit and the license herein granted shall not be copied, shared, distributed, re-sold, offered for re-sale, transferred or sub-licensed in whole or in part except that you may make one copy for archive purposes only. For information about redistribution of Sumlit contact Junior Etrata and Robert Chung.\n\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
    EULAText.addText(" 1. USER AGREEMENT\n\n3.1 Use\n\nYour license to use Sumlit is limited to the number of licenses purchased by you. You shall not allow others to use, copy or evaluate copies of Sumlit.\n\n3.2 Use Restrictions\n\nYou shall use Sumlit in compliance with all applicable laws and not for any unlawful purpose. Without limiting the foregoing, use, display or distribution of Sumlit together with material that is pornographic, racist, vulgar, obscene, defamatory, libelous, abusive, promoting hatred, discriminating or displaying prejudice based on religion, ethnic heritage, race, sexual orientation or age is strictly prohibited.\n\nEach licensed copy of Sumlit may be used on one single smartphone location by one user. Use of Sumlit means that you have loaded, installed, or run Sumlit on a computer or similar device. If you install Sumlit onto a multi-user platform, server or network, each and every individual user of Sumlit must be licensed separately.\n\nThe assignment, sublicense, networking, sale, or distribution of copies of Sumlit are strictly forbidden without the prior written consent of Junior Etrata and Robert Chung. It is a violation of this agreement to assign, sell, share, loan, rent, lease, borrow, network or transfer the use of Sumlit. If any person other than yourself uses Sumlit registered in your name, regardless of whether it is at the same time or different times, then this agreement is being violated and you are responsible for that violation!\n\n3.3 Copyright Restriction\n\nThis Software contains copyrighted material, trade secrets and other proprietary material. You shall not, and shall not attempt to, modify, reverse engineer, disassemble or decompile Sumlit. Nor can you create any derivative works or other works that are based upon or derived from Sumlit in whole or in part.\n\nJunior Etrata and Robert Chung’s name, logo and graphics file that represents Sumlit shall not be used in any way to promote products developed with Sumlit . Junior Etrata and Robert Chung retains sole and exclusive ownership of all right, title and interest in and to Sumlit and all Intellectual Property rights relating thereto.\n\nCopyright law and international copyright treaty provisions protect all parts of Sumlit, products and services. No program, code, part, image, audio sample, or text may be copied or used in any way by the user except as intended within the bounds of the single user program. All rights not expressly granted hereunder are reserved for Junior Etrata and Robert Chung.\n\n3.4 Limitation of Responsibility\n\nYou will indemnify, hold harmless, and defend Junior Etrata and Robert Chung , its employees, agents and distributors against any and all claims, proceedings, demand and costs resulting from or in any way connected with your use of Junior Etrata and Robert Chung’s Software.\n\nIn no event (including, without limitation, in the event of negligence) will Junior Etrata and Robert Chung , its employees, agents or distributors be liable for any consequential, incidental, indirect, special or punitive damages whatsoever (including, without limitation, damages for loss of profits, loss of use, business interruption, loss of information or data, or pecuniary loss), in connection with or arising out of or related to this Agreement, Sumlit or the use or inability to use Sumlit or the furnishing, performance or use of any other matters hereunder whether based upon contract, tort or any other theory including negligence.\n\nJunior Etrata and Robert Chung’s entire liability, without exception, is limited to the customers’ reimbursement of the purchase price of the Software (maximum being the lesser of the amount paid by you and the suggested retail price as listed by Junior Etrata and Robert Chung ) in exchange for the return of the product, all copies, registration papers and manuals, and all materials that constitute a transfer of license from the customer back to Junior Etrata and Robert Chung.\n\n3.5 Warranties\n\nExcept as expressly stated in writing, Junior Etrata and Robert Chung makes no representation or warranties in respect of this Software and expressly excludes all other warranties, expressed or implied, oral or written, including, without limitation, any implied warranties of merchantable quality or fitness for a particular purpose.\n\n3.6 Governing Law\n\nThis Agreement shall be governed by the law of the United States applicable therein. You hereby irrevocably attorn and submit to the non-exclusive jurisdiction of the courts of United States therefrom. If any provision shall be considered unlawful, void or otherwise unenforceable, then that provision shall be deemed severable from this License and not affect the validity and enforceability of any other provisions.\n\n3.7 Termination\n\nAny failure to comply with the terms and conditions of this Agreement will result in automatic and immediate termination of this license. Upon termination of this license granted herein for any reason, you agree to immediately cease use of Sumlit. The financial obligations incurred by you shall survive the expiration or termination of this license.\n\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
    EULAText.addText("DISCLAIMER OF WARRANTY\n\nTHIS SOFTWARE AND THE ACCOMPANYING FILES ARE SOLD “AS IS” AND WITHOUT WARRANTIES AS TO PERFORMANCE OR MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED OR IMPLIED. THIS DISCLAIMER CONCERNS ALL FILES GENERATED AND EDITED BY Sumlit AS WELL.\n\n\n", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
    EULAText.addText("CONSENT OF USE OF DATA\n\nYou agree that Junior Etrata and Robert Chung may collect and use information gathered in any manner as part of the product support services provided to you, if any, related to Sumlit. Junior Etrata and Robert Chung may also use this information to provide notices to you which may be of use or interest to you.", attributes: [.font: regular, NSAttributedString.Key.foregroundColor: textColor!])
      confirmPolicyView.setPolicy(text: EULAText)
   }
}
