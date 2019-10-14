//
//  AppDelegate.swift
//  freegan
//
//  Created by Hammed opejin on 1/8/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import SwiftKeychainWrapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    // set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        if let currentUserId = KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID) {
            
            firebase.child(kRECENT).queryOrdered(byChild: kUSERID).queryEqual(toValue: currentUserId).observe(.value, with: {
                snapshot in
                if snapshot.exists() {
                    let sorted = ((snapshot.value as! NSDictionary).allValues as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)])
                    
                    var counter = 0
                    var resultCounter = 0
                    for recent in sorted {
                        
                        let currentRecent = recent as! NSDictionary
                        
                        let tempCount = currentRecent[kCOUNTER] as! Int
                        
                        resultCounter += 1
                        counter += tempCount
                        
                        if (resultCounter == sorted.count) {
                            UIApplication.shared.applicationIconBadgeNumber = counter
                        }
                    }
                }
            })
        }
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        if let currentUserId = KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID) {
            
            firebase.child(kUSER)
                .child(currentUserId)
                .child(kINSTANCEID)
                .setValue(fcmToken)
        }
    }
    
    func application(
        _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }
    
    func application(
        _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let state = UIApplication.shared.applicationState
        if (state != .active) {
            guard let _ = userInfo["aps"] as? [String: AnyObject] else {
                completionHandler(.failed)
                return
            }

            guard let data = userInfo["data"] as? [String: AnyObject] else {
                completionHandler(UIBackgroundFetchResult.newData)
                return
            }

            guard let withUserUserId = data[kSENDERID] as? String, let postId = data[kPOSTID] as? String,
                let chatRoomId = data[kCHATROOMID] as? String else {
                completionHandler(UIBackgroundFetchResult.newData)
                return
            }
            
            if let currentUserId = KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID) {
                
                firebase.child(kUSER).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: currentUserId)
                    .observeSingleEvent(of: .value, with: {
                        snapshot in
                        
                        if snapshot.exists() {
                            
                            let user = FUser.init(_dictionary: ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary)
                            let chatVC = ChatViewController()
                            chatVC.withUserUserId = withUserUserId
                            chatVC.currentUser = user
                            
                            DataService.ds.REF_POSTS.child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
                                if snapshot.exists() {
                                    let post = Post(postId: snapshot.key, postData: snapshot.value as! Dictionary<String, AnyObject>)
                                    chatVC.post = post
                                    chatVC.chatRoomId = chatRoomId
                                    chatVC.hidesBottomBarWhenPushed = true
                                    let bar = self.window?.rootViewController as? UITabBarController
                                    bar?.selectedIndex = 2
                                    let recentVC = bar?.selectedViewController! as! UINavigationController
                                    recentVC.pushViewController(chatVC, animated: true)
                                }
                            })
                        }
                        
                    })
            }

            completionHandler(UIBackgroundFetchResult.newData)
        } else {
            completionHandler(UIBackgroundFetchResult.newData)
        }
    }
    
    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if let viewControllers = window?.rootViewController?.children[2].children {
            for viewController in viewControllers {
                if viewController.isKind(of: ChatViewController.self) {
                    completionHandler([])
                    return
                }
            }
        }
        completionHandler([.alert, .badge, .sound])
    }

}
