//
//  SummaryViewController.swift
//  Sumlit Share Extension
//
//  Created by Junior Etrata on 11/23/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController {

   @IBOutlet weak var summaryTextView: UITextView!
   var summaryText: String?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      summaryTextView.textContainer.lineFragmentPadding = 0
      summaryTextView.textContainerInset = .zero
      summaryTextView.text = summaryText
   }

   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      DispatchQueue.main.async { [weak self] in
         self?.summaryTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
      }
   }
}
