//
//  EmptyStateViewDelegate.swift
//  ConsumerVPN
//
//  Created by WLVPN on 10/12/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation

/// Defines a contract between the EmptyStateView and the ServerListViewController to reload the servers from the api manager when reloadServersTapped(in:) is called
protocol EmptyStateViewDelegate {
    func reloadServersTapped(in emptyStateView: EmptyStateView)
}
