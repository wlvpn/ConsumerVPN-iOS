//
//  DashboardViewController.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/7/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit
import VPNKit

protocol DashboardViewControllerDelegate {
	func userRequestedConnection(from: DashboardViewController)
}

final class DashboardViewController: UIViewController {
	
	// MARK: Constants
	
	// used for width and height since the view is square, in points
	private let loadingCircleSize: CGFloat = 220
	
	// MARK: IBOutlets and Variables
	@IBOutlet weak var mapImageView: UIImageView!
	@IBOutlet weak var locationStackView: UIStackView!
	@IBOutlet weak var locationSelectionLabel: UILabel!
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
    
    @IBOutlet weak var mapIphoneConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapIpadConstraint: NSLayoutConstraint!
	
	// MARK: - Custom views
	private let loadingCircle = LoadingCircle()
	
	// Login Coordinator handles the entire login flow
	var loginCoordinator: LoginCoordinator?
	
	var delegate: DashboardViewControllerDelegate!
	
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
	
    var shouldreconnectAfterConfigUpdate: Bool = false
    
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .dashboardStatusBar
	}
	
	// MARK: - Lifecycle Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupAccessibilityAndLocalization()
		configureView()
		
		// This notification will need to be removed on deinit of this instance
		NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.resumeFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
		NotificationCenter.default.addObserver(for: self)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setNeedsStatusBarAppearanceUpdate()
	}
	
	private func configureView() {
		mapImageView.image = UIImage(named: "dotmap")?.withRenderingMode(.alwaysTemplate)
		mapImageView.tintColor = .appWideTint
		mapImageView.alpha = 0
		
		view.backgroundColor = .viewBackground
		
		connectButton.setTitleColor(.connectButtonText, for: .normal)
		connectButton.tintColor = .connectButtonText
		connectButton.layer.borderColor = UIColor.connectButtonBorder.cgColor
		connectButton.backgroundColor = .connectButtonBg
		connectButton.layer.cornerRadius = 8.0
		connectButton.layer.borderWidth = 2.0
		
		locationSelectionLabel.textColor = .primaryFont
		
		locationSelectionButton.tintColor = .appWideTint
		
		visibleLocationImageView.tintColor = .appWideTint
		visibleLocationDescriptionLabel.textColor = .primaryText
		visibleLocationLabel.textColor = .secondaryText
		
		ipAddressImageView.tintColor = .appWideTint
		ipAddressDescriptionLabel.textColor = .primaryText
		ipAddressLabel.textColor = .secondaryText
		
		shieldImageView.image = apiManager.isConnectedToVPN() ? ConnectedShield.imageOfArtboard() : DisconnectedShield.imageOfArtboard()
		shieldImageView.alpha = 1
		connectedLabel.alpha = 0
		
		view.addSubview(loadingCircle)
		loadingCircle.translatesAutoresizingMaskIntoConstraints = false
		loadingCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		loadingCircle.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		loadingCircle.widthAnchor.constraint(equalToConstant: loadingCircleSize).isActive = true
		loadingCircle.heightAnchor.constraint(equalToConstant: loadingCircleSize).isActive = true
		loadingCircle.alpha = 0
        
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        
        mapIpadConstraint.isActive = isIpad
        mapIphoneConstraint.isActive = !isIpad
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
			self.shieldImageView.image = DisconnectedShield.imageOfArtboard()
			self.shieldImageView.alpha = 1
			self.loadingCircle.alpha = 0
			self.connectButton.alpha = 1.0
			
			self.connectButton.setTitle("Connect", for: .normal)
			self.connectButton.setTitleColor(.connectButtonText, for: .normal)
			self.connectButton.tintColor = .connectButtonText
			self.connectButton.layer.borderColor = UIColor.connectButtonBorder.cgColor
			self.connectButton.backgroundColor = .connectButtonBg
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
			self.connectButton.setTitleColor(.disconnectButtonText, for: .normal)
			self.connectButton.tintColor = .disconnectButtonText
			self.connectButton.layer.borderColor = UIColor.disconnectButtonBorder.cgColor
			self.connectButton.backgroundColor = .disconnectButtonBg
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
			self.shieldImageView.image = ConnectedShield.imageOfArtboard()
			self.shieldImageView.alpha = 1.0
			self.loadingCircle.alpha = 0
			self.connectButton.alpha = 1.0
			
			self.connectButton.setTitle("Disconnect", for: .normal)
			self.connectButton.setTitleColor(.disconnectButtonText, for: .normal)
			self.connectButton.tintColor = .disconnectButtonText
			self.connectButton.layer.borderColor = UIColor.disconnectButtonBorder.cgColor
			self.connectButton.backgroundColor = .disconnectButtonBg
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
	
	fileprivate func showConfigurationUpdateFailedDialog() {
		let alertController = UIAlertController(title: "Configuration Failure",
                                                message: "There was an error installing the VPN configuration. Please try again.",
                                                preferredStyle: .alert)
		let reinstallAction = UIAlertAction(title: "Reinstall configuration", style: .default) { action in
			self.apiManager.synchronizeConfiguration()
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
			
            case .statusDisconnected, .statusError, .statusInvalid, .statusDisconnecting:
			// User wishes to connect
                delegate.userRequestedConnection(from: self)
			
            case .statusConnected, .statusActive, .statusConnecting, .statusReconnecting:
            // User wishes to disconnect
                if let onDemandEnabled = vpnConfiguration?.onDemandConfiguration?.enabled,
                   onDemandEnabled {
                    let alert = UIAlertController(title: LocalizedString.onDemandConnectedAlertTitle, message: LocalizedString.onDemandConnectedAlertMessage, preferredStyle: .alert)
                    let cancelAction = UIAlertAction.init(title: LocalizedString.cancel, style: .cancel, handler: nil)
                    let confirmAction = UIAlertAction.init(title: LocalizedString.onDemandConnectedAlertConfirm, style: .default, handler: { (UIAlertAction) in
                        self.updateStatusForState(state: .statusDisconnecting)
                        self.vpnConfiguration?.onDemandConfiguration?.enabled = false
                        self.apiManager.disconnect()
                        self.apiManager.synchronizeConfiguration()
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
	func statusConnectionWillBegin(_ notification: Notification) {
		updateStatusForState(state: .statusConnecting)
	}
	
	/// Used to log the connection status of `Did Begin`
	func statusConnectionDidBegin(_ notification: Notification) {
		// Display indeterminate progress showing that the connection process did begin.
	}
	
	/// Transitions the Dashboard's connected state onto the screen via an animation
	func statusConnectionSucceeded(_ notification: Notification) {
		updateStatusForState(state: .statusConnected)
	}
	
	/// Transitions the Dashboard's connected state off of the screen via an animation
	func statusConnectionDidDisconnect(_ notification: Notification) {
		updateStatusForState(state: .statusDisconnected)
        apiManager.refreshLocation()
        
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
    
    func updateConfigurationSucceeded(_ notification: Notification) {
        if shouldreconnectAfterConfigUpdate {
            shouldreconnectAfterConfigUpdate = false
            DispatchQueue.main.async { self.apiManager.connect() }
        }
    }
    
    func updateConfigurationFailed(_ notification: Notification) {
        updateStatusForState()
        showConfigurationUpdateFailedDialog()
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
	func statusInitialServerUpdateWillBegin(_ notification: Notification) {
		UserDefaults.standard.set(true, forKey: Theme.isInitialLoad)
	}
	
	func statusInitialServerUpdateSucceeded(_ notification: Notification) {
		self.connectButton.isEnabled = true
		UserDefaults.standard.set(false, forKey: Theme.isInitialLoad)
        apiManager.updateServerList()
	}
	
	func statusInitialServerUpdateFailed(_ notification: Notification) {
		UserDefaults.standard.set(false, forKey: Theme.isInitialLoad)
	}
	
	func statusServerUpdateWillBegin(_ notification: Notification) {
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

// MARK: - VPNAccountStatusReporting
extension DashboardViewController: VPNAccountStatusReporting {
	func statusLoginWillBegin(_ notification: Notification) {}
	
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
	
	/// Login failures are handled by the Login View Controller
	func statusLoginFailed(_ notification: Notification) {}
	
	func statusAccountExpired(_ notification: Notification) {
		let alertController = UIAlertController(title: "Account Expired", message: "Want to build a VPN app like this? Contact partners@wlvpn.com", preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(okAction)
		present(alertController, animated: true, completion: nil)
	}
    
    func statusLoginServerUpdateWillBegin(_ notification: Notification) {
        UserDefaults.standard.set(true, forKey: Theme.isInitialLoad)
        if apiManager.status == .statusDisconnected {
            lockUIAndSetServersUpdatingStatus()
        }
    }
    
    func statusLoginServerUpdateSucceeded(_ notification: Notification) {
        
        UserDefaults.standard.set(false, forKey: Theme.isInitialLoad)
        
        updatingServers = false
        connectButton.isEnabled = true
        updateStatusForState()
    }
    
    func statusLoginServerUpdateFailed(_ notification: Notification) {
        updatingServers = false
        UserDefaults.standard.set(false, forKey: Theme.isInitialLoad)
        updateStatusForState()
    }
}

// MARK: - StoryboardInstantiable
extension DashboardViewController: StoryboardInstantiable {
	
	static var storyboardName: String {
		return "Dashboard"
	}
	
	class func build(with apiManager: VPNAPIManager, delegate: DashboardViewControllerDelegate) -> DashboardViewController {
		let dashVC = instantiateInitial()
		dashVC.apiManager = apiManager
		dashVC.delegate = delegate
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
