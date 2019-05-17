//
//  DashboardViewController.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/7/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit
import VPNKit


final class DashboardViewController: UIViewController {
    
    // MARK: Constants
    
    // used for width and height since the view is square, in points
    private let loadingCircleSize: CGFloat = 220
    
    // MARK: IBOutlets and Variables
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var locationSelectionButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    
    @IBOutlet weak var connectionDetailsView: UIView!
    @IBOutlet weak var visibleLocationImageView: UIImageView!
    @IBOutlet weak var visibleLocationDescriptionLabel: UILabel!
    @IBOutlet weak var visibleLocationLabel: UILabel!
    @IBOutlet weak var ipAddressImageView: UIImageView!
    @IBOutlet weak var ipAddressDescriptionLabel: UILabel!
    @IBOutlet weak var ipAddressLabel: UILabel!
    
    @IBOutlet weak var shieldImageView: UIImageView!
    @IBOutlet weak var connectedLabel: UILabel!
    
    // MARK: - Custom views
    private let loadingCircle = LoadingCircle()
    
    // Login Coordinator handles the entire login flow
    var loginCoordinator: LoginCoordinator?
	
    // APIManager and VPNConfiguration options
    var apiManager: VPNAPIManager! {
        didSet {
            vpnConfiguration = apiManager.vpnConfiguration
        }
    }

    var vpnConfiguration: VPNConfiguration?
    
    // Used to block UI/show loading animation when server list is
    // being fetched or updated.
    var updatingServers = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccessibilityAndLocalization()
        configureView()
        
        // This notification will need to be removed on deinit of this instance
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.resumeFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(for: self)
        
