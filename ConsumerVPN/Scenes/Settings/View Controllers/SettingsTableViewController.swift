//
//  SettingsTableViewController.swift
//  ConsumerVPN
//
//  Created by WLVPN on 9/19/16.
//  Copyright © 2019 NetProtect. All rights reserved.
//

import UIKit
import VPNKit
import LocalAuthentication


class SettingsTableViewController: UITableViewController, VPNStatusReporting {
    
    // Outlets
    @IBOutlet weak var alwaysOnSwitch: UISwitch!
    @IBOutlet weak var protocolSegmentControl: UISegmentedControl!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    // All labels for theming
    @IBOutlet var labels: [UILabel]!
    
    // All icons for theming
    @IBOutlet var images: [UIImageView]!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .settingsStatusBar
    }
    
    /// VPNKit Variables
    /// This should have a value through dependency injection. If this doesn't have a value, something went wrong and we should crash
    var apiManager : VPNAPIManager! {
        didSet {
            vpnConfiguration = apiManager.vpnConfiguration
        }
    }

    var vpnConfiguration: VPNConfiguration?
    
    /// Used when changing onDemand settings while currently connected to reconnect the user after applying changes.
    var shouldReconnect = false
    
    /// Used when the user presses the `refresh servers` button so that we can display the appropriate server update succeeded/failed notifications
    var serverUpdatePressed = false
    
    var loginCoordinator: LoginCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // Setup Colors
        tableView.backgroundColor = .viewBackground
        for label in labels {
            label.textColor = .settingsFont
        }
        
        for image in images {
            image.tintColor = .appWideTint
        }
        
        if #available(iOS 13.0, *) {
            protocolSegmentControl.selectedSegmentTintColor = .segmentedControlTint
        }
        else {
            protocolSegmentControl.tintColor = .segmentedControlTint
        }
        checkmarkImageView.tintColor = .appWideTint
        
        tableView.separatorStyle = .none
        tableView.separatorColor = .cellSeparatorTint
        
        registerNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restoreDefaultSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        clearSelected()
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.clearSelected), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Listen for VPNKit Notifications
        NotificationCenter.default.addObserver(for: self)
    }
    
    /// Clear selected table row
    @objc func clearSelected() {
        let indexPath = tableView.indexPathForSelectedRow
        if let path = indexPath {
            tableView.deselectRow(at: path, animated: true)
        }
    }
    
    /// Load settings from vpn configuration and apply them visually.
    func restoreDefaultSettings() {
        // Set always on switch to match vpn configuration.
        if let alwaysOn = vpnConfiguration?.getOptionForKey(kOnDemandEnabledKey) as? Bool {
            alwaysOnSwitch.setOn(alwaysOn, animated: true)
        }
        
        // Set protocol segmented control to currently selected protocol.
        if vpnConfiguration?.selectedProtocol == VPNProtocol.ikEv2 {
            protocolSegmentControl.selectedSegmentIndex = 0
        } else if vpnConfiguration?.selectedProtocol == VPNProtocol.ipSec {
            protocolSegmentControl.selectedSegmentIndex = 1
        }
    }
    
    /// This will handle turning the always on functionality on/off.
    @IBAction func alwaysOnSwitch(_ sender: UISwitch) {
        // 1. Check if user is connected to the VPN
        // 2. If connected, notify user that the change will disconnect from VPN, Apply the changes and then reconnect them to VPN.
        // 3. If not connected, Apply changes and update helper.
        if apiManager.status == VPNConnectionStatus.statusConnected || apiManager.status == VPNConnectionStatus.statusActive {
            let title = LocalizedString.preferencesHeader
            let message = LocalizedString.applyChangeReconnect
            var actions : [UIAlertAction] = []
            
            var action = UIAlertAction(title: LocalizedString.cancel, style: .cancel,handler: { (action) in
                sender.setOn(!sender.isOn, animated: true)
            })
            actions.append(action)
           
            action = UIAlertAction(title: LocalizedString.reconnect, style: .default,handler: { (action) in
                
                self.shouldReconnect = true
                self.vpnConfiguration?.setOption(NSNumber.init(booleanLiteral: sender.isOn), forKey: kOnDemandEnabledKey)
                self.apiManager.installHelperAndConnect(onInstall: true)
            })
            actions.append(action)
            
            if !sender.isOn {
                action = UIAlertAction(title: LocalizedString.disconnect, style: .destructive,handler: { (action) in
                    self.apiManager.disconnect()
                    self.vpnConfiguration?.setOption(NSNumber.init(booleanLiteral: sender.isOn), forKey: kOnDemandEnabledKey)
                    self.apiManager.installHelperAndConnect(onInstall: false)
                })
                actions.append(action)
            }
            
            let alert = UIAlertController.alert(withTitle: title, message: message, actions: actions, alertType: .alert)
            present(alert, animated: true, completion: nil)
        } else {
            vpnConfiguration?.setOption(NSNumber.init(booleanLiteral: sender.isOn), forKey: kOnDemandEnabledKey)
            apiManager.installHelperAndConnect(onInstall: false)
        }
    }
    
    /// This will switch the protocol and save the users preference. Currently supported Protocols (IKEv2,IPSec)
    @IBAction func protocolSegmentValueChanged(_ sender: UISegmentedControl) {
        func switchSelectedProtocol() {
            // Set protocol based on user selection
            switch sender.selectedSegmentIndex {
            case 0:
                vpnConfiguration?.selectedProtocol = VPNProtocol.ikEv2
            case 1:
                vpnConfiguration?.selectedProtocol = VPNProtocol.ipSec
            default:
                break
            }
            
            // Install helper to apply changes
            if shouldReconnect {
                apiManager.installHelperAndConnect(onInstall: true)
            }
        }
        
        // 1. Check if user is connected to the VPN
        // 2. If connected, notify user that the change will disconnect from VPN, Apply the changes and then reconnect them to VPN.
        // 3. If not connected, Apply changes and update helper.
        if apiManager.status == VPNConnectionStatus.statusConnected || apiManager.status == VPNConnectionStatus.statusActive {
            
            let title = LocalizedString.preferencesHeader
            let message = LocalizedString.applyChangeReconnect
            var actions : [UIAlertAction] = []
            
            var action = UIAlertAction(title: LocalizedString.cancel, style: .cancel,handler: { (action) in
                sender.selectedSegmentIndex = 1 - sender.selectedSegmentIndex
            })
            actions.append(action)
            
            action = UIAlertAction(title: LocalizedString.reconnect, style: .default,handler: { (action) in
                self.shouldReconnect = true
                switchSelectedProtocol()
            })
            actions.append(action)
            
            action = UIAlertAction(title: LocalizedString.disconnect, style: .destructive,handler: { (action) in
                
                // Get always on switch from vpn configuration.
                if let alwaysOn = self.vpnConfiguration?.getOptionForKey(kOnDemandEnabledKey) as? Bool {
                    
                    // If Always On enabled, notify user that always on will be disabled if they decide to apply the changes.
                    if alwaysOn {
                        let alert = UIAlertController(title: LocalizedString.onDemandConnectedAlertTitle, message: LocalizedString.onDemandConnectedAlertMessage, preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction.init(title: LocalizedString.cancel, style: .cancel, handler: { (action) in
                            sender.selectedSegmentIndex = 1 - sender.selectedSegmentIndex
                        })
                        
                        let confirmAction = UIAlertAction.init(title: LocalizedString.onDemandConnectedAlertConfirm, style: .default, handler: { (UIAlertAction) in
                            self.apiManager.disconnect()
                            switchSelectedProtocol()
                            
                            self.vpnConfiguration?.setOption(NSNumber.init(booleanLiteral: false), forKey: kOnDemandEnabledKey)
                            self.alwaysOnSwitch.isOn = false
                            self.apiManager.installHelperAndConnect(onInstall: false)
                        })
                        
                        alert.addAction(cancelAction)
                        alert.addAction(confirmAction)
                        
                        self.present(alert, animated: true, completion: nil)
                        
                        return
                    }
                }
                
                self.apiManager.disconnect()
                switchSelectedProtocol()
            })
            actions.append(action)
            
            let alert = UIAlertController.alert(withTitle: title, message: message, actions: actions, alertType: .alert)
            present(alert, animated: true, completion: nil)
        } else {
            switchSelectedProtocol()
        }
    }
    
    func fadeOut(imageView: UIImageView, usingImage imageName:String) {
        imageView.image = UIImage(named: imageName)
        UIView.animate(withDuration: 0.5, animations: {
            imageView.alpha = 1
        }) { (completed) in
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
                UIView.animate(withDuration: 0.8, animations: {
                    imageView.alpha = 0
                })
            })
        }
    }
}

