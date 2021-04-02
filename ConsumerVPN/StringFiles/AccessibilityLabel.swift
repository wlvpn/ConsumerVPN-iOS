//
//  AccessibilityLabel.swift
//  ConsumerVPN
//
//  Created by WLVPN on 10/18/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation

// Avoid using words that describe the UI element like `Button` or `Label` and ideally should be
// a single word to describe action to users as in `Play`, `Settings`, or `Delete`

// Labels are great for non-textual pieces of UI or UI that should have more context. For instance,
// assume our app is a competitive app of some kind where we can see history of game sessions. For normal users,
// they might see `W` or `L` and associate that with `Win` or `Loss`, but a blind person may not get that same context.

/// A centralized place to store strings for accessibility identifiers so it can be used in both the application and tests.
/// These strings will be heard by visually impaired users and therefore needs to be localized.
enum AccessibilityLabel {
    
    // MARK: Buttons
    static let settingsButton = NSLocalizedString("Settings",
                                                  comment: "Accessibility for settings button")
    
    static let filterButton = NSLocalizedString("Filter",
                                                comment: "Accessibility for filter button")
    
    static let searchButton = NSLocalizedString("Search",
                                                comment: "Accessibility for search button")
    
    // MARK: Ping Range
    static let lessThanFifty = NSLocalizedString("Less than 50",
                                                 comment: "Accessibility for less than 50 filter option")
    
    static let betweenFiftyAndOneHundred = NSLocalizedString("Between 50 and 100",
                                                             comment: "Accessibility for between 50 and 100 filter option")
    
    static let betweenOneHundredAndTwoHundred = NSLocalizedString("Between 100 and 200",
                                                                  comment: "Accessibility for between 100 and 200 filter option")
    
    static let greaterThanTwoHundred = NSLocalizedString("Greater than 200",
                                                         comment: "Accessibility for greater than 200 filter option")
}