        checkForLogin()
    }
    
    private func configureView() {
        mapImageView.image = UIImage(named: "dotmap")?.withRenderingMode(.alwaysTemplate)
        mapImageView.tintColor = .appWideTint
        mapImageView.alpha = 0
        
        view.backgroundColor = .viewBackground
        connectButton.tintColor = .appWideTint
        connectButton.layer.borderColor = UIColor.appWideTint.cgColor
        connectButton.layer.cornerRadius = 8.0
        connectButton.layer.borderWidth = 2.0
        
        locationSelectionButton.tintColor = .appWideTint
        
        visibleLocationDescriptionLabel.textColor = .primaryText
        visibleLocationLabel.textColor = .appWideTint
        
        ipAddressDescriptionLabel.textColor = .primaryText
        ipAddressLabel.textColor = .appWideTint
        
        shieldImageView.image = ConnectedShield.imageOfArtboard()
        shieldImageView.alpha = 0
        connectedLabel.alpha = 0
        
        view.addSubview(loadingCircle)
        loadingCircle.translatesAutoresizingMaskIntoConstraints = false
        loadingCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingCircle.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingCircle.widthAnchor.constraint(equalToConstant: loadingCircleSize).isActive = true
        loadingCircle.heightAnchor.constraint(equalToConstant: loadingCircleSize).isActive = true
        loadingCircle.alpha = 0
    }
    
    @objc func resumeFromBackground() {
        updateStatusForState()
    }
    
    /// Helper method responsible for setting the accessibility labels and identifiers as well as localizations with our UI
    private func setupAccessibilityAndLocalization() {
//        settingsButton.accessibilityLabel = AccessibilityLabel.settingsButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: Theme.isInitialLoad) {
        }
        
        // based on the current status of the apiManager's connection, change which state is shown to user
        if apiManager.isConnectedToVPN() {
        } else {
        }
        
        // Update UI animations
        updateStatusForState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ipAddressLabel.text = LocalizedString.loading
        visibleLocationLabel.text = LocalizedString.loading
    }
    
    deinit {
        // stop listening to all notifications in relation to the VPNStatusReporting
        NotificationCenter.default.removeObserver(for: self)
    }
    
    /// This will update the UI for the dashboard depending on the current VPN state.
    ///
    /// - Parameters:
    ///   - state: current connected state, can be set manually.
    ///   - didFail: Bool to determine if it should show failed animation.
    func updateStatusForState(state : VPNConnectionStatus? = nil, didFail : Bool = false) {
        // If no state was set, retrieves apiManager status directly to determine state.
        let connectionStatus = state ?? apiManager.status
        
        // Error occurred, displays error animation and returns
        if didFail {
            return
        }
        
        // sets dashboard status UI and animation for state
        switch connectionStatus {
        case .statusDisconnected:
            setDisconnectedStatus()
        case .statusConnecting:
            setInFluxStatus(connecting: true)
        case .statusDisconnecting:
            setInFluxStatus(connecting: false)
        case .statusConnected:
            setConnectedStatus()
        default:
            print("Not implemented")
        }
    }
    
    private func setDisconnectedStatus() {
        UIView.animate(withDuration: 0.4) {
            self.locationStackView.alpha = 1.0
            self.connectionDetailsView.alpha = 0
            self.mapImageView.alpha = 0
            self.shieldImageView.alpha = 0
            self.loadingCircle.alpha = 0
            self.connectButton.alpha = 1.0
            
            self.connectButton.setTitle("Connect", for: .normal)
            self.connectButton.tintColor = .appWideTint
            self.connectButton.layer.borderColor = UIColor.appWideTint.cgColor
        }
    }
    
    private func setInFluxStatus(connecting: Bool) {
        UIView.animate(withDuration: 0.4) {
            self.locationStackView.alpha = 0
            self.connectionDetailsView.alpha = 0
            self.mapImageView.alpha = 0
            self.shieldImageView.alpha = 0
            self.loadingCircle.alpha = 1.0
            self.connectButton.alpha = 1.0
            
            self.connectButton.setTitle("Disconnect", for: .normal)
            self.connectButton.tintColor = .disconnectRed
            self.connectButton.layer.borderColor = UIColor.disconnectRed.cgColor
        }
        if connecting {
            loadingCircle.spinCycle(for: .connecting, completionDelegate: self)
        } else {
            loadingCircle.spinCycle(for: .disconnecting, completionDelegate: self)
        }
    }
    
    private func lockUIAndSetServersUpdatingStatus() {
        UIView.animate(withDuration: 0.4) {
            self.locationStackView.alpha = 0
            self.connectionDetailsView.alpha = 0
            self.mapImageView.alpha = 0
            self.shieldImageView.alpha = 0
            self.loadingCircle.alpha = 1.0
            self.connectButton.alpha = 0
        }
        
        updatingServers = true
        loadingCircle.spinCycle(for: .loadingServers, completionDelegate: self)
    }
    
    private func setConnectedStatus() {
        UIView.animate(withDuration: 0.4) {
            self.locationStackView.alpha = 0
            self.connectionDetailsView.alpha = 1.0
            self.mapImageView.alpha = 1.0
            self.shieldImageView.alpha = 1.0
            self.loadingCircle.alpha = 0
            self.connectButton.alpha = 1.0
            
            self.connectButton.setTitle("Disconnect", for: .normal)
            self.connectButton.tintColor = .disconnectRed
            self.connectButton.layer.borderColor = UIColor.disconnectRed.cgColor
        }
    }
    
    private func checkForLogin() {
        if vpnConfiguration?.user == nil {
            // No user object means not signed in, so show login view
            let loginCoord = LoginCoordinator(presenter: self, apiManager: apiManager)
            loginCoord.start()
            loginCoordinator = loginCoord
        }
    }
    
    /// This helper method takes the passed in VPNConfiguration object to determine what the current location
    /// string should say when presented to the user. This method is mainly used to format out the number the API
    /// will kick back at times. e.g. "0, New Zealand" to instead become: "New Zealand" or "Loading" if the location
    /// has not been determined yet.
    ///
    /// - Parameter vpnConfiguration: The configuration object for VPN Services
    /// - Returns: A formatted text based on the parameter's location contents to display to the user
    fileprivate func locationString(for vpnConfiguration: VPNConfiguration?) -> String {
        // If the location text does not exist, display loading.
        // If the location text exists, but has a number in the text, display just the country name
        // otherwise, display the received location text
        let locationString = vpnConfiguration?.currentLocation?.location() ?? LocalizedString.loading
        // If a number is found, split the string based on the comma + space ', ' and take the second part
        // if it exists
        if locationString.rangeOfCharacter(from: .decimalDigits) != nil {
            // split the string around the comma + space
            let components = locationString.components(separatedBy: ", ")
            if components.count > 0 {
                return components.last!
            } else {
                return locationString
            }
        } else {
            return locationString
        }
        
    }
    
    fileprivate func showHelperFailedDialog() {
        let alertController = UIAlertController(title: "Install Failure", message: "There was an error installing the VPN configuration. Please try again.", preferredStyle: .alert)
        let reinstallAction = UIAlertAction(title: "Reinstall configuration", style: .default) { action in
            self.apiManager.installHelperAndConnect(onInstall: false)
        }
        alertController.addAction(reinstallAction)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .default)
		alertController.addAction(cancelAction)
		
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction private func selectLocation(sender: UIButton) {
        let serverListVC = ServerListViewController.build(with: apiManager)
        serverListVC.presentedModally = true
        let serverNavC = UINavigationController(rootViewController: serverListVC)
        serverNavC.navigationBar.barStyle = .black
        serverNavC.navigationBar.isTranslucent = false
        present(serverNavC, animated: true, completion: nil)
    }
    
    fileprivate var cityDisplayString: String {
        var displayString = ""
        
        if let vpnConfiguration = vpnConfiguration {
            if let city = vpnConfiguration.city,
                let cityName = city.name {
                displayString.append(cityName + ", ")
            }
            if let country = vpnConfiguration.country,
                let countryName = country.name {
                displayString.append(countryName)
            }
            if vpnConfiguration.city == nil,
                vpnConfiguration.country == nil {
                displayString = LocalizedString.fastestAvailable
            }
        }
        
        return displayString
    }
    
    @IBAction private func connectDisconnectTapped(sender: UIButton) {
        switch apiManager.status {
        case .statusDisconnected, .statusError, .statusFailed, .statusInvalid, .statusDisconnecting:
            // User wishes to connect
            let firstRun = UserDefaults.standard.value(forKey: Theme.firstConnectKey) as? Bool
            if firstRun == nil {
                let privacyVC = PrivacyNoticeViewController.build(with: self)
                present(privacyVC, animated: true, completion: nil)
            } else {
                apiManager.connect()
                updateStatusForState(state: .statusConnecting)
            }
        case .statusConnected, .statusActive, .statusConnecting, .statusReconnecting:
            // User wishes to disconnect
            if let onDemandEnabled = vpnConfiguration?.getOptionForKey(kOnDemandEnabledKey) as? Bool,
                onDemandEnabled != false {
                let alert = UIAlertController(title: LocalizedString.onDemandConnectedAlertTitle, message: LocalizedString.onDemandConnectedAlertMessage, preferredStyle: .alert)
                let cancelAction = UIAlertAction.init(title: LocalizedString.cancel, style: .cancel, handler: nil)
                let confirmAction = UIAlertAction.init(title: LocalizedString.onDemandConnectedAlertConfirm, style: .default, handler: { (UIAlertAction) in
                    self.updateStatusForState(state: .statusDisconnecting)
                    self.vpnConfiguration?.setOption(NSNumber(booleanLiteral: false), forKey: kOnDemandEnabledKey)
                    self.apiManager.installHelperAndConnect(onInstall: false)
                })
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
                present(alert, animated: true, completion: nil)
            } else {
                apiManager.disconnect()
                updateStatusForState(state: .statusDisconnecting)
            }
        case .statusReconnect:
            // This status is only used during OpenVPN connections, which are
            // not possible with NEVPNManager
            print("")
		default:
			break;
        }
    }
}

