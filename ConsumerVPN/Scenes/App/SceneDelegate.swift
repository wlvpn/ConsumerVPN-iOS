//
//  SceneDelegate.swift
//  ConsumerVPN
//
//  Created by Irfan Khatik on 25/11/2026.
//  Copyright © 2026 NetProtect. All rights reserved.
//

import UIKit
import VPNKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var appCoordinator: AppCoordinator!
    var apiManager: VPNAPIManager!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Initialize the APIManager using helper Objc object.
        apiManager = ApiManagerHelper.shared.apiManager
        // set the default encryption to 256 if one isn't already set
        ApiManagerHelper.shared.setDefaultEncryption()
        
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
        if !ApiManagerHelper.shared.isUserLogin() {
            appCoordinator.beginLoginFlow()
        }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarC
        self.window = window
        window.makeKeyAndVisible()
        
        // Handle links that launched the app.
        if let activity = connectionOptions.userActivities.first {
            _ = handle(userActivity: activity)
        } else if let url = connectionOptions.urlContexts.first?.url {
            _ = handle(url: url)
        }
    }
    
    // MARK: - Deep links
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        _ = handle(userActivity: userActivity)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = handle(url: url)
    }
    
    private func handle(userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
              let params = components.queryItems else {
            return false
        }
        
        let code = params.first { $0.name == "code" }?.value ?? ""
        return AppDelegate.sharedDelegate().loginWithCode(code)
    }
    
    private func handle(url: URL) -> Bool {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first?.name else {
            return false
        }
        
        return AppDelegate.sharedDelegate().loginWithCode(code)
    }
}
