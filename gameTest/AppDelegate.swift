//
//  AppDelegate.swift
//  gameTest
//
//  Created by Aigo on 16/3/25.
//  Copyright © 2016年 Aigo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        print("ResignActive")
    }

    func applicationDidEnterBackground(application: UIApplication) {
        print("EnterBackground")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        print("EnterForeground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        print("BecomeActive")
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

