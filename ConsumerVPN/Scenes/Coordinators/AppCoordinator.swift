//
//  AppCoordinator.swift
//  ConsumerVPN
//
//  Created by Fernando Olivares on 2/11/20.
//  Copyright © 2020 NetProtect. All rights reserved.
//

import Foundation

class AppCoordinator : NSObject {
	
	var tabController: WLVPNTabBarController!
	var apiManager: VPNAPIManager
	
	let accountAPI: AccountAPI
	
	var loginCoordinator: LoginCoordinator?
	
	init(apiManager: VPNAPIManager) {
		self.apiManager = apiManager
		self.accountAPI = AccountAPI(apiManager: apiManager)
		super.init()
		
		NotificationCenter.default.addObserver(for: self)
	}
	
	func beginLoginFlow() {
		let purchaseCoordinator = RevenueCatCoordinator(apiKey: Theme.revenueCatAPIKey,
														debug: Theme.revenueCatConsoleDebugging,
														productIdentifiers: Theme.revenueCatProductIdentifiers)
		self.loginCoordinator = LoginCoordinator(apiManager: apiManager,
												 accountAPI: accountAPI,
												 purchaseCoordinator: purchaseCoordinator)
		self.loginCoordinator!.delegate = self
		self.loginCoordinator!.start(from: tabController)
	}
}

extension AppCoordinator : DashboardViewControllerDelegate {
	
	func userRequestedConnection(from: DashboardViewController) {
		
		guard
			let accountSetupComplete = UserDefaults.standard.value(forKey: Theme.firstConnectKey) as? Bool,
			accountSetupComplete else {
				beginLoginFlow()
				return
		}
		
		apiManager.connect()
		from.updateStatusForState(state: .statusConnecting)
	}
}

extension AppCoordinator : LoginCoordinatorDelegate {
	func didSignIn(_ user: User) {
		UserDefaults.standard.set(true, forKey: Theme.firstConnectKey)
		UserDefaults.standard.synchronize()
		
		tabController.dismiss(animated: true, completion: nil)
	}
	
	func userDidSignUpUsingAuth(username: String, password: String) {
		UserDefaults.standard.set(true, forKey: Theme.firstConnectKey)
		UserDefaults.standard.synchronize()
		
		tabController.dismiss(animated: true) {
			self.loginCoordinator?.login(username: username, password: password, in: self.tabController)
		}
	}
	
	func userDidSignUpUsingMagicLink(username: String) {
		UserDefaults.standard.set(true, forKey: Theme.firstConnectKey)
		UserDefaults.standard.synchronize()
		
		UIAlertController.presentErrorAlert(LocalizedString.magicLinkSent,
											in: self.tabController)
	}
}

// MARK: - VPN Account Status Reporting Protocol Conformance
extension AppCoordinator: VPNAccountStatusReporting {
	
	/// Used to Ensure Account preferences are set back to defaults
	func statusLogoutWillBegin(_ notification: Notification) {
		UserDefaults.standard.set(0, forKey: Theme.filterPingRangeKey)
		UserDefaults.standard.set(0, forKey: Theme.sortOptionKey)
		UserDefaults.standard.set(nil, forKey: Theme.lastUpdateKey)
		UserDefaults.standard.synchronize()
		
		beginLoginFlow()
	}
	
	func statusLoginSucceeded(_ notification: Notification) {}
	
	func statusLogoutWillBegin() {}
}
