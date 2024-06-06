//
//  ApiManagerHelper+VPNConfiguration.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 28/05/24.
//  Copyright © 2024 NetProtect. All rights reserved.
//

import Foundation
//MARK: VPN Configuration Update

extension ApiManagerHelper {
    
    var selectedProtocol: VPNProtocol { vpnConfiguration?.selectedProtocol ?? .wireGuard   }
    
    var isOnDemandEnabled: Bool { vpnConfiguration?.onDemandConfiguration?.enabled ?? false }
    
    var isKillSwitchOn: Bool { return vpnConfiguration?.isKillSwitchEnabled ?? false }
    
    func synchronizeConfiguration(completion: ((_ success: Bool) -> Void)? = nil) {
        guard apiManager.isActiveUser else {
            completion?(false)
            return
        }
        
        apiManager.synchronizeConfiguration { success in
            completion?(success)
        }
    }
    
    func isSafeToChangeConfiguration() -> Bool {
        return !(apiManager.isConnectedToVPN() || apiManager.isConnectingToVPN() || apiManager.isDisconnectingFromVPN())
    }
    
    func switchProtocol(index:Int) {
       
        if isSafeToChangeConfiguration() {
            
            switch index {
            case 0:
                vpnConfiguration?.selectedProtocol = VPNProtocol.wireGuard
            case 1:
                vpnConfiguration?.selectedProtocol = VPNProtocol.ikEv2
            case 2:
                vpnConfiguration?.selectedProtocol = VPNProtocol.ipSec
            default:
                break
            }
            
        } else {
            debugPrint("[ConsumerVPN] VPN Is connected, you can't change protocol switch")
        }
    }
    
    func toggleKillSwitch(enable:Bool) {
       
        if isSafeToChangeConfiguration() {
            self.vpnConfiguration?.isKillSwitchEnabled = enable
        } else {
            debugPrint("[ConsumerVPN]  VPN Is connected, you can't change kill switch")
        }
        
    }
    
    //Update ondemand configuration without calling synchronization
    func setOnDemand(enable:Bool) {
       
        if !isVPNConnectionInProgress() {
            guard let onDemand = vpnConfiguration?.onDemandConfiguration else {
                return
            }
            onDemand.enabled = enable
        } else {
            debugPrint("[ConsumerVPN]  VPN Connection is in progress, you can't change onDemand")
        }
        
    }
    
    func toggleOnDemand(enable:Bool, reconnect:Bool = false, completion: ((_ success: Bool) -> Void)? = nil) {
        if !isVPNConnectionInProgress() {
            guard let onDemand = vpnConfiguration?.onDemandConfiguration else {
                if reconnect {
                    self.connect()
                    completion?(false)
                }
                return
            }
            
            onDemand.enabled = enable
            
            if reconnect {
                if enable {
                    self.synchronizeConfiguration { success in
                        self.connectOnDemandVPNIfPossible()
                        completion?(true)
                    }
                } else {
                    self.connect()
                    completion?(true)
                }
            } else {
                if enable {
                    self.synchronizeConfiguration { success in
                        self.connectOnDemandVPNIfPossible()
                        completion?(true)
                    }
                }
            }
        } else {
            completion?(false)
        }
        
    }
    
    func getCurrentLocationString() -> String {
        return vpnConfiguration?.currentLocation?.location() ?? LocalizedString.loading
    }
    
    func getCurrentIPLocationString() -> String {
        return vpnConfiguration?.currentLocation?.ipAddress ?? LocalizedString.loading
    }
    
    func selectServerWith(cityModel: CityModel?) {
        
        if let cityModel = cityModel {
            self.vpnConfiguration?.country = cityModel.city.country
            self.vpnConfiguration?.city = cityModel.city
            self.vpnConfiguration?.server = nil
        } else {
            resetServer()
        }
        
    }
    
    func selectServerWith(country: Country?) {
       
        if let country = country {
            self.vpnConfiguration?.server = nil
            self.vpnConfiguration?.city = nil
            self.vpnConfiguration?.country = country
        } else {
            resetServer()
        }
        
    }
    
    private func resetServer() {
        self.vpnConfiguration?.server = nil
        self.vpnConfiguration?.city = nil
        self.vpnConfiguration?.country = nil
    }
    
    func getCityDisplayString() -> String {
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
    
}

//MARK: VPNConfigurationStatusReporting
extension ApiManagerHelper: VPNConfigurationStatusReporting {

    func updateConfigurationBegin(_ notification: Notification) {
    }
    
    func updateConfigurationFailed(_ notification: Notification) {
    }
    
    func updateConfigurationSucceeded(_ notification: Notification) {
    }
    
}
