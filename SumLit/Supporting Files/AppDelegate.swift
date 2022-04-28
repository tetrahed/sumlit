//
//  AppDelegate.swift
//  SumLit
//
//  Created by Junior Etrata on 4/8/19.
//  Copyright © 2019 RobbyApp. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseMessaging
import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    
    var window: UIWindow?
    
    lazy var authReference = Auth.auth()
    lazy var databaseReference = Database.database().reference()
    
    override init() {
        super.init()
        setupFirebase()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        //    clearLaunchScreenCache()
//setupFirebase()
        setupNavigation()
        setupKeyboard()
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        updateUserTokenInDatabase()
        
        
        setupAppGroups()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        window?.endEditing(true)
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate{
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
            //Develop
            Messaging.messaging().setAPNSToken(deviceToken as Data, type: .sandbox)
        #else
            //Production
            Messaging.messaging().setAPNSToken(deviceToken as Data, type: .prod)
        #endif
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

extension AppDelegate : MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
      print("Firebase registration token: \(fcmToken)")

//      let dataDict:[String: String] = ["token": fcmToken]
//      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
//      if let useruuid = authReference.currentUser?.uid{
//        self.databaseReference.child("tokens").child(useruuid).setValue(fcmToken)
//          //Firestore.firestore().collection("tokens").document(useruuid).setData(["token": fcmToken])
//      }
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        if let useruuid = Auth.auth().currentUser?.uid{
            self.databaseReference.child("tokens").child(useruuid).setValue(fcmToken)
        }
    }
}

extension AppDelegate {
    func updateUserTokenInDatabase(){
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                if let useruuid = Auth.auth().currentUser?.uid{
                    self.databaseReference.child("tokens").child(useruuid).setValue(result.token)
//                    Firestore.firestore().collection("tokens").document(useruuid).setData(["token": result.token])
                }
            }
        }
    }
}

// MARK:- Configuration

private extension AppDelegate{
    
    func setupNavigation(){
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        if #available(iOS 13.0, *) {
            UINavigationBar.appearance().tintColor = .label
        } else {
            // Fallback on earlier versions
            UINavigationBar.appearance().tintColor = .black
        }
    }
    
    func setupKeyboard() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = Constants.keyboardConstants.keyboardDistanceFromTextField
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    func setupFirebase(){
        var filePath : String!
        
        #if DEBUG
        filePath = Bundle.main.path(forResource: "GoogleService-Info-Debug", ofType: "plist")
        #else
        filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")
        #endif
        
        let options = FirebaseOptions.init(contentsOfFile: filePath)!
        
        FirebaseApp.configure(options: options)
    }
    
    func setupAppGroups(){
        do {
            try authReference.useUserAccessGroup("group.com.RobbyApp.SumLit")
        } catch {
            print("nope")
            //return completion(.failure(CustomErrors.GeneralErrors.unknownError))
        }
    }
}

// MARK:- Launchscreen

private extension AppDelegate{
    func clearLaunchScreenCache(){
        do{
            try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Library/SplashBoard")
        } catch{
            print("Failed to delete launch screen")
        }
    }
}
