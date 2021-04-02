//
//  AccessibilityIdentifier.swift
//  ConsumerVPN
//
//  Created by WLVPN on 10/18/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation

//Identifiers should be used for things that will change as in `Best Available` or `Atlanta, US` and does not need to be localized

/// A centralized place to store strings for accessibility identifiers so it can be used in both the application and tests.
/// These strings won't be user-facing and therefore does not need to be localized.
enum AccessibilityIdentifier: String {
    case
    popSelection = "PoP Selection",
    bannerImage = "Banner Image",
    popHeaderLocationLabel = "PoP Header Location Label"
}
