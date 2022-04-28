//
//  ContainerViewController.swift
//  Sumlit Share Extension
//
//  Created by Junior Etrata on 11/21/19.
//  Copyright © 2019 Sumlit. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

private let mainStackViewSpacingPortrait : CGFloat = 24
private let mainStackViewSpacingLandscape : CGFloat = 10

class ContainerViewController: UIViewController {
    
    @IBOutlet weak var headlineScrollView: UIScrollView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var postBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet var shareOptionStackView: UIStackView!
    @IBOutlet var shareOptionTitleStackView: UIStackView!
    @IBOutlet weak var shareOptionContainerView: UIView!
    @IBOutlet var addCommentStackView: UIStackView!
    @IBOutlet var innerAddCommentStackView: UIStackView!
    
    var articleService : ArticleService!
    var createPostService: CreatePostService!
    var prepost : PrePostDataModel!
    let defaults = UserDefaults(suiteName: "group.com.RobbyApp.SumLit")
    var shareOptionType : ShareOptionTypes = .sumlit
    
    //MARK:- VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirebase()
        setupNavigation()
        
        if articleService == nil { articleService = ArticleService() }
        if prepost == nil { prepost = PrePostDataModel() }
        if createPostService == nil { createPostService = CreatePostService() }
        postBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)], for: .normal)
        postBarButtonItem.hideButton()
        
        if UIDevice.current.userInterfaceIdiom == .pad { summaryTextView.isScrollEnabled = false }
        
        summaryTextView.textContainer.lineFragmentPadding = 0
        summaryTextView.textContainerInset = .zero
        
        summaryTextView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(displaySummaryFully)))
        summaryTextView.isUserInteractionEnabled = false
        
        
        commentLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addComment)))
        
        do {
            try Auth.auth().useUserAccessGroup("group.com.RobbyApp.SumLit")
        } catch {
            DispatchQueue.main.async {
                self.presentAlertAndCompleteRequest(title: "Error", message: "Please try again.")
            }
        }
        
        if let username = defaults?.string(forKey: "username"), let useruuid = defaults?.string(forKey: "useruuid"){
            prepost.username = username
            prepost.useruuid = useruuid
        }else{
            presentAlertAndCompleteRequest(title: "Error", message: "You are not logged in. Please sign in before trying to share.")
        }
        
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = view.center
        self.view.addSubview(indicator)
        self.view.bringSubviewToFront(indicator)
        
        getURL { [weak self] (url) in
            self?.prepost.websiteURL = url
            self?.extractArticleData(completion: { [weak self] (result) in
                
                switch result{
                case .success(let title, let body, let websiteURL):
                    self?.prepost.title = title
                    self?.prepost.summary = self?.performSummarization(text: body)
                    self?.prepost.websiteURL = websiteURL
                    DispatchQueue.main.async {
                        self?.headlineLabel.text = title
                        self?.headlineScrollView.contentSize = CGSize(width: self?.headlineLabel.frame.width ?? 0, height: self?.headlineLabel.frame.height ?? 0)
                        self?.summaryTextView.text = self?.setupSummary(self?.prepost.summary ?? "")
                        self?.summaryTextView.isUserInteractionEnabled = true
                        self?.postBarButtonItem.showButton(color: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
                    }
                case .failure(_):
                    DispatchQueue.main.async { [weak self] in
                        self?.presentAlertAndCompleteRequest(title: "Error", message: "Sorry, we could not summarize this article. We are still improving our summarizer!")
                    }
                }
            })
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard DeviceDetection.isPhone else { return }
        let screen = UIScreen.main.bounds
        
        if screen.width > screen.height{
            mainStackView.spacing = mainStackViewSpacingLandscape
            mainStackView.removeArrangedSubview(shareOptionStackView)
            shareOptionContainerView.isHidden = true
            shareOptionTitleStackView.alpha = 0
            mainStackView.removeArrangedSubview(addCommentStackView)
            addCommentStackView.alpha = 0
            commentLabel.alpha = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        commentLabel.textColor = prepost.comment == nil ? #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        commentLabel.text = prepost.comment ?? "Optional: Add a comment."
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        guard DeviceDetection.isPhone else { return }
        let screen = UIScreen.main.bounds
        if screen.width < screen.height{
            self.mainStackView.spacing = mainStackViewSpacingPortrait
            self.mainStackView.insertArrangedSubview(self.shareOptionStackView, at: 2)
            self.shareOptionContainerView.isHidden = false
            self.shareOptionTitleStackView.alpha = 1
            self.mainStackView.insertArrangedSubview(self.addCommentStackView, at: 3)
            self.commentLabel.alpha = 1
            self.addCommentStackView.alpha = 1
        }else{
            self.mainStackView.spacing = mainStackViewSpacingLandscape
            self.mainStackView.removeArrangedSubview(self.shareOptionStackView)
            self.shareOptionContainerView.isHidden = true
            self.shareOptionTitleStackView.alpha = 0
            self.mainStackView.removeArrangedSubview(self.addCommentStackView)
            self.addCommentStackView.alpha = 0
            self.commentLabel.alpha = 0
        }
    }
}

//MARK:- BUTTON ACTIONS
extension ContainerViewController: ShareOptionsProtocol{
   
   @IBAction func cancelShare(_ sender: UIBarButtonItem) {
    self.extensionContext?.cancelRequest(withError: NSError(domain:"", code: .max, userInfo:nil))
   }
   
    @IBAction func shareArticle(_ sender: UIBarButtonItem) {
        guard let prepost = prepost else { return }
        switch shareOptionType{
        case .sumlit:
            shareToSumlit()
    //  case .twitter:
    //        shareThroughTwitter()
        case .email:
            shareThroughEmail(url: prepost.websiteURL, title: prepost.title, summary: prepost.summary, comment: prepost.comment)
        case .message:
            shareThroughMessage(url: prepost.websiteURL, title: prepost.title, summary: prepost.summary, comment: prepost.comment)
        }
    }
    
    func shareToSumlit(){
        if defaults?.string(forKey: "username") == nil || defaults?.string(forKey: "useruuid") == nil{
           return presentAlertAndCompleteRequest(title: "Error", message: "You are not logged in. Please sign in before trying to share.")
        }
        guard let useruuid = prepost.useruuid, let url = prepost.websiteURL,
           let title = prepost.title, let summary = prepost.summary else {
              return presentAlertAndCompleteRequest(title: "Error", message: CustomErrors.GeneralErrors.unknownError.errorDescription ?? "Unknown error.")
        }
        let spinner = Spinner()
        spinner.start(from: self.view)
        navigationItem.rightBarButtonItem?.hideButton()
        createPostService.savePost(useruuid: useruuid, title: title, summary: summary, comment: prepost.comment ?? "", link: url) { (result) in
           DispatchQueue.main.async { [weak self] in
              spinner.stop()
              switch result{
              case .success(let success):
                 if success{
                    self?.presentAlertAndCompleteRequest(title: "Success!", message: "Your post has been added to our database. Check it out sometime!")
                 }else{
                    self?.presentCustomAlertOnMainThread(title: "Error", message: "Could not save your post. Please try again.")
                 }
              case .failure(let error):
                self?.presentCustomAlertOnMainThread(title: "Error", message: error.localizedDescription)
              }
              self?.navigationItem.rightBarButtonItem?.showButton(color: #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1))
           }
        }
    }
}


extension ContainerViewController: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK:- SETUP
fileprivate extension ContainerViewController{
   
   func getURL(completion : @escaping ((String) -> ())){
      if let item = extensionContext?.inputItems.first as? NSExtensionItem {
         if let itemProvider = item.attachments?.first {
            if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
               itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { [weak self] (url, error) -> Void in
                  if let shareURL = url as? URL {
                     completion(shareURL.absoluteString)
                  }else{
                     self?.presentAlertAndCompleteRequest(title: "Error", message: CustomErrors.ArticleParserError.brokenLink.errorDescription ?? "Unknown Error")
                  }
               })
            }
         }
      }
   }
   
   func extractArticleData(completion: @escaping ArticleService.ArticleHandler){
      guard let websiteURL = prepost?.websiteURL else {
         return presentAlertAndCompleteRequest(title: "Error", message: CustomErrors.GeneralErrors.unknownError.errorDescription ?? "Unknown Error")
      }
      articleService.extractDataWithValidURL(websiteURL) { (result) in
         completion(result)
      }
   }
   
   func setupSummary(_ text: String) -> String{
      let split = text.splitSentence()
      var newText = ""
      for sentence in split{
         newText += "\u{2022} \(sentence)\n\n"
      }
      return newText.trimmingCharacters(in: .whitespacesAndNewlines)
   }
   
    func presentAlertAndCompleteRequest(title: String, message: String){
        presentCustomAlertOnMainThread(title: title, message: message) {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
                self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
                }, completion: { (_) in
                    self.extensionContext?.cancelRequest(withError: NSError(domain:"", code: .max, userInfo:nil))
            })
        }
    }
}

