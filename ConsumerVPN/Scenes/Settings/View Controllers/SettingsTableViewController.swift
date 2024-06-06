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
    @IBOutlet weak var killSwitch: UISwitch!
    
    // All labels for theming
    @IBOutlet var labels: [UILabel]!
    
    // All icons for theming
    @IBOutlet var images: [UIImageView]!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .settingsStatusBar
    }
    
    /// VPNKit Variables
    /// This should have a value through dependency injection. If this doesn't have a value, something went wrong and we should crash
    var apiManager : VPNAPIManager!

        
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
        } else {
            protocolSegmentControl.tintColor = .segmentedControlTint
        }
        protocolSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.primaryText], for: .selected)
        protocolSegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.secondaryText], for: .normal)
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        unregisterForNotifications()
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTableViewController.clearSelected), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Listen for VPNKit Notifications
        NotificationCenter.default.addObserver(for: self)
    }
    
    func unregisterForNotifications() {
        let center = NotificationCenter.default
        
        center.removeObserver(for: self)
        center.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
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
        alwaysOnSwitch.setOn(ApiManagerHelper.shared.isOnDemandEnabled, animated: true)
        
        // Set protocol segmented control to currently selected protocol.
        switch ApiManagerHelper.shared.selectedProtocol {
        case .wireGuard:
            protocolSegmentControl.selectedSegmentIndex = 0
        case .ikEv2:
            protocolSegmentControl.selectedSegmentIndex = 1
        case .ipSec:
            protocolSegmentControl.selectedSegmentIndex = 2
        default:
            protocolSegmentControl.selectedSegmentIndex = 0
        }
        configureUIForSelectedState()
        
    }
    
    /// This will handle turning the always on functionality on/off.
    @IBAction func alwaysOnSwitch(_ sender: UISwitch) {
        // 1. Check if user is connected to the VPN
        // 2. If connected, notify user that the change will disconnect from VPN, Apply the changes and then reconnect them to VPN.
        // 3. If not connected, Apply changes and update helper.
        sender.isEnabled = false
        if sender.isOn != ApiManagerHelper.shared.isOnDemandEnabled  {
            if ApiManagerHelper.shared.isConnectedToVPN() {
                let title = LocalizedString.preferencesHeader
                let message = LocalizedString.applyChangeReconnect
                var actions : [UIAlertAction] = []
                
                var action = UIAlertAction(title: LocalizedString.cancel, style: .cancel,handler: { (action) in
                    sender.setOn(!sender.isOn, animated: true)
                    sender.isEnabled = true
                })
                actions.append(action)
               
                action = UIAlertAction(title: LocalizedString.reconnect, style: .default) {  (action) in
                    ProgressSpinnerHelper.shared.showSpinner(on: self.tabBarController?.view ?? self.view)
                    ApiManagerHelper.shared.disconnect()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) { [weak self] in
                        guard let self = self else { return }
                        ProgressSpinnerHelper.shared.showSpinner(on: self.tabBarController?.view ?? self.view)
                        ApiManagerHelper.shared.toggleOnDemand(enable: sender.isOn, reconnect: true) { success in
                            DispatchQueue.main.async {
                                sender.isEnabled = true
                            }
                            
                        }
                    }
                }
                
                actions.append(action)
                
                if !sender.isOn {
                    action = UIAlertAction(title: LocalizedString.disconnect, style: .destructive) {  (action) in
                        ProgressSpinnerHelper.shared.showSpinner(on: self.tabBarController?.view ?? self.view)
                        ApiManagerHelper.shared.disconnect()
                        ApiManagerHelper.shared.setOnDemand(enable: false)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
                            sender.isEnabled = true
                        }
                        
                    }
                    actions.append(action)
                }
                
                let alert = UIAlertController.alert(withTitle: title, message: message, actions: actions, alertType: .alert)
                present(alert, animated: true, completion: nil)
            } else {
                ApiManagerHelper.shared.toggleOnDemand(enable: sender.isOn) { success in
                    DispatchQueue.main.async {
                        sender.isEnabled = true
                    }
                }
            }
        } else {
            sender.isEnabled = true
        }
        
    }
    
    /// This will handle turning the kill switch functionality on/off.
    @IBAction func killSwitch(_ sender: UISwitch) {
        ApiManagerHelper.shared.toggleKillSwitch(enable: sender.isOn)
    }
    
    private func configureUIForSelectedState() {
        killSwitch.isOn = ApiManagerHelper.shared.isKillSwitchOn
        killSwitch.isEnabled = ApiManagerHelper.shared.isSafeToChangeConfiguration()
        alwaysOnSwitch.isEnabled = !ApiManagerHelper.shared.isVPNConnectionInProgress()
        protocolSegmentControl.isEnabled = ApiManagerHelper.shared.isSafeToChangeConfiguration()
    }
    
    /// This will switch the protocol and save the users preference. Currently supported Protocols (IKEv2,IPSec)
    @IBAction func protocolSegmentValueChanged(_ sender: UISegmentedControl) {
        protocolSegmentControl.isEnabled = false
        alwaysOnSwitch.isEnabled = false
        killSwitch.isEnabled = false
        ApiManagerHelper.shared.switchProtocol(index: sender.selectedSegmentIndex)
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
                tableView.deselectRow(at: indexPath, animated: true)
                ApiManagerHelper.shared.logout()
            default:
                break
            }
        case 1: // Connection Settings
            switch indexPath.row {
            case 3:
                ApiManagerHelper.shared.refreshServer { [weak self] success, error in
                    guard let `self` = self else { return  }
                    if success {
                        fadeOut(imageView: checkmarkImageView, usingImage: "checkmark_icon")
                    } else {
                        if let updateServerError = error {
                            present(UIAlertController.contactSupport(with: updateServerError), animated: true, completion: nil)
                        } else {
                            if !ApiManagerHelper.shared.isNetworkReachable() {
                                self.present(UIAlertController.network(), animated: true, completion: nil)
                            }
                        }
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
        ApiManagerHelper.shared.setOnDemand(enable: false)
        
        if let error = notification.object as? Error {
            print("Helper Install Failed with Error - \(error.localizedDescription)")
        }
    }
}

// MARK: - VPNConnectionStatusReporting
extension SettingsTableViewController : VPNConnectionStatusReporting {
    func statusConnectionSucceeded(_ notification: Notification) {
        configureUIForSelectedState()
        ProgressSpinnerHelper.shared.hideSpinner()
    }
    
    func statusConnectionDidDisconnect(_ notification: Notification) {
        configureUIForSelectedState()
        ProgressSpinnerHelper.shared.hideSpinner()
    }
    
    func statusConnectionFailed(_ notification: Notification) {
        if let error = notification.object as? Error {
            print("Connection Failed with Error - \(error.localizedDescription)")
        }
        alwaysOnSwitch.setOn(ApiManagerHelper.shared.isOnDemandEnabled, animated: true)
        configureUIForSelectedState()
    }
    func statusConnectionWillBegin(_ notification: Notification) {
        if self.tabBarController?.selectedIndex == 2 {
            ProgressSpinnerHelper.shared.showSpinner(on: self.tabBarController?.view ?? self.view)
        }
        configureUIForSelectedState()
    }
    func statusConnectionWillDisconnect(_ notification: Notification) {
        if self.tabBarController?.selectedIndex == 2 {
            ProgressSpinnerHelper.shared.showSpinner(on: self.tabBarController?.view ?? self.view)
        }
    }
    
}

extension SettingsTableViewController: VPNConfigurationStatusReporting {
    func statusCurrentProtocolDidChange(_ notification: Notification) {
        ApiManagerHelper.shared.synchronizeConfiguration { success in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let `self` = self else {return}
                self.alwaysOnSwitch.isEnabled = true
                self.protocolSegmentControl.isEnabled = true
                self.killSwitch.isEnabled = true
            }
            
        }
    }
    
    func updateConfigurationFailed(_ notification: Notification) {
        alwaysOnSwitch.setOn(ApiManagerHelper.shared.isOnDemandEnabled, animated: true)
    }
}
// MARK: - VPNServerStatusReporting
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
