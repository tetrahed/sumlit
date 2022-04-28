//
//  ReportPostViewController.swift
//  SumLit
//
//  Created by Junior Etrata on 1/20/20.
//  Copyright © 2020 Sumlit. All rights reserved.
//

import UIKit

class ReportPostViewController: UIViewController {
    
    let customInputViewController = CustomInputViewController(promptTitle: "Report post", textFieldPlaceholder: "Reason", textFieldCharacterLimit: nil)
    private var finishedActionHandler: ((String) -> ())
    private var cancelActionHandler: (() -> ())
    
    // MARK:- Initializers
    
    init(finishedActionHandler: @escaping ((String) -> ()), cancelActionHandler: @escaping (() -> ())) {
        self.finishedActionHandler = finishedActionHandler
        self.cancelActionHandler = cancelActionHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8470588235)
        customInputViewController.modalTransitionStyle = .crossDissolve
        customInputViewController.modalPresentationStyle = .overFullScreen
        customInputViewController.customInputDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        present(customInputViewController, animated: true, completion: nil)
    }
}

// MARK:- CustomInputProtocol

extension ReportPostViewController: CustomInputProtocol{
    
    func cancel() {
        cancelActionHandler()
        view.backgroundColor = .clear
        dismiss(animated: false, completion: nil)
    }
    
    func finishedAction(text: String) {
        finishedActionHandler(text)
    }
}
