//
//  AppDelegate.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 11/11/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import GooglePlaces
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "-"
            $0.clientKey = "-"
            $0.server = "-"
        }
        Parse.initialize(with: configuration)
        
        GMSPlacesClient.provideAPIKey("-")
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "APP_ID",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        if UserDefaults.standard.bool(forKey: "logged") {
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homePage = mainStoryboard.instantiateViewController(withIdentifier: "LoadViewController") as! LoadingViewController
            self.window?.rootViewController = homePage
        } else {
            let mainStoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homePage = mainStoryboard.instantiateViewController(withIdentifier: "LoadViewController") as! LoadingViewController
            self.window?.rootViewController = homePage
        }
    
        return true
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
        
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
}

