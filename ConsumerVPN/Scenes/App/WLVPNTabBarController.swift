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
	}
}

extension WLVPNTabBarController: StoryboardInstantiable {
	
	static var storyboardName: String {
		return "TabBar"
	}
	
	class func build(with apiManager: VPNAPIManager,
					 dashboardVC: UIViewController,
					 serverListVC: UIViewController,
					 settingsVC: UIViewController) -> WLVPNTabBarController {
		
		let tabbarController = instantiateInitial()
		
		// To ensure tab bar items load properly (including active tint color for
		// the selected tab), the tab bar items are configured here rather than
		// within each view controller class.
		dashboardVC.tabBarItem = UITabBarItem(title: "Dashboard",
											  image: UIImage(named: Theme.dashboardTabBarIcon),
											  tag: 0)
		
		serverListVC.tabBarItem = UITabBarItem(title: "Servers",
											   image: UIImage(named: Theme.serverListTabBarIcon),
											   tag: 1)
		let serverNavC = UINavigationController(rootViewController: serverListVC)
		serverNavC.navigationBar.barStyle = .black
		serverNavC.navigationBar.isTranslucent = false
		serverNavC.navigationBar.barTintColor = .serverNavigationBarBg
		serverNavC.navigationBar.tintColor = .serverNavigationBarItemTint
		serverNavC.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.serverNavigationBarItemTint]
		
		settingsVC.tabBarItem = UITabBarItem(title: "Settings",
											 image: UIImage(named: Theme.settingsTabBarIcon),
											 tag: 2)
		let settingsNavC = UINavigationController(rootViewController: settingsVC)
		settingsNavC.navigationBar.barStyle = .black
		settingsNavC.navigationBar.isTranslucent = false
		settingsNavC.navigationBar.barTintColor = .settingsNavigationBarBg
		settingsNavC.navigationBar.tintColor = .settingsNavigationBarItemTint
		settingsNavC.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.settingsNavigationBarItemTint]
		
		tabbarController.viewControllers = [dashboardVC, serverNavC, settingsNavC]
		tabbarController.selectedViewController = dashboardVC
		
		// Accessing the view property of each tab's root view controller forces
		// the system to run "viewDidLoad" which will configure the tab icon and
		// title in the tab bar.
		let _ = dashboardVC.view
		let _ = serverListVC.view
		let _ = settingsVC.view
		
		tabbarController.apiManager = apiManager
		return tabbarController
	}
}

extension WLVPNTabBarController {
	
	open override var childForStatusBarStyle: UIViewController? {
		return selectedViewController?.childForStatusBarStyle ?? selectedViewController
	}
	
}

extension UINavigationController {
	
	open override var childForStatusBarStyle: UIViewController? {
		return topViewController?.childForStatusBarStyle ?? topViewController
	}
	
}
