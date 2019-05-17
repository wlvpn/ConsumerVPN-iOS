//
//  LocalizedString.swift
//  ConsumerVPN
//
//  Created by WLVPN on 10/18/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import Foundation

/// Centralized Location of all Localizeable Strings as written in Swift to be easily shared across targets and tests.
/// LocalizedString is defined as an enum to prevent instantiation
enum LocalizedString {
    
    // MARK: - ServerListViewController
    
    static let serverUpdateBegin = NSLocalizedString("Loading Servers", comment: "Notify the user that the server update has started.")
    static let serverUpdateSuccess = NSLocalizedString("Servers loaded successfully!", comment: "Notify the user that the server update has succeeded.")
    static let serverUpdateFailed = NSLocalizedString("Server update failed", comment: "Notify the user that the server update has failed.")
    
    // MARK: - General
    static let loading = NSLocalizedString("Loading...", comment: "Label shown for loading to indicate indeterminate progress")
    static let fastestAvailable = NSLocalizedString("Fastest Available", comment: "Cell allowing the user to let the app choose the optimal city, country for the connection")
    
    // MARK: - Dashboard
    static let aes256 = NSLocalizedString("AES-256", comment: "Label indicating the current encryption level of the connection")
    static let aes128 = NSLocalizedString("AES-128", comment: "Label indicating the current encryption level of the connection")
    static let statusConnected = NSLocalizedString("Connected", comment: "Status label to indicate to the user that they are connected to the VPN.")
    
    // MARK: - Empty State View
    static let somethingWentWrongTitle = NSLocalizedString("Something Went Wrong", comment: "Title telling the user something went wrong") // Also used as Alert Title
    static let noResultsFound = NSLocalizedString("No Results Found", comment: "Title Label shown to indicate no servers match provided options and/or search text")
    static let noResultsReloadServers = NSLocalizedString("No servers were found. Try again.", comment: "Label shown to indicate no servers were found at all and prompt the user to attempt to retry loading the servers again")
    
    static let noMatchInPingRangeFormat = NSLocalizedString("No servers were found that match \"%@\" in the ping range \"%@\".",
                                                            comment: "Label shown for no servers matching search text within ping range")
    static let noMatchFormat = NSLocalizedString("No servers were found that match \"%@\".",
                                                 comment: "Label shown for no servers matching search text")
    static let noResultsInPingRangeFormat = NSLocalizedString("No servers were found in the ping range \"%@\". Try changing the filter options.",
                                                              comment: "Label shown for no servers within ping range. Suggesting to change filter options")
    
    // MARK: - Filter View Controller
    // MARK: Table Headers
    static let sortByHeader = NSLocalizedString("Sort By", comment: "Header presenting list of options for how to sort the servers list")
    static let pingHeader = NSLocalizedString("Ping", comment: "Header presenting list of options for constraining servers within a range of ping values")
    
    // MARK: Filter Options
    static let any = NSLocalizedString("Any", comment: "Label displaying an option indicating any and all values will be displayed")
    static let lessThanFifty = NSLocalizedString("< 50", comment: "Label displaying an option indicating only servers with a latency of less than 50 will be displayed")
    static let betweenFiftyAndOneHundred = NSLocalizedString("50 - 100", comment: "Label displaying an option indicating only servers with a latency between 50 and 100 inclusive will be displayed")
    static let betweenOneHundredAndTwoHundred = NSLocalizedString("100 - 200", comment: "Label displaying an option indicating only servers with a latency between 100 and 200 inclusive will be displayed")
    static let greaterThanTwoHundred = NSLocalizedString("> 200", comment: "Label displaying an option indicating only servers with a latency greater than 200 will be displayed")
    
    // MARK: Sort Options
    static let citySelection = NSLocalizedString("City", comment: "Label displaying a preference for sorting the servers list")
    static let countrySelection = NSLocalizedString("Country", comment: "Label displaying a preference for sorting the servers list")
    static let serverCountSelection = NSLocalizedString("Server Count", comment: "Label displaying a preference for sorting the servers list")
    
    // MARK: - Settings View Controller
    
    /// Function for creating a localized formatted string asking the user to rate the current product
    ///
    /// - Parameter product: The name of the product we want the user to rate
    /// - Returns: Localized formatted string of **Rate %@**
    static func rate(productName product: String) -> String {
        return String.localizedStringWithFormat(NSLocalizedString("Rate %@", comment: "Static Text informing the user they can rate the product"), product)
    }
    
