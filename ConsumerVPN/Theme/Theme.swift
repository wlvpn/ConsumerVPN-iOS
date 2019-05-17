//
//  Constants.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/16/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation

final class Theme {
    
    static let productName = "Consumer VPN"
    static let brandName = "Consumer VPN"

    static let forgotPasswordURL = "https://www.wlvpn.com"
    static let contactSupportURL = "https://www.wlvpn.com"

    static let usernameSuffix = "<supplied by WLVPN>"
    static let apiKey = "<supplied by WLVPN>"
    
    // MARK: User Defaults Keys
    static let lastUpdateKey = "lastUpdateKey"
    static let isInitialLoad = "isInitialLoadDone"
    static let sortOptionKey = "sortOption"
    static let filterPingRangeKey = "filterPingRange"
    static let loginErrorKey = "loginError"
    static let firstConnectKey = "firstConnect"
    
    // Tab Bar Icon names in the asset catalog
    static let dashboardTabBarIcon = "dashboard_tab_bar"
    static let serverListTabBarIcon = "server_list_tab_bar"
    static let settingsTabBarIcon = "settings_tab_bar"
}

// MARK: - Target Specific Colors
extension UIColor {
    
    // New colors for new design
    
    // Color used as background fill of views
    static var viewBackground: UIColor {
        return UIColor(hexColorString: "1F232F")
    }
    
    // Color used to denote tappable controls
    static var appWideTint: UIColor {
        return UIColor(hexColorString: "4A90E2")
    }
    
    // Color of tab bar
    static var tabBarBg: UIColor {
        return UIColor(hexColorString: "393F51")
    }
    
    // Color of tab bar icons and titles when not selected
    static var tabBarItemInactiveTint: UIColor {
        return UIColor(hexColorString: "1F232F")
    }
    
    // Color of tab bar icons and titles when active tab
    static var tabBarItemActiveTint: UIColor {
        return .white
    }
    
    static var primaryText: UIColor {
        return .white
    }
    
    static var secondaryText: UIColor {
        return UIColor(hexColorString: "707070")
    }
    
    static var navigationBarBg: UIColor {
        return .viewBackground
    }
    static var navigationBarItemTint: UIColor {
        return .white
    }
    
    static var serverListSectionBg: UIColor {
        return UIColor(hexColorString: "424754")
    }
    
    static var checkmark: UIColor {
        return .primaryAccent
    }
    
    static var segmentedControlTint: UIColor {
        return .appWideTint
    }
    
    static var cellSeparatorTint: UIColor {
        return .serverListSectionBg
    }
    
    static var cellAccessoryTint: UIColor {
        return .white
    }
    
    static var disconnectRed: UIColor {
        return UIColor(hexColorString: "D0021B")
    }
    
    static var loginViewGradientTop: UIColor {
        return UIColor(hexColorString: "090A0E")
    }
    
    static var loginViewGradientMid: UIColor {
        return UIColor(hexColorString: "4A4E5C")
    }
    
    static var loginViewGradientBottom: UIColor {
        return UIColor(hexColorString: "202534")
    }
    
    static var loginViewTallTriangleBg: UIColor {
        return UIColor(hexColorString: "2F323F")
    }
    
    static var loginViewShortTriangleBg: UIColor {
        return UIColor(hexColorString: "262a37")
    }
    
    static var loginFieldText: UIColor {
        return .primaryText
    }
    
    
    
    
    
    // Old colors, may or may not use these vars in the new design
    
    static var pingFont: UIColor {
        return UIColor(hexColorString: "7ED321")
    }
    
    // Some Targets have a secondary accent color and others do not
    // Some Targets have a secondary background color and others do not

    static var primaryAccent: UIColor {
        return UIColor(hexColorString: "FFFFFF")
    }
    static var secondaryAccent: UIColor {
        return UIColor(hexColorString: "202020")
    }
    static var primaryBackground: UIColor {
        return UIColor(hexColorString: "545454")
    }
    static var selectedServer: UIColor {
        return UIColor(hexColorString: "545454")
    }
    
    // Buttons
    static var loginButtonBackground: UIColor {
        return primaryAccent
    }
    static var signUpButtonBorder: UIColor {
        return primaryAccent
    }
    
    // Backgrounds
    static var loginBackground: UIColor {
        return .primaryBackground
    }
    static var serverListBackground: UIColor {
        return UIColor(hexColorString: "0C0C0C")
    }
    static var filterBackground: UIColor {
        return .serverListBackground
    }
    static var settingsBackground: UIColor {
        return .primaryBackground
    }
    
    // Cell colors
    static var settingsCell: UIColor {
        return .selectedServer
    }
    static var filterCell: UIColor {
        return .selectedServer
    }
    
    // Fonts
    static var primaryFont: UIColor {
        return .white
    }
    static var secondaryFont: UIColor {
        return .secondaryAccent
    }
    static var optionsFont: UIColor {
        return .primaryFont
    }
    
}
