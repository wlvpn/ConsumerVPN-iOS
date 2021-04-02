//
//  StoryboardInstantiable.swift
//  Consumer VPN
//
//  Created by WLVPN on 2/12/19.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation
import UIKit

protocol StoryboardInstantiable: class {
    static var storyboardName: String { get }
}

extension StoryboardInstantiable where Self: UIViewController {
    static func instantiatingStoryboard() -> UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: nil)
    }
    
    static func instantiateInitial() -> Self {
        return instantiatingStoryboard().instantiateInitialViewController() as! Self
    }
    
    static func instantiate(with identifier: String) -> Self {
        return instantiatingStoryboard().instantiateViewController(withIdentifier: identifier) as! Self
    }
}
