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
	
	// APIManager
	var apiManager: VPNAPIManager!
	
	
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
        connectButton.layer.cornerRadius = 8.0
        connectButton.layer.borderWidth = 2.0
		setConnectButton()
		
		locationSelectionLabel.textColor = .primaryFont
		
		locationSelectionButton.tintColor = .appWideTint
		
		visibleLocationImageView.tintColor = .appWideTint
		visibleLocationDescriptionLabel.textColor = .primaryText
		visibleLocationLabel.textColor = .secondaryText
		
		ipAddressImageView.tintColor = .appWideTint
		ipAddressDescriptionLabel.textColor = .primaryText
		ipAddressLabel.textColor = .secondaryText
		
        shieldImageView.image = ApiManagerHelper.shared.isConnectedToVPN() ? ConnectedShield.imageOfArtboard() : DisconnectedShield.imageOfArtboard()
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
		
        ipAddressLabel.text = ApiManagerHelper.shared.getCurrentIPLocationString()
        visibleLocationLabel.text = ApiManagerHelper.shared.getCityDisplayString()
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
        let connectionStatus = state ?? ApiManagerHelper.shared.getVPNConnectionStatus()
        debugPrint("[ConsumerVPN] \(#function) \(connectionStatus.rawValue)")
		// Error occurred, displays error animation and returns
		if didFail {
			return
		}
		
		// sets dashboard status UI and animation for state
		switch connectionStatus {
		case .statusDisconnected:
            setDisconnectedStatus()
		case .statusConnecting:
            self.connectButton.isHidden = true
            setInFluxStatus(connecting: true)
        case .statusDisconnecting:
            self.connectButton.isHidden = true
			setInFluxStatus(connecting: false)
		case .statusConnected:
			setConnectedStatus()
		default:
            self.connectButton.isHidden = false
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
            self.setConnectButton()
        } completion: { [weak self] success in
            guard let self = self else { return  }
            self.connectButton.isHidden = false
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
        }
    }
	
	private func setInFluxStatus(connecting: Bool) {
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
		UIView.animate(withDuration: 0.4) {
			self.locationStackView.alpha = 0
			self.connectionDetailsView.alpha = 0
			self.mapImageView.alpha = 0
			self.shieldImageView.alpha = 0
			self.loadingCircle.alpha = 1.0
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
			self.ipAddressLabel.text = ApiManagerHelper.shared.getCurrentIPLocationString()
            self.visibleLocationLabel.text = ApiManagerHelper.shared.getCityDisplayString()
            self.setDisconnectButton()
        } completion: { [weak self] success in
            guard let self = self else { return  }
            self.connectButton.isHidden = false
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
        }
	}
	
    private func setDisconnectButton() {
        self.connectButton.setTitle("Disconnect", for: .normal)
        self.connectButton.setTitleColor(.disconnectButtonText, for: .normal)
        self.connectButton.tintColor = .disconnectButtonText
        self.connectButton.layer.borderColor = UIColor.disconnectButtonBorder.cgColor
        self.connectButton.backgroundColor = .disconnectButtonBg
        self.connectButton.alpha = 1.0
    }
    
    private func setConnectButton() {
        self.connectButton.setTitle("Connect", for: .normal)
        self.connectButton.setTitleColor(.connectButtonText, for: .normal)
        self.connectButton.tintColor = .connectButtonText
        self.connectButton.layer.borderColor = UIColor.connectButtonBorder.cgColor
        self.connectButton.backgroundColor = .connectButtonBg
        self.connectButton.alpha = 1.0
    }
    
	
	
	fileprivate func showConfigurationUpdateFailedDialog() {
		let alertController = UIAlertController(title: "Configuration Failure",
                                                message: "There was an error installing the VPN configuration. Please try again.",
                                                preferredStyle: .alert)
		let reinstallAction = UIAlertAction(title: "Reinstall configuration", style: .default) { action in
            ApiManagerHelper.shared.synchronizeConfiguration()
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
	
	
	@IBAction private func connectDisconnectTapped(sender: UIButton) {
        
        switch ApiManagerHelper.shared.getVPNConnectionStatus() {
			
            case .statusDisconnected, .statusError, .statusInvalid, .statusDisconnecting:
			// User wishes to connect
                delegate.userRequestedConnection(from: self)
			
            case .statusConnected, .statusActive, .statusConnecting, .statusReconnecting:
            // User wishes to disconnect
            if ApiManagerHelper.shared.isOnDemandEnabled {
                    let alert = UIAlertController(title: LocalizedString.onDemandConnectedAlertTitle, message: LocalizedString.onDemandConnectedAlertMessage, preferredStyle: .alert)
                    let cancelAction = UIAlertAction.init(title: LocalizedString.cancel, style: .cancel, handler: nil)
                    let confirmAction = UIAlertAction.init(title: LocalizedString.onDemandConnectedAlertConfirm, style: .default, handler: { (UIAlertAction) in
                        self.updateStatusForState(state: .statusDisconnecting)
                        ApiManagerHelper.shared.disconnect()
                        ApiManagerHelper.shared.setOnDemand(enable: false)
                    })
                    alert.addAction(cancelAction)
                    alert.addAction(confirmAction)
                    present(alert, animated: true, completion: nil)
                } else {
                    ApiManagerHelper.shared.disconnect()
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
        self.connectButton.isHidden = true
		// Display indeterminate progress showing that the connection process did begin.
	}
	
	/// Transitions the Dashboard's connected state onto the screen via an animation
	func statusConnectionSucceeded(_ notification: Notification) {
		updateStatusForState(state: .statusConnected)
	}
	
	/// Transitions the Dashboard's connected state off of the screen via an animation
	func statusConnectionDidDisconnect(_ notification: Notification) {
		updateStatusForState(state: .statusDisconnected)
        ApiManagerHelper.shared.refreshLocation()
        
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
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
		updateStatusForState(didFail: true)
		
		// Removes error animation after 5 seconds
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: { [weak self] in
			self?.updateStatusForState()
		})
		
		guard let error = notification.object as? Error else {
			print("Connection Failed with No Error")
			return
		}
		
        if ApiManagerHelper.shared.isNetworkReachable() { // Contact Support
			present(UIAlertController.contactSupport(with: error), animated: true, completion: nil)
		} else { // Network Connection Issue
			present(UIAlertController.network(), animated: true, completion: nil)
		}
	}
    
    func updateConfigurationBegin(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        ProgressSpinnerHelper.shared.showSpinner(on: self.tabBarController!.view)
    }
    
    func updateConfigurationSucceeded(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        ProgressSpinnerHelper.shared.hideSpinner()
    }
    
    func updateConfigurationFailed(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        ProgressSpinnerHelper.shared.hideSpinner()
        updateStatusForState()
        showConfigurationUpdateFailedDialog()
    }
}

// MARK: - VPNConfigurationStatusReporting
extension DashboardViewController : VPNConfigurationStatusReporting {
	func statusCurrentCityDidChange(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        locationSelectionButton.setTitle(ApiManagerHelper.shared.getCityDisplayString(), for: .normal)
	}
	
	func statusCurrentLocationDidChange(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        ipAddressLabel.text = ApiManagerHelper.shared.getCurrentIPLocationString()
		visibleLocationLabel.text = ApiManagerHelper.shared.getCityDisplayString()
	}
}

// MARK: - VPNServerStatusReporting
extension DashboardViewController : VPNServerStatusReporting {
    
	func statusServerUpdateWillBegin(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        updatingServers = true
        connectButton.isHidden = true
        UserDefaults.standard.set(false, forKey: Theme.isInitialLoad)
        if ApiManagerHelper.shared.getVPNConnectionStatus() == .statusDisconnected {
			lockUIAndSetServersUpdatingStatus()
		}
	}
	
	func statusServerUpdateSucceeded(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function)")
        
        if !UserDefaults.standard.bool(forKey: Theme.isInitialLoad) {
            ApiManagerHelper.shared.synchronizeConfiguration { success in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self  else { return }
                    self.connectButton.isHidden = !success
                }
            }
        }
        
        updatingServers = false
        updateStatusForState()
        UserDefaults.standard.set(true, forKey: Theme.isInitialLoad)
	}
	
	func statusServerUpdateFailed(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        if !UserDefaults.standard.bool(forKey: Theme.isInitialLoad) {
            return
        }
        UserDefaults.standard.set(true, forKey: Theme.isInitialLoad)
		updatingServers = false
		updateStatusForState()
	}
    
}

