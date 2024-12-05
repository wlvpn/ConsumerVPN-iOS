# Integrating WireGuard

## Table of contents

1. [Project Setup](#project-setup)
    1. [Add the required permissions for the app](#add-the-required-permissions-for-the-app)
    2. [Integrate WireGuard Network Extension](#integrate-wireguard-network-extension)
        1. [Set Up the Network Extension Target](#set-up-the-network-extension-target)
        2. [Create the Packet Tunnel Provider Class](#create-the-packet-tunnel-provider-class)
        3. [Set Up Main Entry Point](#set-up-main-entry-point)
        4. [Configure Info.plist](#configure-infoplist)
        5. [Configure Entitlements](#configure-entitlements)
2. [Initialize the app](#initialize-the-app)
3. [Connection](#connection)
4. [Notifications](#notifications)
5. [Error handling](#error-handling)
6. [Limitations, Features, and Compatibility](#limitations-features-and-compatibility)


## 1. Project Setup

### 1.1 Add the required permissions for the app

Add the required permissions for the app in the ***project file*** and initialize the app using the Primary Objects.
> Refer to: [VPNKit iOS Guide](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/VPNKit%20iOS%20Guide.md)  
> Refer to: [VPNKit macOS Guide](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/VPNKit%20macOS%20Guide.md)

### 1.2 Integrate WireGuard Network Extension

#### 1.2.1 Set Up the Network Extension Target

**Add a New Target:**
   - In Xcode, go to `File` > `New` > `Target`.
     - For iOS: Select `App Extension` > `Network Extension`.
     - For macOS: Select `System Extension` > `Network Extension`.
   - Choose **Packet Tunnel Provider** as the extension type and name it, such as ***PacketTunnelProvider***.

#### 1.2.2 Create the Packet Tunnel Provider Class

- **File:** `PacketTunnelProvider.swift`
- **Description:** This file defines the `PacketTunnelProvider` class, which inherits from `WGPacketTunnelProvider` provided by the VPKWireGuardExtension framework.

##### Key Points:
- **Initialization:** In the initializer, you can configure settings for traffic monitoring (optional).
- **Traffic Monitoring:** Override `vpnDidReceiveTrafficDataCounter` to handle and debug traffic data if traffic monitoring is enabled.
- **Handshake Timestamp:** Call `getLastHandshake()` to retrieve the timestamp of the last successful handshake and updated network status.
- **Disconnect VPN:** Call `disconnect()` method () to terminate the VPN connection.
- **Bypass Traffic:** Call `bypassAllTraffic()` to bypass all traffic from the VPN connection.

```swift
import NetworkExtension
import VPKWireGuardExtension

class PacketTunnelProvider: WGPacketTunnelProvider {
   
   override init() {
       super.init()
       /*
        Uncomment the following code block to enable traffic monitoring:
        
        // Enable reading packets, must override vpnDidReceiveTrafficDataCounter method if it is enabled.
        self.allowReadPackets = true
        
        // Set the threshold for monitoring downloaded bytes during each interval
        self.readThreshold = UInt64(6_000_000)  // Value in bytes
        
        // Set the threshold for monitoring uploaded bytes during each interval
        self.writeThreshold = UInt64(3_000_000)  // Value in bytes
        
        // Set the time interval in seconds; invoke vpnDidReceiveTrafficDataCounter every interval if the given threshold matches
        self.readPacketTimeInterval = 2 * 60  // Value in seconds
        */
   }
   
   override func vpnDidReceiveTrafficDataCounter(_ counter: TrafficCounter) {
       debugPrint("\(#function) Read: \(counter.read) and Write:\(counter.write)")
   }
   
   // Fetches the last handshake date and network status.
   //
   // This method is designed to be called periodically (e.g., in a timer) to monitor the health of the network connection. 
   // If the time elapsed since the last handshake exceeds a specified threshold, 
   // it indicates potential connectivity issues. In such cases, the method can trigger appropriate actions like disconnecting the tunnel or bypassing traffic.

   func fetchLastHandshake() {
    
        // Asynchronously fetches the last handshake date and network connection status.
        self.getLastHandshake { [weak self] lastHandshakeDate, isConnected in
            debugPrint("\(#function) last handshake completed at: \(lastHandshakeDate) and Network Status:\(isConnected)")
        
            // Calculates the time interval between the current time and the last handshake date.
            // If the interval exceeds the threshold, it indicates a potential issue with the network connection.
            // Implement appropriate actions based on your specific requirements:
            // Option 1: Disconnect the tunnel
            // Option 2: Bypass all traffic if connect on demand is enable for macOS
            // self.isOnDemandEnabled ? self.bypassAllTraffic() : self.disconnect()
            
        }
   }
   
}
```

#### 1.2.3 **Set Up Main Entry Point**

 - **File:** `main.swift`
 - **Description:** This file initializes the system extension mode and starts the dispatch main loop for the Packet Tunnel Provider.

 ```swift
 import Foundation
 import NetworkExtension

 autoreleasepool {
    NEProvider.startSystemExtensionMode()
 }

 dispatchMain()
 ```


#### 1.2.4. Configure `Info.plist`

 - **File:** `Info.plist`
 - **Description:** This property list file configures essential metadata and specifies the `PacketTunnelProvider` class.

##### Key Entries:
  - **`CFBundleDisplayName`**: Name of the extension.
  - **`CFBundleExecutable`**: Executable name.
  - **`CFBundleIdentifier`**: Unique identifier for the extension.
  - **`NetworkExtension`**: Defines the `NEProviderClasses` to use the `PacketTunnelProvider` class.
      Set to reference your Packet Tunnel Provider class, e.g., $(PRODUCT_MODULE_NAME).PacketTunnelProvider.
  - **`NSSystemExtensionUsageDescription`**: Provide a description as your system extension needs access to         certain resources (e.g., "This app requires a system extension for VPN functionality").
 
 iOS Example:
```xml
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.networkextension.packet-tunnel</string>
        <key>NSExtensionPrincipalClass</key>
        <string>$(PRODUCT_MODULE_NAME).PacketTunnelProvider</string>
    </dict>
    <key>com.wireguard.ios.app_group_id</key>
    <string>group.com.xxxxx</string>
 </dict>
 </plist>
 ```

 macOS example:
```xml
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
    <key>CFBundleDisplayName</key>
    <string>WireGuardNetworkExtension</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>$(MARKETING_VERSION)</string>
    <key>CFBundleVersion</key>
    <string>$(CURRENT_PROJECT_VERSION)</string>
    <key>LSMinimumSystemVersion</key>
    <string>$(MACOSX_DEPLOYMENT_TARGET)</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright XXXXX </string>
    <key>NSSystemExtensionUsageDescription</key>
    <string></string>
    <key>NetworkExtension</key>
    <dict>
        <key>NEProviderClasses</key>
        <dict>
            <key>com.apple.networkextension.packet-tunnel</key>
            <string>$(PRODUCT_MODULE_NAME).PacketTunnelProvider</string>
        </dict>
    </dict>
 </dict>
 </plist>
```

#### 1.2.5 Configure Entitlements

 - **File:** `Entitlements.plist`
  - **Description:** This property list file specifies the required entitlements for the Packet Tunnel Provider.

##### Key Entries:
  - **`com.apple.developer.networking.networkextension`**: Specifies the extension type.
  - **`com.apple.security.app-sandbox`**: Enables app sandboxing.
  - **`com.apple.security.network.client`**: Allows network client access.
  - **`com.apple.security.network.server`**: Allows network server access.

 iOS entitlements example:
```xml
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
    <key>com.apple.developer.networking.networkextension</key>
    <array>
        <string>packet-tunnel-provider</string>
    </array>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.xxxxx</string>
    </array>
    <key>com.apple.security.network.client</key>
    <true/>
 </dict>
 </plist>
```

macOS entitlements example:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.networking.networkextension</key>
    <array>
        <string>packet-tunnel-provider-systemextension</string>
    </array>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
</dict>
</plist>
```
 
 Summary:
 1. **Implement the `PacketTunnelProvider` class** with optional traffic monitoring settings.
 2. **Set up the main entry point** to start the system extension mode.
 3. **Configure `Info.plist`** to provide metadata and specify the provider class.
 4. **Configure `Entitlements.plist`** to define required permissions and capabilities for the extension.
 5. **Sign the Network Extension:** Ensure the Network Extension target is signed using your developer certificate. In Signing & Capabilities, add an App Group.



 ## **2. Initialize the app**

 Initialize the app with the provided `APIKey`, `suffix`, `brandName`, and `configName`.
 > Refer to: [Initializers](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Initializers.md)

 ### Primary Objects
 > Refer to: [README MacOS](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/README%20MacOS.md)  
 > Refer to: [README iOS](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/README%20iOS.md)


 ## **3. Connection**

 WireGuard's system extension must be successfully installed in order to perform the connection.

 ### SystemExtension Support (macOS)

 This category provides helper methods for managing the installation, approval, and uninstallation of the WireGuard system extension.

 #### `- (BOOL)systemExtensionInstalled`

 **Returns:**  
 `YES` if the WireGuard system extension is installed, otherwise `NO`.
 **Discussion:**  
  This method determines if the WireGuard system extension is already present on the system. If the extension is installed, there is no need to initiate a new installation.

 #### `- (BOOL)systemExtensionApprovalPending`

 **Returns:**  
 `YES` if the WireGuard system extension is awaiting user approval, otherwise `NO`.CFBundleDisplayName
 **Discussion:**  
 System extensions may require user approval after installation for security reasons. This method checks if such an approval is pending. Applications may need to prompt users to approve the extension in system settings.

 #### `- (void)installSystemExtension`

 **Discussion:**  
 This method starts the installation process for the WireGuard system extension.  
 The outcome of the installation process will be communicated via notifications:
 - `VPNHelperInstallSuccessNotification`: Sent if the installation is successful.
 - `VPNHelperInstallFailedNotification`: Sent if the installation fails. The error information will be provided in the notification.
 
 **Note:**  
 The installation process might require administrative privileges, and users may need to approve the installation manually.

 #### `- (void)uninstallSystemExtension`

 **Discussion:**  
 This method handles the uninstallation of the WireGuard system extension. It ensures that the extension is properly removed from the system, freeing up resources and preventing conflicts.

 **Note:**  
 The uninstallation may also require user interaction or administrative privileges.


 ## **4. Notifications**

 Installation success or failure is reported via system notifications, allowing the app to asynchronously handle the result. You call a framework function and it will perform asynchronous actions. At various points during the action, a notification will be sent out that allows you to respond to the event.

 > Refer to: [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Notifications.md)
 
 
 ## **5. Error handling**

 The API throws an error code and error message. These values are listed in the **Error documentation**.

 > Refer: [Errors](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Errors)


 ## **6. Limitations, Features, and Compatibility**

 ### a. Limitations

 - **Network Extension Entitlements:** macOS apps require special entitlements to use Network Extensions. Ensure you have the necessary permissions from Apple.
 - **Background Execution:** Packet Tunnel Providers may have limited background execution time.
 - **Performance Considerations:** WireGuard is designed for efficiency, but network performance can still be affected by the device's processing power and network conditions.

 ### b. Features

 - **High Performance:** WireGuard is known for its high-speed cryptographic operations and minimal overhead, making it a preferred choice over other protocols.
 - **Simplicity:** The configuration and operation of WireGuard are simpler compared to other VPN protocols, making it easier to set up and manage.
 - **Security:** WireGuard uses state-of-the-art cryptography and is designed to minimize the attack surface.
 - Supports features like **Threat Protection, Multihop, KillSwitch, Connect On demand, Split Tunneling**.

 > For more details:  
 > Refer to: [README MacOS](https://github.com/wlvpn/ConsumerVPN-macOS/blob/main/SDK/README%20MacOS.md) 
 > Refer to: [README iOS](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/README%20iOS.md)

 ### c. Compatibility

 - **Device Compatibility:** WireGuard is compatible with both Intel and Apple Silicon Macs and iOS devices.

 > To get the necessary assets/SDK, please contact support@wlvpn.com