//MARK:- Summarization
fileprivate extension ContainerViewController{
   
   func performSummarization(text: String) -> String {
      let summary = Summary()
      return summary.getSummary(text: text, numberOfSentences: getNumberOfSentences(text: text))
   }
   
   func getNumberOfSentences(text: String) -> Int {
      let numberOfWords = getNumberOfWords(text: text)
      if numberOfWords <= 700 {
         return 3
      }
      else if numberOfWords > 700 && numberOfWords <= 1100 {
         return 4
      }
      else {
         return 5
      }
   }
   
   func getNumberOfWords(text: String) -> Int
   {
      let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
      let components = text.components(separatedBy: chararacterSet)
      let words = components.filter { !$0.isEmpty }
      
      return words.count
   }
}

//MARK:- NAVIGATION
fileprivate extension ContainerViewController{
   
   @objc func displaySummaryFully(){
      guard let vc = UIStoryboard.init(name: "Summary", bundle: Bundle.main).instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController else {
         return
      }
      vc.summaryText = summaryTextView.text
      navigationController?.pushViewController(vc, animated: true)
   }
   
   @objc func addComment(){
      guard let vc = UIStoryboard.init(name: "AddComment", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddCommentViewController") as? AddCommentViewController else {
         return
      }
      vc.initialComment = prepost.comment
      vc.addCommentDelegate = self
      navigationController?.pushViewController(vc, animated: true)
   }
}

//MARK:- SEGUE
extension ContainerViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case ShareOptionsViewController.segueIdentifier:
            let destination = segue.destination as? ShareOptionsViewController
            destination?.shareOptionDelegate = self
        default:
            break
        }
    }
}

//MARK:- AddCommentDelegate
extension ContainerViewController: AddCommentProtocol{
   
   func addNewComment(_ comment: String?) {
      prepost.comment = comment
   }
}

//MARK:- ShareOptionDelegate
extension ContainerViewController: SelectShareOptionProtocol{
    
    func didSelectShareType(_ type: ShareOptionTypes) {
        shareOptionType = type
    }
}

// MARK:- Configuration
private extension ContainerViewController{
    func setupFirebase(){
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
    }
    
    func setupNavigation(){
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = true
    }
}
