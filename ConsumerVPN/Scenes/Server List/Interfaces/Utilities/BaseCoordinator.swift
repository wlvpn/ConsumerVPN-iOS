//
//  BaseCoordinator.swift
//  Consumer VPN
//
//  Created by WLVPN on 2/12/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation
import UIKit

class BaseCoordinator: CoordinatorType {
    let uuid = UUID()
    var childCoordinators = [CoordinatorType]()
    var navigationController = UINavigationController()
    
    func start() {
        preconditionFailure("A subclass must override start()")
    }
}
