//
//  LvAppDelegate.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let isiOS8 = (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0

extension AppDelegate {
    
    
    func lvApplication(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if isiOS8 {
            var userType = UIUserNotificationType.Badge | UIUserNotificationType.Alert | UIUserNotificationType.Sound
            var uns = UIUserNotificationSettings(forTypes: userType, categories: nil)
            application.registerForRemoteNotifications()
            application.registerUserNotificationSettings(uns)
        } else {
            var remoteType = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound
            application.registerForRemoteNotificationTypes(remoteType)
        }
        return true
    }
    
    func lvApplicationWillResignActive(application: UIApplication) {
        
    }
    
    func lvApplicationDidEnterBackground(application: UIApplication) {
        
    }
    
    func lvApplicationWillEnterForeground(application: UIApplication) {
    }
    
    func lvApplicationDidBecomeActive(application: UIApplication) {
    }
    
    func lvApplicationWillTerminate(application: UIApplication) {
    }

    func lvApplication(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var token = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        println("设备 token 为\(token)")
        var pushSDKManager = PushSDKManager.shareInstance()
        pushSDKManager.registerDeviceToken(token)
        var manager = IMClientManager.shareInstance
    }
    
    func lvApplication(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        var pushSDKManager = PushSDKManager.shareInstance()
        pushSDKManager.registerDeviceToken("")
    }
    
    func lvApplication(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
    }
    
    func lvApplication(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
    }

}
















