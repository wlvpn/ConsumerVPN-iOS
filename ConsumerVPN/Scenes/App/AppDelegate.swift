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
    
    var window: UIWindow?
    
    var appCoordinator: AppCoordinator!
    var apiManager: VPNAPIManager!
    
    static func sharedDelegate() -> AppDelegate {
        // This should cause a crash if it isn't correct, hence the force unwrap.
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Initialize the APIManager using helper Objc object.
        apiManager = SDKInitializer.initializeAPIManager(
            withBrandName: Theme.brandName,
            configName: Theme.configName,
            apiKey: Theme.apiKey,
            andSuffix: Theme.usernameSuffix
        )
        
        // set the default encryption to 256 if one isn't already set
        if apiManager.vpnConfiguration.hasOption(forKey: kIKEv2Encryption) == false {
            apiManager.vpnConfiguration.setOption(kVPNEncryptionAES256, forKey: kIKEv2Encryption)
        }
        
        appCoordinator = AppCoordinator(apiManager: apiManager)
        
        let dashboardVC = DashboardViewController.build(with: apiManager,
                                                        delegate: appCoordinator)
        let serverListVC = ServerListViewController.build(with: apiManager)
        let settingsVC = SettingsTableViewController.build(with: apiManager)
        let tabBarC = WLVPNTabBarController.build(with: apiManager,
                                                  dashboardVC: dashboardVC,
                                                  serverListVC: serverListVC,
                                                  settingsVC: settingsVC)
        appCoordinator.tabController = tabBarC
        
        // No user object means not signed in, so show login view
        if apiManager.vpnConfiguration.user == nil {
            appCoordinator.beginLoginFlow()
        }
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = tabBarC
        
        self.window = window
        self.window?.makeKeyAndVisible()
        
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
        UserDefaults.standard.set(nil, forKey: Theme.loginErrorKey)
        UserDefaults.standard.synchronize()
        if apiManager.isConnectedToVPN() {
            if let ondemandConfiguration = apiManager.vpnConfiguration.onDemandConfiguration {
                if !ondemandConfiguration.enabled { apiManager.disconnect() }
            } else {
                apiManager.disconnect()
            }
        }
        
        apiManager.cleanup()
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
              let _ = components.path,
              let params = components.queryItems else {
            return false
        }
        
        var code = "";
        for param in params {
            if param.name == "code" {
                code = param.value!
            }
        }
        
        return loginWithCode(code)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        guard
            let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let _ = components.path,
            let code = components.queryItems?[0].name else {
            return false
        }
        
        return loginWithCode(code)
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
        
        apiManager.login(withUsername: username, password: password)
        return true
    }
    
    func showExpiredTokenMessage() {
        
        let alertController = UIAlertController(title: "Expired Link", message: "The link you followed has expired. Please re-enter your email address.", preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
            print("You've pressed ok");
        }
        
        alertController.addAction(action1)
        
        self.window?.rootViewController?.presentedViewController?.present(alertController, animated: true, completion: nil)
    }
}
