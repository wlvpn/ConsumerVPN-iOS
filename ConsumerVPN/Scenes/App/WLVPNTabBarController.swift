//
//  MainTabBarController.swift
//  Consumer VPN
//
//  Created by WLVPN on 2/12/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

class WLVPNTabBarController: UITabBarController {
    
    var apiManager: VPNAPIManager! {
        didSet {
            vpnConfiguration = apiManager.vpnConfiguration
        }
    }
    
    var vpnConfiguration: VPNConfiguration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = .tabBarItemActiveTint
        tabBar.unselectedItemTintColor = .tabBarItemInactiveTint
        tabBar.barTintColor = .tabBarBg
        
        // To ensure tab bar items load properly (including active tint color for
        // the selected tab), the tab bar items are configured here rather than
        // within each view controller class.
        
        let dashboardVC = DashboardViewController.build(with: apiManager)
        dashboardVC.tabBarItem = UITabBarItem(title: "Dashboard",
                                              image: UIImage(named: Theme.dashboardTabBarIcon),
                                              tag: 0)
        
        let serverListVC = ServerListViewController.build(with: apiManager)
        serverListVC.tabBarItem = UITabBarItem(title: "Servers",
                                               image: UIImage(named: Theme.serverListTabBarIcon),
                                               tag: 1)
        let serverNavC = UINavigationController(rootViewController: serverListVC)
        serverNavC.navigationBar.barStyle = .black
        serverNavC.navigationBar.isTranslucent = false
        serverNavC.navigationBar.barTintColor = .navigationBarBg
        serverNavC.navigationBar.tintColor = .navigationBarItemTint
        serverNavC.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.navigationBarItemTint]
        
        let settingsVC = SettingsTableViewController.build(with: apiManager)
        settingsVC.tabBarItem = UITabBarItem(title: "Settings",
                                             image: UIImage(named: Theme.settingsTabBarIcon),
                                             tag: 2)
        let settingsNavC = UINavigationController(rootViewController: settingsVC)
        settingsNavC.navigationBar.barStyle = .black
        settingsNavC.navigationBar.isTranslucent = false
        settingsNavC.navigationBar.barTintColor = .navigationBarBg
        settingsNavC.navigationBar.tintColor = .navigationBarItemTint
        settingsNavC.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.navigationBarItemTint]
        
        viewControllers = [dashboardVC, serverNavC, settingsNavC]
        selectedViewController = dashboardVC
        
        // Accessing the view property of each tab's root view controller forces
        // the system to run "viewDidLoad" which will configure the tab icon and
        // title in the tab bar.
        let _ = dashboardVC.view
        let _ = serverListVC.view
        let _ = settingsVC.view
    }
}

extension WLVPNTabBarController: StoryboardInstantiable {
    
    static var storyboardName: String {
        return "TabBar"
    }
    
    class func build(with apiManager: VPNAPIManager) -> WLVPNTabBarController {
        let tabBarC = instantiateInitial()
        tabBarC.apiManager = apiManager
        return tabBarC
    }
}
