//
//  AccountAPI.swift
//  ConsumerVPN
//
//  Created by Fernando Olivares on 29/03/20.
//  Copyright © 2020 NetProtect. All rights reserved.
//

import UIKit

class AccountAPI : NSObject {
	
	var apiManager: VPNAPIManager
	
	var signInCompletion: ((Result<User, Error>) -> Void)?
	
	init(apiManager: VPNAPIManager) {
		self.apiManager = apiManager
		super.init()
		
		NotificationCenter.default.addObserver(for: self)
	}
	
	func signIn(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
		// This function will notify us via notifications of the results.
        apiManager.loginWithRetry(forUsername: username, password: password)
		signInCompletion = completion
	}
}

// MARK: - VPNAccountStatusReporting
extension AccountAPI: VPNAccountStatusReporting {
	
	func statusLoginSucceeded(_ notification: Notification) {
        onLogin(notification)
	}
	
	func statusLoginFailed(_ notification: Notification) {
		
		guard let error = notification.object as? NSError else {
			assertionFailure("`statusLoginFailed` notification does not contain a `User` object")
			return
		}
		
		signInCompletion?(.failure(error))
	}
    
    func statusAutomaticLoginSuceeded(_ notification: Notification) {
        onLogin(notification)
    }
    
    func onLogin(_ notification: Notification) {
        guard let user = notification.object as? User else {
            assertionFailure("`statusLoginSucceeded` notification does not contain a `User` object")
            return
        }
        
        signInCompletion?(.success(user))
    }
}