    // MARK: - Alerts
    // MARK: Titles
    static let networkSettingsAlertTitle = NSLocalizedString("Network Settings", comment: "Alert Title indicating a root cause of an issue")
    static let logoutAlertTitle = NSLocalizedString("Logout?", comment: "")
    static let loginErrorAlertTitle = NSLocalizedString("Login Failed", comment: "A Login Error has occurred")
    static let preferencesHeader = NSLocalizedString("Preferences", comment: "")
    static let onDemandConnectedAlertTitle = NSLocalizedString("OnDemand is Enabled", comment: "OnDemand is Enabled.")
    static let signUpErrorAlertTitle = NSLocalizedString("Sign Up Error", comment: "Alert Title indicating an error on Sign Up")
    static let passwordAlertTitle = NSLocalizedString("Account Verification", comment: "Alert title indicating more information needed to verify account")
    static let accountAlertTitle = NSLocalizedString("Account Created Successfully", comment: "Account was created successfully.")
    
    
    // MARK: Messages
    static let logoutAlertMessageConnected = NSLocalizedString("Logging out will disconnect you from the VPN. Are you sure you would like to logout?", comment: "")
    static let logoutAlertMessageDisconnected = NSLocalizedString("Are you sure you would like to logout?", comment: "")
    static let loginEmptyField = NSLocalizedString("One or more login fields are empty. Please enter your credentials.", comment: "One or more fields are empty")
    static let usernameInvalid = NSLocalizedString("The username entered is invalid.", comment: "Username invalid format")
    static let applyChangeReconnect = NSLocalizedString("To apply this change now, we must restart your connection. Do you want to continue?", comment: "")
    static let connectingProgress = NSLocalizedString("Connecting...", comment: "")
    static let connectionFailed = NSLocalizedString("Failed to connect to VPN", comment: "The connection to the VPN has failed.")
    static let initialServerListBegin = NSLocalizedString("Loading Initial Servers", comment: "Initial server list load has started.")
    static let networkConnectionIssue = NSLocalizedString("There appears to be no network connection. Please check your connection settings.",
                                                          comment: "Alert Message requesting the user check their network settings")
    static let onDemandConnectedAlertMessage = NSLocalizedString("Disconnecting from the VPN will disable OnDemand settings. Do you wish to continue?",
                                                                 comment: "Disconnecting from the VPN will disable OnDemand settings. Do you wish to continue?")
    static let signUpEmptyFieldAlertMessage = NSLocalizedString("One or more login fields are empty. Please enter your credentials.",
                                                                comment: "Alert Message telling the user one or more fields are empty and should not be")
    static let signUpUsernameCharacterCountAlertMessage = NSLocalizedString("Your username must be less than 255 characters",
                                                                            comment: "Alert message telling the user the email field has too many characters")
    static let signUpEmailCharacterCountAlertMessage = NSLocalizedString("Your email must be less than 100 characters.",
                                                                         comment: "Alert Message telling the user the email field has too many characters")
    static let signUpPasswordCharacterCountAlertMessage = NSLocalizedString("Password must be at least 4 characters long.",
                                                                            comment: "Alert Message telling the user the password field has too few characters")
    static let signUpUsernameIncorrectFormatAlertMessage = NSLocalizedString("The username you entered is not valid. Only letters and numbers are allowed. No special characters.",
                                                                             comment: "Alert message telling the user an invalid username was provided")
    static let signUpEmailIncorrectFormatAlertMessage = NSLocalizedString("The email address you entered is not a valid email.",
                                                                          comment: "Alert Message telling the user an invalid email address was provided")
    static let signUpPasswordMismatchAlertMessage = NSLocalizedString("Passwords do not match. Please make sure both entires are the same.",
                                                                      comment: "Alert Message telling the user the password fields do not match")
    static let touchIDReason = NSLocalizedString("Logging in with Touch ID", comment: "System Alert Message to indicate reason for Touch ID prompt")
    static let passwordAlertInitialMessage = NSLocalizedString("Enter your password:", comment: "Alert message asking user to input their account password")
    static let checkUsernameDidFailAlertMessage = NSLocalizedString("The username you have selected is already in use.", comment: "Alert message letting the user know that the username they selected is already being used.")
    private static let passwordAlertAttemptedFormat = NSLocalizedString("Previous attempt failed. You have %d attempt(s) left before being logged out. Enter your password:", comment: "Alert message asking user to input their account password correctly")
    static func passwordAlertAttemptedMessage(withNumberOfAttempts numberOfAttempts: UInt) -> String {
        return String.localizedStringWithFormat(passwordAlertAttemptedFormat, numberOfAttempts)
    }
    
