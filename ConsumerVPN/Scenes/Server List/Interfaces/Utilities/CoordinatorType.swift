//
//  CoordinatorType.swift
//  Consumer VPN
//
//  Created by WLVPN on 2/12/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation
import UIKit

protocol CoordinatorType: class {
    var childCoordinators: [CoordinatorType] { get set }
    var uuid: UUID { get }
    var navigationController: UINavigationController { get set }
    func start()
}

extension CoordinatorType {
    func add(childCoordinator: CoordinatorType) {
        childCoordinators.append(childCoordinator)
    }
    
    func remove(childCoordinator: CoordinatorType) {
        guard let index = childCoordinators.firstIndex(where: { otherCoordinator in
            return otherCoordinator.uuid == childCoordinator.uuid
        }) else {
            return
        }
        
        childCoordinators.remove(at: index)
    }
    
    func removeAllChildren() {
        childCoordinators.removeAll()
    }
}
