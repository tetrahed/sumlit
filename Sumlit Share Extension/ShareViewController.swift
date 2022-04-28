//
//  ShareViewController.swift
//  Sumlit Share Extension
//
//  Created by Junior Etrata on 11/21/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit
import Firebase

class ShareViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    //MARK:- VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        var filePath : String!
        
        #if DEBUG
            filePath = Bundle.main.path(forResource: "GoogleService-Info-Debug", ofType: "plist")
        #else
            filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        #endif
        
        let options = FirebaseOptions.init(contentsOfFile: filePath)!
        
        if FirebaseApp.app() == nil{
            FirebaseApp.configure(options: options)
        }
        
        setupNavigation()
        
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: 0, y: UIScreen.main.bounds.height)
        transform = transform.scaledBy(x: 0.5, y: 0.5)
        containerView.transform = transform
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
            self.containerView?.transform = CGAffineTransform.identity
        }) { (_) in }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        extensionContext?.cancelRequest(withError: NSError(domain:"", code: .max, userInfo:nil))
    }
    
    func setupNavigation(){
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = true
    }
}
