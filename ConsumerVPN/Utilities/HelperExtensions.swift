//
//  HelperExtensions.swift
//  ConsumerVPN
//
//  Created by WLVPN on 10/5/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit

extension Sequence {
    /// Searches a sequence of elements for the first one that passes the test passed into the method
    ///
    /// - parameter predicate: Test to be run on each of the elements. First one to pass the test is returned
    ///
    /// - throws: Rethrows any errors that the passed in method throws if any
    ///
    /// - returns: A valid value for the first element to pass the test or nil if none in the collection pass
    func find(_ predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        for element in self {
            if try predicate(element) {
                return element
            }
        }
        return nil
    }
    
    /// Similar to `find` this method searches a sequence of elements for elements that pass the test passed in as a parameter,
    /// but unlike `find` this method does not return after finding the first element to pass. Instead, this method will find all elements
    /// that pass the test and return the index positions of those elements
    ///
    /// - parameter predicate: Test to be run on each of the elements. Index is returned for all elements that pass.
    ///
    /// - throws: Rethrows any errors that the passed in method throws if any
    ///
    /// - returns: An array containing the index positions of the elements that passed the test.
    func indices(where predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> [Int] {
        var indices: [Int] = []
        for (index, element) in self.enumerated() {
            if try predicate(element) {
                indices.append(index)
            }
        }
        return indices
    }
}

extension String {
    
    /// A Boolean value indicating whether a string has characters
    var hasText: Bool {
        return !self.isEmpty
    }
}

extension UIColor {
    
    /// A lighter representation of the caller's color value. This is done by increasing the `brightness` value by 30% and capping at 100% brightness
    var lighter: UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        return UIColor(hue: h, saturation: s, brightness: min(b * 1.3, 1), alpha: a)
    }
    
    /// A darker representation of the caller's color value. This is done be decreasing the `brightness` value by 25%.
    var darker: UIColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        return UIColor(hue: h, saturation: s, brightness: b * 0.75, alpha: a)
    }
}

extension UIAlertController {
    
    /// Helper method for creating an alert controller and adding each of the actions to it.
    ///
    /// - parameter title:     Title of the alert controller
    /// - parameter message:   Message body of the alert controller
    /// - parameter actions:   List of UIAlertActions that define what buttons the user sees on the alert controller and what functionality should run when tapped
    /// - parameter alertType: The type of alert controller that will be returned
    ///
    /// - returns: An alert controller composed of all the incoming parameters' values
    static func alert(withTitle title : String,
                      message : String,
                      actions : [UIAlertAction],
                      alertType : UIAlertController.Style) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: alertType)
        
        for action in actions {
            alert.addAction(action)
        }
        
        return alert
    }
    
    /// Helper method for creating an alert specifically geared towards lack of network reachability
    ///
    /// - returns: An alert controller containing all information about the lack of network connection
    static func network() -> UIAlertController {
        return .alert(withTitle: LocalizedString.networkSettingsAlertTitle,
                     message: LocalizedString.networkConnectionIssue,
                     actions: [UIAlertAction.init(title: LocalizedString.ok, style: .default, handler: nil)],
                     alertType: .alert)
    }
    
    /// Helper method for creating an alert specifically geared towards informing the user of what went wrong and to contact support should it persist
    ///
    /// - parameter error: Error describing what went wrong
    ///
    /// - returns: An alert controller containing all information about the error and contact support
    static func contactSupport(with error: Error) -> UIAlertController {
        let alertTitle = LocalizedString.somethingWentWrongTitle
        let alertMessage = LocalizedString.contactSupport(with: error)
        
        // Attempts to retrieve contact support URL from the Customization.plist. If this fails, show generic alert to contact support
        let contactSupportURL = URL(string: Theme.contactSupportURL)!; // Display Alert with Ability to Contact Support


        let cancel = UIAlertAction(title: LocalizedString.ok, style: .cancel, handler: nil)
        let contact = UIAlertAction(title: LocalizedString.contact,
                                    style: .default,
                                    handler: { (action) in
                                        // Ask if we can open the URL
                                        if UIApplication.shared.canOpenURL(contactSupportURL) {
                                            UIApplication.shared.open(contactSupportURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                                        }
        })

        return .alert(withTitle: alertTitle, message: alertMessage, actions: [cancel, contact], alertType: .alert)
    }
}

extension UIViewController {
    
    /// This helper method will drill down from the root view controller of the application to find the view controller that is most
    /// active/currently viewed by the user at that point in time.
    ///
    /// - Returns: The top most/currently viewed view controller if one exists
    static var currentViewController: UIViewController? {
        // Find best view controller
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return nil
        }
        
        return findBestViewController(with: rootViewController)
    }
    
    /// This helper method is called recursively until we've reached the end of the view controller hierarchy. It takes into consideration
    /// split view controllers, navigation controllers, tab controllers, and presented view controllers to find the top-most, currently-viewed,
    /// right-hand view controller
    ///
    /// - Parameter viewController: The View Controller to drill down further into
    /// - Returns: The top-most, currently-viewed/right-hand view controller in the app at the time of calling
    private static func findBestViewController(with viewController: UIViewController) -> UIViewController {
        
        // based on the incoming view controller, drill down the the current top most view controller
        
        if let presentedViewController = viewController.presentedViewController { // If this view controller presented something, keep going down
            
            // Return the presented view controller
            return findBestViewController(with: presentedViewController)
            
        } else if let splitViewController = viewController as? UISplitViewController { // If this is a split vc
            
            // Return the right hand side
            if splitViewController.viewControllers.count > 0 {
                return findBestViewController(with: splitViewController.viewControllers.last!)
            } else {
                return viewController
            }
        } else if let navigationController = viewController as? UINavigationController { // If this is a nav controller
            
            // Return the top view controller
            if let topViewController = navigationController.topViewController {
                return findBestViewController(with: topViewController)
            } else {
                return viewController
            }
        } else if let tabController = viewController as? UITabBarController { // If this is a tab controller
            
            // Return the visible view controller (selected)
            if let selectedViewController = tabController.selectedViewController {
                return findBestViewController(with: selectedViewController)
            } else {
                return viewController
            }
        } else { // Unkown
            
            // Unknown view controller type, return last child view controller
            return viewController
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
