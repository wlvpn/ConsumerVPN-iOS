//
//  LoginCoordinator.swift
//  Consumer VPN
//
//  Created by WLVPN on 2/12/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation

final class LoginCoordinator: BaseCoordinator {
    
    let presenter: UIViewController
    var rootViewController = UINavigationController()
    
    let apiManager: VPNAPIManager
    let vpnConfiguration: VPNConfiguration
    
    init(presenter: UIViewController, apiManager: VPNAPIManager) {
        self.presenter = presenter
        self.apiManager = apiManager
        self.vpnConfiguration = apiManager.vpnConfiguration
    }
    
    override func start() {
        let loginVC = LoginViewController.build(with: apiManager)
        rootViewController = UINavigationController(rootViewController: loginVC)
        // Causes modal presentation to occur on the next run loop iteration, preventing "unbalanced call" messages
        DispatchQueue.main.async {
            self.presenter.present(self.rootViewController, animated: true, completion: nil)
        }
    }
}
