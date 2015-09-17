//
//  AppDelegate.swift
//  PicQurate
//
//  Created by SongXujie on 17/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var notificationSelector : Selector = "registerUserNotificationSettings:"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions);
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true);
        let type = FBSDKLoginButton.self;
        
        PQ.initialize(launchOptions);
        
        if application.respondsToSelector(notificationSelector) {
            // iOS 8 Notifications
            let types: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            application.registerUserNotificationSettings(settings);
            application.registerForRemoteNotifications();
        } else {
            // iOS < 8 Notifications
            let types: UIRemoteNotificationType = [UIRemoteNotificationType.Badge, UIRemoteNotificationType.Sound, UIRemoteNotificationType.Alert]
            application.registerForRemoteNotificationTypes(types);
        }
        
        // Extract the notification data
        if let notificatinoPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject: AnyObject] {
            if let userId = notificatinoPayload["userId"] as? String{
                let storyboard = UIStoryboard(name: "Main", bundle: nil);
                let VC = storyboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController;
                let user = PQUser(userId: userId);
                user.fetchInBackgroundWithBlock({ (downloadedUser, error) -> Void in
                    if let e = error {
                        PQ.showError(e);
                    } else {
                        VC.user = user as PQUser;
                        VC.title = user.profileName;
                    }
                })
            }
        }
        
        
        
        
        UITabBar.appearance().tintColor = PQ.primaryColor;
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //Clear push notification badge
        let num = application.applicationIconBadgeNumber;
        if (num != 0) {
            let currentInstallation = AVInstallation.currentInstallation();
            currentInstallation.badge = 0;
            currentInstallation.saveEventually();
            application.applicationIconBadgeNumber = 0;
        }
        application.cancelAllLocalNotifications();
        
        FBSDKAppEvents.activateApp();
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation);
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        if (PQ.currentUser != nil && PQ.currentUser.email != nil) {
            let installation = AVInstallation.currentInstallation();
            installation.setDeviceTokenFromData(deviceToken);
            installation.setObject(PQ.currentUser.objectId, forKey: "userId");
            installation.saveInBackgroundWithBlock({ (success, error) -> Void in
                if (success) {
                    PQ.currentUser.setInstallation(installation);
                    PQ.currentUser.saveInBackground();
                } else {
                    PQ.showError(error);
                }
            });
        }
    }


}

