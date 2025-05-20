//
//  ApiManagerHelper+VPNConnection.swift
//  ConsumerVPN
//
//  Created by Jaydeep Vyas on 28/05/24.
//  Copyright © 2024 NetProtect. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

//MARK: VPN Connection
extension ApiManagerHelper {
    
    func isConnectedToVPN() -> Bool {
        return apiManager.isConnectedToVPN()
    }
    
    func isVPNConnectionInProgress() -> Bool {
        return apiManager.isConnectingToVPN() || apiManager.isDisconnectingFromVPN()
    }
    
    func isDisconnectingFromVPN() -> Bool {
        return apiManager.isDisconnectingFromVPN()
    }
    
    func isConnectingToVPN() -> Bool {
        return apiManager.isConnectingToVPN()
    }
    
    func getVPNConnectionStatus() -> VPNConnectionStatus {
        return apiManager.connectionStatus
    }
    
    func connect() {
        apiManager.connect()
    }
    
    func disconnect() {
        apiManager.disconnect()
    }
    
    func disconnectOnAppTerminate() {
        if apiManager.isConnectedToVPN() {
            if let ondemandConfiguration = vpnConfiguration?.onDemandConfiguration {
                if !ondemandConfiguration.enabled { apiManager.disconnect() }
            } else {
                apiManager.disconnect()
            }
        }
        
        apiManager.cleanup()
    }
    
    func connectOnDemandVPNIfPossible() {
        
        guard let onDemandConfig = vpnConfiguration?.onDemandConfiguration, onDemandConfig.enabled  else {
            return
        }
        DispatchQueue.main.async {
            let currentSSID = NetworkUtils.getCurrentSSID() ?? ""
            
            // Trusted WiFi
            if onDemandConfig.trustWiFi &&
                onDemandConfig.untrustedWiFiNetworks.contains(currentSSID) {
                debugPrint("[ConsumerVPN] [OnDemand] \(#function)  Send notification Trusted WIFI")
                attemptToConnect()
                return
            }
            // Untrusted WiFi
            if !onDemandConfig.trustWiFi &&
                !onDemandConfig.trustedWiFiNetworks.contains(currentSSID) {
                debugPrint("[ConsumerVPN] [OnDemand] \(#function)  Send notification UnTrusted WIFI")
                attemptToConnect()
                return
            }
            
            if !onDemandConfig.trustCellular {
                debugPrint("[ConsumerVPN] [OnDemand] \(#function)  Send notification Trusted Cellular")
                
                attemptToConnect()
            }
            
        }
        
        
        func attemptToConnect() {
            debugPrint("[ConsumerVPN] [OnDemand] \(#function)  send notification")
            NotificationCenter.default.post(name: .beginVPNConnection, object: nil)
            
            let task = URLSession.shared.streamTask(withHostName: vpnConfiguration?.server?.hostname ?? "", port: 443)
            task.resume()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                task.cancel()
            }
        }
        
    }
    
}

//MARK: VpnConnection Status Reporting
extension ApiManagerHelper: VPNConnectionStatusReporting {
    func statusConnectionSucceeded(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function): \(notification)")
        guard let vpnConfiguration = vpnConfiguration else {
            return
        }
        
        // if autobalancing is on, reset the vpn config to nil in those areas
        if vpnConfiguration.usingAutoselectedCity {
            vpnConfiguration.city = nil
        }
    }
    
    func statusConnectionDidDisconnect(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function): \(notification)")
        
    }
    
    func statusConnectionFailed(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function): \(notification)")
        if let error = notification.object as? Error {
            print("Connection Failed with Error - \(error.localizedDescription)")
        }
    }
    
    
    func statusConnectionWillBegin(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function): \(notification)")
    }
    
    func statusConnectionWillDisconnect(_ notification: Notification) {
        debugPrint("[ConsumerVPN] \(#function): \(notification)")
    }
    
}


@objc class NetworkUtils: NSObject {
    
    /// Fetches the SSID of the WI-Fi network currently connected, and nil if not connected to Wi-Fi.
    @objc static func getCurrentSSID() -> String? {
        var currentSSID: String?
        if let interfaces = CNCopySupportedInterfaces() {
            for i in 0..<CFArrayGetCount(interfaces) {
                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
                if unsafeInterfaceData != nil {
                    if let interfaceData = unsafeInterfaceData as? Dictionary<String, Any> {
                        currentSSID = interfaceData["SSID"] as? String
                    }
                }
            }
        }
        
        return currentSSID
    }
    
}