    /// Function for creating a localized formatted string based on the incoming error parameter.
    /// The string states the operation couldn't be completed due to the error and displays the error to the user.
    /// It also suggests to contact support should the problem persist.
    ///
    /// - parameter error: The reason for failure
    ///
    /// - returns: Localized formatted string of **Operation failed with error: "%@" If this problem continues, please contact support for further assistance.**
    static func contactSupport(with error: Error) -> String {
        return String.localizedStringWithFormat(NSLocalizedString("Operation failed with error: \"%@\" If this problem continues, please contact support for further assistance.",
                                                                  comment: "Alert Message telling the user we don't immediately know what the problem is and to contact support"), error.localizedDescription)
    }
    
    // MARK: Actions
    static let ok = NSLocalizedString("OK", comment: "Understood")
    static let contact = NSLocalizedString("Contact", comment: "Alert Button verb contact support")
    static let cancel = NSLocalizedString("Cancel", comment: "")
    static let disconnect = NSLocalizedString("Disconnect and Apply", comment: "")
    static let reconnect = NSLocalizedString("Apply and Reconnect", comment: "")
    static let logout = NSLocalizedString("Logout", comment: "")
    static let onDemandConnectedAlertConfirm = NSLocalizedString("Confirm", comment: "Confirm")
    
    // MARK: - Login/Sign-Up
    static let username = NSLocalizedString("Username or Email", comment: "account username")
	static let email = NSLocalizedString("Email", comment: "account email")
    static let password = NSLocalizedString("Password", comment: "account password")
    static let signUpPassword = NSLocalizedString("Enter Your Password", comment: "account password")
    static let signUpReenterPassword = NSLocalizedString("Reenter Your Password", comment: "account password")
    static let signUpUsername = NSLocalizedString("Username", comment: "Placeholder text to indicate the account username should be entered")
    static let signUpEmail = NSLocalizedString("Email", comment: "Placeholder text to indicate the account email should be entered")
    static let signUp = NSLocalizedString("Sign Up", comment: "")
    static let backToLogin = NSLocalizedString("Already have an account? Login", comment: "")
    static let loggingInProgress = NSLocalizedString("Authenticating...", comment: "Static text indicating progress of logging in.")
    static let creatingAccountProgress = NSLocalizedString("Creating Account...", comment: "Static text indicating progress of logging in.")
    static let accountCreated = NSLocalizedString("Your account has successfully been created!", comment: "Account was created successfully.")
    static let accountNotProvisionedTitle = NSLocalizedString("Almost Done", comment: "Title for account not provisioned alert.")
    static let accountNotProvisioned = NSLocalizedString("Your account has not yet been fully provisioned. Please wait a few minutes before attempting to login.", comment: "Account needs to be provisioned.")
    
    //MARK: - Framework Notifications
    // TODO: Move the below strings into the framework to handle
    /*
     * "AccountExpiredMessage" = "Your account is expired. Please update your information, or contact support. You may still attempt to connect.";
     * "VPNConnectionFailedInvalidConfig" = "Invalid VPN Configuration";
     * "VPNConnectionFailedInvalidProtocol" = "Invalid protocol selected";
     * "VPNConnectionFailedNoInternet" = "No Internet Connection. Please check your network settings.";
     *
     */
    /// Localized String of **Your account is expired. Please update your information, or contact support. 
    /// You may still attempt to connect.**
    static let accountExpired = NSLocalizedString("AccountExpiredMessage", comment: "Alert user that their account is expired and they should update their information or contact support to proceed.")
    /// Localized String of **Invalid VPN Configuration**
    static let invalidVPNConfig = NSLocalizedString("VPNConnectionFailedInvalidConfig", comment: "Invalid VPN Configuration")
    /// Localized String of **Invalid protocol selected**
    static let invalidProtocol = NSLocalizedString("VPNConnectionFailedInvalidProtocol", comment: "Invalid Protocol selected")
    /// Localized String of **No Internet Connection. Please check your network settings.**
    static let noInternetWarning = NSLocalizedString("VPNConnectionFailedNoInternet", comment: "Notify the user that there is an issue with their network connectivity.")
    
    
}
