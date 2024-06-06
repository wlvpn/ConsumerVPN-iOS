//
//  ApiManagerHelper.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 23/05/24.
//  Copyright © 2024 NetProtect. All rights reserved.
//

import Foundation
import VPNKit
extension Notification.Name {
    static let beginVPNConnection = Notification.Name("VPNConnectionWillBeginNotification")
}

@objc extension NSNotification {
    public static let beginVPNConnection = Notification.Name.beginVPNConnection
}


/// `ApiManagerHelper` is a singleton class responsible for managing VPN API operations such as login, checking network reachability, refreshing location, handling VPN disconnection, and setting encryption.
class ApiManagerHelper: NSObject {
    
    /// The instance of `VPNAPIManager` used to perform API operations.
    var apiManager: VPNAPIManager
    var vpnConfiguration: VPNConfiguration?
    
    /// The shared singleton instance of `ApiManagerHelper`.
    static let shared = ApiManagerHelper()
    
    /// Private initializer to ensure the singleton pattern.
    private override init() {
        self.apiManager =  SDKInitializer.initializeAPIManager(
            withBrandName: Theme.brandName,
            configName: Theme.configName,
            apiKey: Theme.apiKey,
            andSuffix: Theme.usernameSuffix
        )
        self.vpnConfiguration = apiManager.vpnConfiguration
        super.init()
        NotificationCenter.default.addObserver(for: self)
    }
    
    /// Sets the default encryption to 256-bit AES if no encryption is already set.
    func setDefaultEncryption() {
        if vpnConfiguration?.hasOption(forKey: kIKEv2Encryption) == false {
            vpnConfiguration?.setOption(kVPNEncryptionAES256, forKey: kIKEv2Encryption)
        }
    }
    
    func loginWithRetry(forUsername: String, password: String) {
        apiManager.loginWithRetry(forUsername: forUsername, password: password)
    }
    
    func loginWith(forUsername username: String, password: String) {
        apiManager.login(withUsername: username, password: password)
    }
    
    func isUserLogin() -> Bool {
        return apiManager.isLoggedIn()
    }
    
    func isNetworkReachable() -> Bool {
        return apiManager.networkIsReachable
    }
    
    func logout() {
        self.resetOnLogout()
        apiManager.logout()
    }
    
    /// Refreshes the location and calls the completion handler with the result.
    /// - Parameter completion: A closure called with a boolean indicating success or failure.
    func refreshLocation(completion: ((_ success: Bool) -> Void)? = nil) {
        
        apiManager.refreshLocation(completion: { location, error in
            completion?(error == nil)
        })
        
    }
    
    func refreshServer(completion: @escaping (Bool, Error?) -> Void) {
        // Refresh Servers
        // 1) If the network is reachable,
        // a) Refresh the servers if it has been more than 5 minutes since the last successful update OR
        // b) Inform the user the servers are already up to date, otherwise
        // 2) Tell the user to change their network settings
        if apiManager.networkIsReachable {
            // Has it been more than 5 minutes (300 seconds) since the last successful update?
            let lastUpdate = UserDefaults.standard.value(forKey: Theme.lastUpdateKey) as? Date ?? Date.distantPast
            if Date().timeIntervalSince(lastUpdate) > 300 { // Update servers
                apiManager.updateServerList { [weak self] success in
                    DispatchQueue.main.async {
                        guard let `self` = self else { return  }
                        if success {
                            UserDefaults.standard.set(Date(), forKey: Theme.lastUpdateKey)
                            completion(true, nil)
                        } else {
                            UserDefaults.standard.set(nil, forKey: Theme.lastUpdateKey)
                            if !self.apiManager.networkIsReachable { // Contact Support
                                let error = NSError(domain: "com.consumervpn.ios", code: 0 , userInfo: [
                                    NSLocalizedDescriptionKey: "Server Update Failed: No network"
                                ])
                                completion(false, error)
                            } else {
                                let error = NSError(domain: "com.consumervpn.ios", code: 0 , userInfo: [
                                    NSLocalizedDescriptionKey: "Server Update Failed: Unknown"
                                ])
                                completion(false, error)
                            }
                        }
                    }
                }
            } else {
                completion(true, nil)
            }
        } else {
            completion(false, nil)
        }
    }
    
    //MARK: Get City List
    func fetchCities() -> [CityModel] {
        
        if let fetchedCities = apiManager.fetchAllCities() as? [City] {
            
            // Convert the fetchedCities into CityModel objects
            let fetchedCityModels = fetchedCities.compactMap(CityModel.init)
            // Assign the initial data model to both the reference point (cityModels)
            return fetchedCityModels
            
        } else {
            return []
        }
        
    }
    
    private func resetOnLogout() {
        UserDefaults.standard.set(0, forKey: Theme.filterPingRangeKey)
        UserDefaults.standard.set(0, forKey: Theme.sortOptionKey)
        UserDefaults.standard.set(nil, forKey: Theme.lastUpdateKey)
        UserDefaults.standard.synchronize()
    }
    
}

//MARK: Server Status Listner
extension ApiManagerHelper: VPNServerStatusReporting {
    
    func statusServerUpdateSucceeded(_ notification: Notification) {
        UserDefaults.standard.set(Date(), forKey: Theme.lastUpdateKey)
    }
    
    func statusServerUpdateFailed(_ notification: Notification) {
        UserDefaults.standard.set(nil, forKey: Theme.lastUpdateKey)
    }
    
}