// MARK: - TableView Delegate Methods
extension SettingsTableViewController {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .viewBackground
        cell.accessoryView?.tintColor = .appWideTint
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .settingsFont
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 1:
                // Logout
                apiManager.logout()
            default:
                break
            }
        case 1: // Connection Settings
            switch indexPath.row {
            case 2: // Refresh Servers
                // 1) If the network is reachable,
                    // a) Refresh the servers if it has been more than 5 minutes since the last successful update OR
                    // b) Inform the user the servers are already up to date, otherwise
                // 2) Tell the user to change their network settings
                
                if apiManager.networkIsReachable {
                    // Has it been more than 5 minutes (300 seconds) since the last successful update?
                    let lastUpdate = UserDefaults.standard.value(forKey: Theme.lastUpdateKey) as? Date ?? Date.distantPast
                    if Date().timeIntervalSince(lastUpdate) > 300 { // Update servers
                        serverUpdatePressed = true
                        apiManager.updateServerList()
                    } else {
                        fadeOut(imageView: checkmarkImageView, usingImage: "checkmark_icon")
                    }
                } else { // Change Network Settings
                    // This is run on the main thread because for some reason without it, it takes forever for the alert to show (WTF?)
                    DispatchQueue.main.async {
                        self.present(UIAlertController.network(), animated: true, completion: nil)
                    }
                    
                }
            default:
                break
            }
        default:
            break
        }
    }
}