// MARK: - VPNAccountStatusReporting
extension DashboardViewController: VPNAccountStatusReporting {
	func statusLoginWillBegin(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
    }
	
	/// - Parameter notification: Notification kicked back from the framework. Holds `Account` information.
	func statusLoginSucceeded(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        onLogin()
	}
    
    func statusAutomaticLoginSuceeded(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
        onLogin()
    }
    
    func onLogin() {
        if let _ = loginCoordinator {
            dismiss(animated: true, completion: nil)
            loginCoordinator = nil
            if tabBarController?.selectedIndex != 0 {
                // The dashboard isn't the current active tab, so switch to it
                tabBarController?.selectedViewController = self
            }
        }
        
        updateStatusForState()
    }
	
	/// Login failures are handled by the Login View Controller
	func statusLoginFailed(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
    }
    
	func statusAccountExpired(_ notification: Notification) {
        ProgressSpinnerHelper.shared.hideSpinner()
        debugPrint("[ConsumerVPN] \(#function) \(notification)")
		let alertController = UIAlertController(title: "Account Expired", message: "Want to build a VPN app like this? Contact partners@wlvpn.com", preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(okAction)
		present(alertController, animated: true, completion: nil)
	}
    
    func statusLogoutWillBegin(_ notification: Notification) {
        ProgressSpinnerHelper.shared.showSpinner(on: self.tabBarController!.view)
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
        if ApiManagerHelper.shared.isConnectingToVPN() {
			loadingCircle.spinCycle(for: .connecting, completionDelegate: self)
		} else if ApiManagerHelper.shared.isDisconnectingFromVPN() {
			loadingCircle.spinCycle(for: .disconnecting, completionDelegate: self)
		} else if updatingServers {
			loadingCircle.spinCycle(for: .loadingServers, completionDelegate: self)
		}
	}
}
