//
//  FilterViewControllerDelegate.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/22/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation

protocol FilterViewControllerDelegate {
    func filterViewController(_ filterViewController: FilterViewController, selected sortOption: SortOption)
}
