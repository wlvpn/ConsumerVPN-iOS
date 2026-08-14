//
//  PacketTunnelProvider.swift
//  ConsumerVPNOpenVPNExtension
//
//  Created by Hitesh on 29/04/25.
//  Copyright © 2025 NetProtect. All rights reserved.
//

import NetworkExtension
import VPKOpenVPNNetworkExtension

class PacketTunnelProvider: OVPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // Add code here to start the process of connecting the tunnel.
        super.startTunnel(options: options, completionHandler: completionHandler)
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        super.stopTunnel(with: reason, completionHandler: completionHandler)
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        super.handleAppMessage(messageData, completionHandler: completionHandler)
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        super.sleep(completionHandler: completionHandler)
    }
    
    override func wake() {
        // Add code here to wake up.
        super.wake()
    }
}
