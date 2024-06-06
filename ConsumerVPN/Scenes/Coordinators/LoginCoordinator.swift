//
//  LoginCoordinator.swift
//  Consumer VPN
//
//  Created by WLVPN on 2/12/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation

protocol LoginCoordinatorDelegate {
	func didSignIn(_ user: User)
	func userDidSignUpUsingAuth(username: String, password: String)
	func userDidSignUpUsingMagicLink(username: String)
}

protocol LoginFlowViewControllerDelegate {
	func signUpRequested(username: String?, password: String?, confirmPassword: String?, from controller: UIViewController)
	func signInRequested(username: String?, password: String?, from controller: UIViewController)
}

final class LoginCoordinator: NSObject {
	
	var rootViewController = UINavigationController()
	
	let accountAPI: AccountAPI
	let purchaseCoordinator: PurchaseCoordinator
	
	// We cannot make this a constant due to our conformance to VPNAccountStatusReporting.
	var apiManager: VPNAPIManager!
	
	var delegate: LoginCoordinatorDelegate!
	
	init(apiManager: VPNAPIManager, accountAPI: AccountAPI, purchaseCoordinator: PurchaseCoordinator) {
		self.apiManager = apiManager
		self.accountAPI = accountAPI
		self.purchaseCoordinator = purchaseCoordinator
		// NotificationCenter.default.addObserver(for: self)
	}
	
	func start(from: UIViewController) {
		let loginVC = LoginViewController.build(with: self)
		loginVC.delegate = self
        
		if #available(iOS 13.0, *) {
			loginVC.isModalInPresentation = true
		}
		rootViewController = UINavigationController(rootViewController: loginVC)
        rootViewController.modalPresentationStyle = .fullScreen
		// Causes modal presentation to occur on the next run loop iteration, preventing "unbalanced call" messages
		DispatchQueue.main.async {
            ProgressSpinnerHelper.shared.hideSpinner()
			from.present(self.rootViewController, animated: true, completion: nil)
		}
	}
	
	func login(username: String?, password: String?, in controller: UIViewController) {
		
		guard let username = username?.emailCharactersOnlyString else {
            ProgressSpinnerHelper.shared.hideSpinner()
			UIAlertController.presentErrorAlert(LocalizedString.usernameInvalid, in: controller)
			return
		}
		
		guard let password = password?.whiteSpaceTrimmed else {
            ProgressSpinnerHelper.shared.hideSpinner()
			UIAlertController.presentErrorAlert(LocalizedString.loginEmptyField, in: controller)
			return
		}
		
		accountAPI.signIn(username: username, password: password) { result in
            ProgressSpinnerHelper.shared.hideSpinner()
			switch result {
            case .success(let user):
				self.delegate.didSignIn(user)
				
			case .failure(let error):
				UIAlertController.presentErrorAlert(error.localizedDescription, in: controller)
			}
		}
	}
}

extension LoginCoordinator : LoginFlowViewControllerDelegate {
	
	func signInRequested(username: String?, password: String?, from controller: UIViewController) {
		
		// If we're coming `from = SignUpVC` then display the LoginVC.
		guard controller is LoginViewController else {
            ProgressSpinnerHelper.shared.hideSpinner()
			rootViewController.popToRootViewController(animated: true)
			return
		}
		
		login(username: username,
			  password: password,
			  in: controller)
	}
	
	
	func signUpRequested(username: String?, password: String?, confirmPassword: String?, from controller: UIViewController) {
		
		// If we're coming `from = LoginVC` then display the SignUpVC.
		guard controller is SignupViewController else {
			let signUpVC = SignupViewController.build(delegate: self,
													  username: username,
													  password: password)
			rootViewController.pushViewController(signUpVC, animated: true)
			return
		}
		
		guard let username = username?.emailCharactersOnlyString else {
			UIAlertController.presentErrorAlert(LocalizedString.usernameInvalid, in: controller)
			return
		}
		
		// Is this a magic link kind of thing or do we have a password?
		let validatedPassword: String?
		if Theme.hideSignUpPasswordFields {
			// Magic link.
			validatedPassword = nil
		} else {
			// We do have passwords. Validate they're not empty and they're the same.
			guard
				let password = password?.whiteSpaceTrimmed,
				let confirmPassword = confirmPassword?.whiteSpaceTrimmed else {
					UIAlertController.presentErrorAlert(LocalizedString.loginEmptyField, in: controller)
					return
			}
			
			guard password == confirmPassword else {
				UIAlertController.presentErrorAlert(LocalizedString.passwordMismatch, in: controller)
				return
			}
			
			validatedPassword = password
		}
		
		// Prompt the user to accept the privacy policy.
		// This is a requirement by Apple's App Store Review Guidelines [guideline 5.4](https://developer.apple.com/app-store/review/guidelines/).
		let privacyVC = PrivacyNoticeViewController.build(with: self, username: username, password: validatedPassword)
		rootViewController.pushViewController(privacyVC, animated: true)
	}
}

extension LoginCoordinator: PrivacyNoticeDelegate {
	
	func userDidAgree(username: String, password: String?, in controller: UIViewController) {
		
		let plans = PlansViewController.build(delegate: self, username: username, password: password)
		self.rootViewController.pushViewController(plans, animated: true)
		
		purchaseCoordinator.fetch { result in
			switch result {
				
			case .success(let products):
				plans.plans = products
				
			case .failure(let error):
				UIAlertController.presentErrorAlert(LocalizedString.contactSupport(with: error),
													in: controller)
			}
		}
	}
}

extension LoginCoordinator : PlansViewControllerDelegate {
	
	func userDidSelect(plan: Plan, username: String, password: String?, from controller: UIViewController) {
		
		purchaseCoordinator.purchase(product: plan, username: username, password: password) { result in
			switch result {
				
			case .success:
				if let password = password {
					self.delegate.userDidSignUpUsingAuth(username: username, password: password)
				} else {
					self.delegate.userDidSignUpUsingMagicLink(username: username)
				}
				
			case .failure(let error):
				UIAlertController.presentErrorAlert(LocalizedString.contactSupport(with: error),
													in: controller)
			}
		}
	}
}
