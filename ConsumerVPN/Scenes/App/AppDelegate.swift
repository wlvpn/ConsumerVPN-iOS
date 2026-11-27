//
//  AppDelegate.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/8/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit
import VPNKit
import LocalAuthentication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static func sharedDelegate() -> AppDelegate {
        // This should cause a crash if it isn't correct, hence the force unwrap.
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        ApiManagerHelper.shared.disconnectOnAppTerminate()
    }
    
    func loginWithCode(_ code: String) -> Bool {
        if code.count == 0 {
            return false
        }
        
        guard let username = UserDefaults.standard.string(forKey: "MagicLink_Username"),
              let password = UserDefaults.standard.string(forKey: "MagicLink_Password"),
              let confirmation = UserDefaults.standard.string(forKey: "MagicLink_ConfirmationCode") else {
            return false
        }
        
        if confirmation != code {
            showExpiredTokenMessage()
            return false
        }
        ApiManagerHelper.shared.loginWith(forUsername: username, password: password)
        return true
    }
    
    func showExpiredTokenMessage() {
        
        let alertController = UIAlertController(title: "Expired Link", message: "The link you followed has expired. Please re-enter your email address.", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
            print("You've pressed ok");
        }
        
        alertController.addAction(action1)
        
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        window?.rootViewController?.presentedViewController?.present(alertController, animated: true, completion: nil)
    }
}