// MARK: - VPNHelperStatusReporting
extension SettingsTableViewController : VPNHelperStatusReporting {
    func statusHelperInstallFailed(_ notification: Notification) {
        alwaysOnSwitch.setOn(false, animated: true)
        vpnConfiguration?.setOption(false, forKey: kOnDemandEnabledKey)
        
        if let error = notification.object as? Error {
            print("Helper Install Failed with Error - \(error.localizedDescription)")
        }
    }
}

// MARK: - VPNConnectionStatusReporting
extension SettingsTableViewController : VPNConnectionStatusReporting {
    func statusConnectionSucceeded(_ notification: Notification) {
        guard let vpnConfiguration = vpnConfiguration else {
            return
        }
        
        // if autobalancing is on, reset the vpn config to nil in those areas
        if vpnConfiguration.usingAutoselectedCity {
            vpnConfiguration.city = nil
        }
    }
    
    func statusConnectionDidDisconnect(_ notification: Notification) {
        if shouldReconnect {
            shouldReconnect = false
            apiManager.connect()
        }
    }
    
    func statusConnectionFailed(_ notification: Notification) {
        if let error = notification.object as? Error {
            print("Connection Failed with Error - \(error.localizedDescription)")
        }
        
        alwaysOnSwitch.setOn(false, animated: true)
    }
    
}

// MARK: - VPNServerStatusReporting
extension SettingsTableViewController: VPNServerStatusReporting {
    
    func statusServerUpdateSucceeded(_ notification: Notification) {
        if serverUpdatePressed {
            // Set to false in the scenario the user tapped the `refresh servers` button to not show any more notifications unless pressed again
            serverUpdatePressed = false
            
            // Since we succeeded, save out this time stamp to user defaults
            UserDefaults.standard.set(Date(), forKey: Theme.lastUpdateKey)
            
            fadeOut(imageView: checkmarkImageView, usingImage: "checkmark_icon")
        }
    }
    
    func statusServerUpdateFailed(_ notification: Notification) {
        if serverUpdatePressed { // Only display something if the user manually attempted refresh
            
            // 1) If the network is reachable, tell the user they should contact support, otherwise
            // 2) Tell them to change their network settings (This should never happen since we're responding to this when refresh is selected)
            if apiManager.networkIsReachable { // Contact Support
                
                guard let error = notification.object as? Error else {
                    print("Server Update Failed with No Error")
                    return
                }
				
                // This alert is to inform the user to contact support
                present(UIAlertController.contactSupport(with: error), animated: true, completion: nil)
                
            } else { // Change Settings
                present(UIAlertController.network(), animated: true, completion: nil)
            }
        }
        
        // Set to false in the scenario the user tapped the `refresh servers` button to not show any more notifications unless pressed again
        serverUpdatePressed = false
        
        // Since we failed, erase the last successful update
        UserDefaults.standard.set(nil, forKey: Theme.lastUpdateKey)
    }
}

extension SettingsTableViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        return "Settings"
    }
    
    class func build(with apiManager: VPNAPIManager) -> SettingsTableViewController {
        let settingsVC = instantiateInitial()
        settingsVC.apiManager = apiManager
        return settingsVC
    }
}