// MARK: - VPNConnectionStatusReporting
extension DashboardViewController: VPNConnectionStatusReporting {
    
    /// Used to log the connection status of `Will Begin`
    func statusConnectionWillBegin() {
        updateStatusForState(state: .statusConnecting)
    }
    
    /// Used to log the connection status of `Did Begin`
    func statusConnectionDidBegin() {
        // Display indeterminate progress showing that the connection process did begin.
    }
    
    /// Transitions the Dashboard's connected state onto the screen via an animation
    func statusConnectionSucceeded() {
        updateStatusForState(state: .statusConnected)
    }
    
    /// Transitions the Dashboard's connected state off of the screen via an animation
    func statusConnectionDidDisconnect() {
        updateStatusForState(state: .statusDisconnected)
        
        UIView.animate(withDuration: 0.75,
                       animations: {
                        self.view.layoutSubviews()
            },
                       completion: { (finished) in
                        if finished {
                        }
            }
        )
    }
    
    /// This function displays an alert to the user depending on the reason for a failed connection. 
    /// If the reason is something other than a network connection issue, present an alert with the description of the error
    /// and provide the ability to contact support should this problem persist.
    ///
    /// - parameter notification: Notification object kicked back from the VPNKit. The notification's `object` property is an NSError describing the reason for failure
    func statusConnectionFailed(_ notification: Notification) {
        updateStatusForState(didFail: true)
        
        // Removes error animation after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            self.updateStatusForState()
        })
		
		guard let error = notification.object as? Error else {
			print("Connection Failed with No Error")
			return
		}
		
        if apiManager.networkIsReachable { // Contact Support
            present(UIAlertController.contactSupport(with: error), animated: true, completion: nil)
        } else { // Network Connection Issue
            present(UIAlertController.network(), animated: true, completion: nil)
        }
    }
}

