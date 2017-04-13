//
//  AppDelegate.swift
//  passcode_test
//
//  Created by Florian Pfeffer on 12.04.17.
//  Copyright © 2017 Florian Pfeffer. All rights reserved.
//

import UIKit
import SAPFoundation
import SAPFiori

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var passcodeHandler: PassCodeHandler!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        passcodeHandler = PassCodeHandler()
        window?.makeKeyAndVisible()
        passcodeHandler.passcodeActionOnResume((self.window?.rootViewController)!)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        passcodeHandler.passcodeActionOnResume((self.window?.rootViewController)!)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}



