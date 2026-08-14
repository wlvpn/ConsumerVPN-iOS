# Integrating OpenVPN+NE

## Minimum OS Support

Ensure your app targets the following minimum OS versions to use OpenVPN with Network Extension:

- **iOS**: 15.0 or later  
- **macOS**: 12.4 or later  
- **tvOS**: 18.0 or later  

## Table of contents

1. [Project Setup](#project-setup)
    1. [Add the required permissions for the app](#add-the-required-permissions-for-the-app)
    2. [Integrate OpenVPN Network Extension](#integrate-openvpn-network-extension)
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
7. [Handshake Update Implementation](#handshake-update-implementation)


## 1. Project Setup

### 1.1 Add the required permissions for the app

Add the required permissions for the app in the ***project file*** and initialize the app using the Primary Objects.
> Refer to: [README macOS Guide](https://github.com/wlvpn/ConsumerVPN-macOS/blob/main/SDK/Documentation/VPNKit%20macOS%20Guide.md) 
> Refer to: [README iOS Guide](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/VPNKit%20iOS%20Guide.md)

### 1.2 Integrate OpenVPN Network Extension

#### 1.2.1 Set Up the Network Extension Target

**Add a New Target:**
   - In Xcode, go to `File` > `New` > `Target`.
     - For iOS: Select `App Extension` > `Network Extension`.
     - For macOS: Select `System Extension` > `Network Extension`.
   - Choose **Packet Tunnel Provider** as the extension type and name it, such as ***PacketTunnelProvider***.

#### 1.2.2 Create the Packet Tunnel Provider Class

- **File:** `PacketTunnelProvider.swift`
- **Description:** This file defines the `PacketTunnelProvider` class, which inherits from `OVPacketTunnelProvider` provided by the VPKOpenVPNNetworkExtension framework.

##### Key Points:
- **Initialization:** In the initializer, you can configure settings for traffic monitoring (optional).
- **Traffic Monitoring:** Override `vpnDidReceiveTrafficDataCounter` to handle and debug traffic data if traffic monitoring is enabled.
- **Handshake Timestamp:** Read the `lastHandshakeDate` property to retrieve the timestamp of the last successful handshake.
- **Disconnect VPN:** Call `disconnect()` to terminate the VPN connection. The SDK clears `isOnDemandEnabled` and `includeAllNetworks` on the underlying `NETunnelProviderManager` so iOS does not re-spawn the extension.
- **Bypass Traffic:** Call `bypassAllTraffic()` to bypass all traffic from the VPN connection.
- **Connect-On-Demand status:** Read the `isOnDemandEnabled` property to check whether Connect-On-Demand is currently enabled on the provider.
- **Kill switch status:** Read the `isKillSwitchEnabled` property to check whether the kill switch (`includeAllNetworks`) is enabled. Use this from `vpnHandshakeUpdateDetected(_:)` to decide whether a `captivePortalLikely` recovery requires an explicit `disconnect()` call (kill switch on) or whether the SDK will auto-recover once the user signs in (kill switch off).
- **Roaming event verbosity:** `notifyRoamingOnce` (default `true`) debounces `.roaming` to one notification per roam episode. Set to `false` for verbose mode if you want a `.roaming` event on every handshake retry inside the post-roam window — useful for telemetry / diagnostics.
- **Live internet status:** `isInternetAvailable` is computed from the live `NWPath.Status` (no cache), so it is always safe to use as the authoritative reachability signal — including from inside `vpnHandshakeUpdateDetected(_:)`.
- **Session floating (default on):** `allowSessionFloating` on `OVPacketTunnelProvider` defaults to `true`. With floating on, Wi-Fi ↔ cellular swaps recover by rebinding the existing OpenVPN session to the new socket rather than doing a full TLS / key renegotiation — much faster, no visible "reconnecting" episode. Set `self.allowSessionFloating = false` in your `PacketTunnelProvider` subclass `init()` if you need to revert to the historical full-handshake-per-path-change behaviour.
- **Handshake Update Monitoring:** Override `vpnHandshakeUpdateDetected(_ error: Error?)` to receive structured notifications about handshake health. The SDK classifies failures into `HandshakeError` cases — including `roaming`, `staleSession`, `handshakeTimeout`, `tunnelCancelled(reason:)`, and `captivePortalLikely`. For `captivePortalLikely` the SDK additionally pauses its internal reconnect loop so the extension stops burning cycles against an unreachable server; reconnects auto-resume on the next satisfiable path update when the kill switch is off, or after the app calls `disconnect()` when the kill switch is on.

```swift
import NetworkExtension
import VPKOpenVPNNetworkExtension

class PacketTunnelProvider: OVPacketTunnelProvider {

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
        
        // Optout for session floating on network path change
        self.allowSessionFloating = false
        */
   }

   override func vpnDidReceiveTrafficDataCounter(_ counter: TrafficCounter) {
       debugPrint("\(#function) Read: \(counter.read) and Write:\(counter.write)")
   }

   // optional
   public override func vpnHandshakeUpdateDetected(_ error: Error?) {

        NSLog("[VPNKIT-NE] Internet Status: \(self.isInternetAvailable) Last Handshake Date: \(String(describing: self.lastHandshakeDate))")

        guard let nsError = error as NSError?,
              let handshakeError = HandshakeError.fromNSError(nsError) else {
            // All good, tunnel is having active connection.
            NSLog("[VPNKIT-NE] All good!!!")
            return
        }

        NSLog("[VPNKIT-NE] HandshakeError: \(handshakeError)")

        switch handshakeError {
        case .failure, .internetUnreachable, .roaming, .staleSession, .handshakeTimeout:
            // Transient or informational classifications. The SDK / OS will
            // typically recover on their own. Surface to the UI as needed.
            break
        case .tunnelCancelled(let reason):
            // The tunnel was cancelled externally — the SDK has already invoked
            // `cancelTunnelWithError(...)`. This notification is informational
            // and intended for logging or user notification purposes only.
            // For OpenVPN TCP connections, when Connect-On-Demand is enabled,
            // the VPN will reconnect automatically once internet connectivity
            // is restored. When Connect-On-Demand is disabled, this cancellation
            // is expected and the VPN will remain disconnected.
            NSLog("[VPNKIT-NE] tunnelCancelled reason: \(reason)")
        case .captivePortalLikely:
            // Repeated handshake failures after a network path change while the
            // OS still reports connectivity — the current network most likely
            // requires HTTP sign-in (captive portal). With the kill switch on,
            // iOS's captive sign-in sheet is blocked; call `disconnect()` so
            // the SDK clears `includeAllNetworks` and lets iOS present it. With
            // the kill switch off, no app action is required — the SDK auto-
            // resumes reconnects on the next satisfiable path update.
            if self.isKillSwitchEnabled {
                #if os(macOS)
                self.disconnect { error in
                    // Optional: surface error / log
                }
                #elseif os(iOS) || os (tvOS)
                // App target needs to call `apiManager.disconnect()`
                #endif
            }
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
  - **`NSSystemExtensionUsageDescription`**: Provide a description as your System Extension needs access to certain resources (e.g., "This app requires a system extension for VPN functionality").
  - **`com.vpnkit.<platform>.app_group_id`**: Add new key in both App and Network Extension Targets as `com.vpnkit.<platform>.app_group_id`: `<App-Group-ID>`.
 
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
    <key>com.vpnkit.ios.app_group_id</key>
    <string><!-- Replace with your App Group ID, e.g. TeamID.com.example.vpn --></string>
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
    <string>OpenVPNNetworkExtension</string>
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
        <string><!-- Replace with your App Group ID, e.g. group.com.example.vpn --></string>
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
    <key>com.apple.security.application-groups</key>
    <array>
        <string>App-Group-ID</string>
    </array>
</dict>
</plist>
```
 
 Summary:
 1. **Implement the `PacketTunnelProvider` class** with optional traffic monitoring settings.
 2. **Set up the main entry point** to start the system extension mode.
 3. **Configure `Info.plist`** to provide metadata and specify the provider class.
 4. **Configure `Entitlements.plist`** to define required permissions and capabilities for the extension.
 5. **Sign the Network Extension:** Ensure the Network Extension target is signed using your developer certificate. In Signing & Capabilities, add an App Group, Keychain Sharing.

 ## **2. Initialize the app**

 Initialize the app with the provided `APIKey`, `suffix`, `brandName`, and `configName`.
 > Refer to: [Initializers](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Initializers.md)

 ### Primary Objects
 > Refer to: [README macOS](https://github.com/wlvpn/ConsumerVPN-macOS/blob/main/SDK/README%20MacOS.md) 
 > Refer to: [README iOS](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/README%20iOS.md)


 ## **3. Connection**

 OpenVPN's system extension must be successfully installed in order to perform the connection.

 ### SystemExtension Support (macOS)

 This category provides helper methods for managing the installation, approval, and uninstallation of the OpenVPN System Extension.

 #### `- (BOOL)systemExtensionInstalled`

 **Returns:**  
 `YES` if the OpenVPN System Extension is installed, otherwise `NO`.
 **Discussion:**  
  This method determines if the OpenVPN System Extension is already present on the system. If the extension is installed, there is no need to initiate a new installation.

 #### `- (BOOL)systemExtensionApprovalPending`

 **Returns:**  
 `YES` if the OpenVPN system extension is awaiting user approval, otherwise `NO`.CFBundleDisplayName
 **Discussion:**  
 System extensions may require user approval after installation for security reasons. This method checks if such an approval is pending. Applications may need to prompt users to approve the extension in system settings.

 #### `- (void)installSystemExtension`

 **Discussion:**  
 This method starts the installation process for the OpenVPN system extension.  
 The outcome of the installation process will be communicated via notifications:
 - `VPNHelperInstallSuccessNotification`: Sent if the installation is successful.
 - `VPNHelperInstallFailedNotification`: Sent if the installation fails. The error information will be provided in the notification.
 
 **Note:**  
 The installation process might require administrative privileges, and users may need to approve the installation manually.

 #### `- (void)uninstallSystemExtension`

 **Discussion:**  
 This method handles the uninstallation of the OpenVPN System Extension. It ensures that the extension is properly removed from the system, freeing up resources and preventing conflicts.

 **Note:**  
 The uninstallation may also require user interaction or administrative privileges.


 ## **4. Notifications**

 Installation success or failure is reported via system notifications, allowing the app to asynchronously handle the result. You call a framework function and it will perform asynchronous actions. At various points during the action, a notification will be sent out that allows you to respond to the event.

 > Refer to: [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Notifications.md)
 
 
 ## **5. Error handling**

 The API throws an error code and error message. These values are listed in the **Error documentation**.

 > Refer: [Errors](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Errors.md)


 ## **6. Limitations, Features, and Compatibility**

 ### a. Limitations

 - **Network Extension Entitlements:** macOS apps require special entitlements to use Network Extensions. Ensure you have the necessary permissions from Apple.
 - **Background Execution:** Packet Tunnel Providers may have limited background execution time.
 - **Performance Considerations:** Slower than some newer protocols like WireGuard due to heavier encryption and more complex code. TCP mode can be particularly slow due to double encapsulation (TCP over TCP)
 - **Mobile Efficiency:** Not as optimized for mobile devices compared to modern protocols like `IKEv2` or `WireGuard`.
 - **No Native OS Integration:** Not built into most operating systems like `IKEv2` or `L2TP`/`IPsec`.

 ### b. Features

 - **Strong Security:** OpenVPN uses OpenSSL for encryption (supports AES, Blowfish, etc.). Offers authentication with certificates, username/password, and/or pre-shared keys. Supports TLS for secure key exchange.
 - **Open Source:** Transparent, regularly audited, and improved by the community. No backdoors; security-focused.
 - **Stability and Reliability:** Maintains stable connections even over unstable networks. Capable of reconnecting and resuming sessions after brief drops.
 - Supports features like **Threat Protection, Multihop, KillSwitch, Connect On demand, Split Tunneling**.

 For more details:  
> Refer to: [README macOS](https://github.com/wlvpn/ConsumerVPN-macOS/blob/main/SDK/README%20MacOS.md) 

 ### c. Compatibility

 - **Device Compatibility:** OpenVPN is compatible with both Intel and Apple Silicon Macs and iOS devices.
 - **Minimum Deployment Target:
    - **iOS**   : 15.0 and above
    - **macOS** : 12.0 and above
    - **tvOS**  : 18.0 and above
    
 > To get the necessary assets/SDK, please contact support@wlvpn.com

## **7. Handshake Update Implementation**
Handshake update implementation to detect VPN connection stability.

> Refer to: [Handshake Update Implementation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Handshake%20Update%20Implementation.md)