// MARK: - VPNConfigurationStatusReporting
extension DashboardViewController : VPNConfigurationStatusReporting {
    func statusCurrentCityDidChange(_ notification: Notification) {
        locationSelectionButton.setTitle(cityDisplayString, for: .normal)
    }
    
    func statusCurrentLocationDidChange(_ notification: Notification) {
        ipAddressLabel.text = vpnConfiguration?.currentLocation?.ipAddress ?? LocalizedString.loading
        visibleLocationLabel.text = cityDisplayString
    }
}

// MARK: - VPNServerStatusReporting
extension DashboardViewController : VPNServerStatusReporting {
    func statusInitialServerUpdateWillBegin() {
        UserDefaults.standard.set(true, forKey: Theme.isInitialLoad)
    }
    
    func statusInitialServerUpdateSucceeded(_ notification: Notification) {
		self.connectButton.isEnabled = true
        UserDefaults.standard.set(false, forKey: Theme.isInitialLoad)
	}
    
    func statusInitialServerUpdateFailed(_ notification: Notification) {
        UserDefaults.standard.set(false, forKey: Theme.isInitialLoad)
    }

    func statusServerUpdateWillBegin() {
        if apiManager.status == .statusDisconnected {
            lockUIAndSetServersUpdatingStatus()
        }
    }
    
    func statusServerUpdateSucceeded(_ notification: Notification) {
        updatingServers = false
		self.connectButton.isEnabled = true
        updateStatusForState()
    }
    
    func statusServerUpdateFailed(_ notification: Notification) {
        updatingServers = false
        updateStatusForState()
    }
}

// MARK: - VPNHelperStatusReporting
extension DashboardViewController : VPNHelperStatusReporting {
    func statusHelperInstallFailed(_ notification: Notification) {
        updateStatusForState()
        showHelperFailedDialog()
    }
    
    // Helper should be installed here
    func statusHelperShouldInstall(_ notification: Notification) {
        apiManager.installHelperAndConnect(onInstall: true)
    }
    
    func statusHelperDidInstall(_ notification: Notification) {
//        apiManager.connect()
    }
}

// MARK: - VPNAccountStatusReporting
extension DashboardViewController: VPNAccountStatusReporting {
    func statusLoginWillBegin() {}
    
    /// - Parameter notification: Notification kicked back from the framework. Holds `Account` information.
    func statusLoginSucceeded(_ notification: Notification) {
        if let _ = loginCoordinator {
            dismiss(animated: true, completion: nil)
            loginCoordinator = nil
            if tabBarController?.selectedIndex != 0 {
                // The dashboard isn't the current active tab, so switch to it
                tabBarController?.selectedViewController = self
            }
        }
        
        updateStatusForState()
		self.connectButton.isEnabled = false
    }
    
    func statusLogoutSucceeded() {
        loginCoordinator = nil
        loginCoordinator = LoginCoordinator(presenter: self, apiManager: apiManager)
        loginCoordinator?.start()
    }
    
    /// Login failures are handled by the Login View Controller
    func statusLoginFailed(_ notification: Notification) {}
    
    func statusAccountExpired(_ notification: Notification) {
        let alertController = UIAlertController(title: "Account Expired", message: "Want to build a VPN app like this? Contact partners@wlvpn.com", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - StoryboardInstantiable
extension DashboardViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        return "Dashboard"
    }
    
    class func build(with apiManager: VPNAPIManager) -> DashboardViewController {
        let dashVC = instantiateInitial()
        dashVC.apiManager = apiManager
        return dashVC
    }
}

// MARK: - Animation Delegate
extension DashboardViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if apiManager.isConnectingToVPN() {
            loadingCircle.spinCycle(for: .connecting, completionDelegate: self)
        } else if apiManager.isDisconnectingFromVPN() {
            loadingCircle.spinCycle(for: .disconnecting, completionDelegate: self)
        } else if updatingServers {
            loadingCircle.spinCycle(for: .loadingServers, completionDelegate: self)
        }
    }
}

extension DashboardViewController: PrivacyNoticeDelegate {
    func userDidAgree() {
        dismiss(animated: true, completion: nil)
        apiManager.connect()
        updateStatusForState(state: .statusConnecting, didFail: false)
        UserDefaults.standard.set(false, forKey: Theme.firstConnectKey)
    }
}
