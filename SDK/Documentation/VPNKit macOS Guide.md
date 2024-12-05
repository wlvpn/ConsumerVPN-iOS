# VPNKit macOS Guide

VPNKit is a framework developed to manage, create and monitor a VPN connection. 
The framework provides APIs to login, fetch servers, backup data in a database, connect and configure the VPN service, and get connection states.

## Table of contents

1. [Integrating VPNKit framework](#integrating-vpnKit-framework)
2. [Project Settings](#project-settings)
    1. [Signing](#signing)
    2. [Capabilities](#capabilities)
3. [Initializing the VPNAPIManager](#initializing-the-vpnapimanager)
4. [Implementation](#implementation)
    1. [Login and Sign Up](#login-and-sign-up)
    2. [Fetching the servers](#fetching-the-servers)
    3. [Fetching the location](#fetching-the-location)
    4. [Selecting a protocol](#selecting-a-protocol)
    5. [Synchronize the configuration](#synchronize-the-configuration)
    6. [Perform a VPN connection](#perform-a-vpn-connection)
    7. [Error handling](#error-handling)
    8. [Notification handling](#notification-handling)
5. [Some Features](#some-features)
    1. [On Demand configuration](#on-demand-configuration)
    2. [Kill Switch](#kill-switch)
    3. [Split Tunneling](#split-tunneling)
    4. [Threat Protection](#threat-protection) 
    5. [Multihop](#multihop)
6. [Common Questions](#common-questions)


# `Integrating VPNKit framework`
1. Copy the VPNKit SDKs (VPNKit, VPNV3APIAdapter) from macOS or XCFrameworks to the SDK folder of the project.
    
2. Copy the VPNKitNetworkExtensionAdapters SDKs (VPKWireGuardAdapter, VPKWireGuardExtension) from macOS or XCFrameworks to the SDK folder of the project.

- You can find the VPNKit changelog in its subfolder.

> Refer to: [Changelog](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Changelog.md)


# `Project Settings`

Setting Up Signing & Capabilities in Xcode
> **Note**
> The minimum version of Xcode required to develop is **Xcode 13** 

### Signing

1. Open your project in Xcode.
2. Select your target.
3. Go to the **Signing & Capabilities** tab.
4. Select your **Team** and check **Automatically manage signing**.

### Capabilities

1. In the **Signing & Capabilities** tab, click **+ Capability**.
2. Add **Network Extensions**.
  - Configure the settings by enabling **Packet Tunnel**
3. Add **App Groups** as app needs to share data.
4. Add **Access WiFi Information** to allow app to access information about the local WiFi network.
5. Add **Personal VPN** for VPN functionality.
6. Add **System Extensions** as app uses the system extension features.
7. Add **Maps** as app uses mapping functionalities.
8. Add **Hardened Runtime**.
    -Enable **Location** under Hardened Runtime options.


> Note: These capabilities are reflected under `Developer Account`.

Developer > Account > Certificates, Identifiers & Profiles > Identifiers > [your app ID]


# `Initializing the VPNAPIManager`

The `VPNAPIManager` creates a VPN connection and a VPN connection adapter for each VPN protocol. The `VPNConnectionTestAdapter` class fakes a VPN connection in the simulator and produces all the correct notifications.

In **Appdelegate** initialize the SDK:

An initialized `VPNAPIManager` object for various API and connection adapter settings is built using helper Objc objects. It contains the brand name, configuration name, api key, and username suffix.

```swift
import VPNKit
import VPNV3APIAdapter
import VPNHelperAdapter

class AppDelegate: UIResponder, UIApplicationDelegate {

var apiManager: VPNAPIManager!
let privilegedHelperManager = VPNPrivilegedHelperManager(helperName: <#openVPNToolBundleId>, andBrandName: <#brand name>)

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Initialize the APIManager using helper Objc object.
        apiManager = SDKInitializer.initializeAPIManager(
            withBrandName: // brandName,
            configName: // Your company custom VPN configuration name,
            apiKey: // apiKey,
            andSuffix: // usernameSuffix,
        )
        // set the default encryption to 256 if one isn't already set
        if apiManager.vpnConfiguration.hasOption(forKey: kIKEv2Encryption) == false {
            apiManager.vpnConfiguration.setOption(kVPNEncryptionAES256, forKey: kIKEv2Encryption)
        }
    }
}
```

> Refer : [Initializers](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Initializers.md)


# `Implementation`

### 1. Login 
Login securely authenticates the user to your application.

```swift
func login(username : String, password: String) {
    apiManager.login(withUsername: username, password: password)
} 
```

> Refer : [Login](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Login.md)


### 2. Fetching the servers
```swift
// Fetch all of the cities from the APIManager
fetchedCities = apiManager.fetchAllCities() 
```

> Refer: [Fetch](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Fetch.md)


### 3. Fetching the location
- Fetch the current location by listening to the `VPNConfigurationStatusReporting` notification named 'statusCurrentLocationDidChange'
    - It contains VPNCurrentLocationModel object as a notification object.

- Fetch the current location model from the `vpnConfiguration` object.

> Refer: [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Fetch.md)


### 4. Selecting a protocol
The desired protocol can be selected by setting the VPN's api manager and its configuration.
On changing the protocol listen to the notification as given in example:

```swift
 class VPNManager: NSObject {
    // set the selectedProtocol property of VPNConfiguration
    // If WireGuard selected
    apiManager.vpnConfiguration.selectedProtocol = VPNProtocol.wireGuard
    // If IKEv2 selected
    apiManager.vpnConfiguration.selectedProtocol = VPNProtocol.ikEv2
    // If IPSec selected
    apiManager.vpnConfiguration.selectedProtocol = VPNProtocol.ipSec
    // If OpenVPN UDP selected
    apiManager.vpnConfiguration.selectedProtocol = VPNProtocol.openVPN_UDP
    // If OpenVPN TCP selected
    apiManager.vpnConfiguration.selectedProtocol = VPNProtocol.openVPN_TCP
}

extension VPNManager: VPNConfigurationStatusReporting {
    func statusCurrentProtocolDidChange(_ notification: Notification) {
        if let vpnconfiguration = notification.object as? VPNConfiguration {
            DDLogVerbose("CurrentProtocolDidChange: \(vpnconfiguration)");
        }
        apiManager.synchronizeConfiguration()
    }
}
```


 **NOTE:**
- If selected protocol is Wireguard, check **WireGuard System Extension** is installed or not.
- If selected protocol is OpenVPN, check **Priviledge Helper** is installed or not.

> Refer: [APIManager](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/APIManager.md)

### 5. Synchronize the configuration
 * In order to avoid excessive updates to the underlying VPN connections, we don't automatically apply changes as they're made to VPNConfiguration.
 * Excessive updates can cause unpredictable client behavior.
 * Use the below methods to commit configuration changes to the currently active adapter.
 * Call the below methods whenever there are changes to the configuration.
 
``` swift
- (void)synchronizeConfiguration;
- (void)synchronizeConfigurationWithCompletion:(void(^_Nullable)(BOOL success))completion;
```
Note: Notifications related to synchronization are listed under `VPNConnectionStatusReporting`

> Refer: [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Notifications.md)


### 6. Perform a VPN connection
The user can connect and disconnect using the API.
- You can select the vpn server by setting the VPN configuration either by country, city or server from the available server list.
- If all the server properties (country, city, and server) are left nil, then the api manager would choose the optimal location for connection.
- Before connecting, you can check for the validity of the user by `apiManager.activeUser`
```swift
    if apiManager.activeUser {
        apiManager.vpnConfiguration.country = nil
        apiManager.vpnConfiguration.city = selectedCity ////City object fetched from the server list in Step-3.
        apiManager.vpnConfiguration.server = nil
        apiManager.vpnConfiguration.selectedProtocol = VPNProtocol.ikEv2
        apiManager.connect()
    }
```

> Refer: [Connection](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Connection.md)


### 7. Error handling
The API throws an error code and error message. These values are listed in the **Error documentation**

> Refer: [Errors](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Errors.md)


### 8. Notification handling
Most of the events such as connection/disconnection, configuration changes, etc. fire notifications and the end-user must handle these events. Notifications are listed in the **Notifications documentation**

> Refer: [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Notifications.md)


# `Some Features`

### 1. On Demand configuration
-  You can get the `VPNOnDemandConfiguration` via `apiManager.vpnConfiguration?.onDemandConfiguration` and setting its `enabled` property to true.

> Refer: [On Demand](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/On%20Demand.md)

### 2. Kill Switch
- The VPN Kill Switch is a configurable setting within specific VPN software applications designed to  enhance security by preventing data from leaking outside the VPN tunnel.

> Refer: [Kill Switch](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Kill%20Switch.md)

### 3. Split Tunneling
- VPN split tunneling is an advanced feature of virtual private network software, designed to help you better manage and control your VPN traffic. 

> Refer: [Apple Split Tunneling](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Apple%20Split%20Tunneling.md)

### 4. Threat Protection
- Block ads, trackers and malicious websites when the VPN is connected

> Refer: [DNSUsage](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/DNSUsage.md)

### 5. Multihop
- The multihop feature enhances the anonymity and security of VPN connections by introducing an entry
and exit point, thereby adding an extra layer of protection to user data.
The user's connection will entry through one server and exit through another one.

> Refer: [MultiHop Implementation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/MultiHop%20Implementation.md)


# `Common Questions`
1.  Why the Wireguard protocol is not working?
-   Wireguard's system extension must be successfully installed in order to perform connection.
-   In order to install the Wireguard system extension, the app must be placed under the /applications folder.

2.  Is CocoaPods required during the development?
-   CocoaPods is not a requirement for the development.

3.  What is On Demand configuration and its limitation?
-   VPN On Demand allows the system to automatically start or stop a VPN connection based on various criterias.
-   For example, you can use VPN On Demand to configure an iPhone to start a VPN connection when it iss on Wi-Fi and stop the connection when it is on cellular. Or, you can start the VPN connection when an app tries to connect to a specific service that is only available via VPN.
-   This configuration only supports trusted Wi-Fi connections and untrusted domains.
-   Moreover, split tunneling will not work with this configuration.

4.  How to integrate notifications?
-   A detailed documentation is available for adding notification callbacks in the application.

> Refer: [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Notifications.md)

5. How to get the user account details?
-  The user's information can be retrieved from the `apiManager?.vpnConfiguration?.user` object which has details such as the username, email, account type of the user.

> Refer: [VPNConfiguration](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/VPNConfiguration.md)
