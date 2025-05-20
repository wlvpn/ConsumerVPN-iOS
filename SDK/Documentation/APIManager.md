# APIManager

## Properties

- **`isActiveUser`**            : `Bool` - Indicates whether the user is active or not.
- **`vpnConfiguration`**        : `VPNConfiguration` object - Manages the state of the VPN configuration and API state for the app. Allows setting/getting the current user, account,                                         country,  city, server, etc. Also allows setting VPN connection options such as on-demand.
- **`connectionStatus`**        : `VPNConnectionStatus` object - Shows the current VPN connection status.
- **`helperStatus`**            : `VPNConnectionStatus` object – Indicates the current status of the VPN helper installation, used only for OpenVPN and WireGuard. This helps track whether the VPN helper was successfully installed, is pending, or failed. (macOS only).
- **`networkIsReachable`**      : `Bool` - Indicates if the internet is currently reachable by the device or not.
- **`reachableViaWWAN`**        : `Bool` - Indicates if the network is currently reachable via WWAN or not.
- **`reachableViaWiFi`**        : `Bool` - Indicates if the network is currently reachable via WiFi or not.
- **`networkType`**             : `VPNNetworkType` object - Describes the type of network interface on the device.
- **`captivePortalStatus`**     : `CaptivePortal` object - Describes the possibility of being in a captive portal.
- **`apiAdapter`**              : Read-only.
- **`metadata`**                : `MetaProxy` object - Provides metadata API access. 
- **`isLoggedIn`**              : `Bool` - Returns `YES` if the user is logged in otherwise `NO`.
- **`availableEntitlements`**:  : `NSArray` - Returns array of available entitlements.

Properties can be accessed using: `[APIManager object].[property]`. For example:

```swift
class ApiManagerHelper: NSObject {
    var apiManager: VPNAPIManager
    var vpnConfiguration: VPNConfiguration?
    
    func connect() {
        self.vpnConfiguration = self.apiManager.vpnConfiguration
        if apiManager.networkIsReachable { 
            apiManager.connect()
        }
    }
}
```

## Initialization

- **`initWithAPIAdapter:connectionAdapter:andOptions:`**
```objc
  - (instancetype _Nullable)initWithAPIAdapter:(NSObject<VPNAPIAdapterProtocol> * _Nonnull)apiAdapter
       connectionAdapter:(NSObject<VPNConnectionAdapterProtocol> * _Nonnull)connectionAdapter
              andOptions:(NSDictionary * _Nonnull)options
```
  Initializes the `APIManager` with the provided `APIAdapter` and `ConnectionAdapter`. Both of these objects must conform to their respective protocols. This method also allows you to pass in customization options to be used by the manager. For example:

```swift
 let apiManager = VPNAPIManager(apiAdapter: apiAdapter,
                        connectionAdapters: adapters as! [VPNConnectionAdapterProtocol],
                                andOptions: apiManagerOptions) 
```

## Update Account Configuration Functions

- **`updateAccountConfiguration:`**
```objc
 - (void)updateAccountConfigurationWithCompletion:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completionHandler;
```
  Updates the user's account configuration by fetching the latest information from the API adapter. For example:

```swift
  apiManager?.updateAccountConfiguration( completion: { success in
    // success will be true or false
    // After completion, the `availableEntitlements` property will be updated with the latest entitlement list.
  })
```


## Refresh Location Functions

- **`refreshLocationWithCompletion:`**
```objc
  - (void)refreshLocationWithCompletion:(void (^_Nullable)(VPNCurrentLocationModel * _Nullable locationModel,
                                                            NSError * _Nullable reachabilityError))completionHandler;
```
  Refreshes the user's current location using the API adapter. For example:

```swift
  apiManager.refreshLocation(completion: { location, error in
      //Location will be user's current location or VPN server location.
  })
```

## Update Server List

- **`updateServerList`**
```objc
  - (void)updateServerList;
```
  Fetches the server list and stores it as a current list of servers. For example:

```swift
  func refreshServer() async -> Bool {
      guard apiManager.networkIsReachable else { return false }
      let success = await apiManager.updateServerList()
      
      return success
  }
```

## Fetch Country Functions

- **`fetchAllCountries`**
```objc
  - (NSArray * _Nonnull)fetchAllCountries;
```
  Returns an array with all available Countries. For example:

```swift
  apiManager.fetchAllCountries()
```

> Refer : [Fetch](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Fetch.md)

## Fetch All Cities

- **`fetchAllCities`**
```objc
  - (NSArray * _Nonnull)fetchAllCities;
```
  Returns an array with all available Cities. For example:

```swift
  apiManager.fetchAllCities()
```

> Refer : [Fetch](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Fetch.md)

## Connection Functions

- **`synchronizeConfiguration`**
```objc
  - (void)synchronizeConfiguration;
  - (void)synchronizeConfigurationWithCompletion:(void(^_Nullable)(BOOL success))completion;
```
  Use these methods to commit configuration changes to the currently active adapter. For example:

```swift
  apiManager.synchronizeConfiguration { success in
      // Perform an action based on the success parameter
  }
```

- **`connect`**
```objc
  - (void)connect;
```
  Connect to the VPN with the provided `VPNConfiguration`. For example:
  
```swift
  apiManager.connect()
```

- **`disconnect`**
```objc
  - (void)disconnect;
```
  Disconnect from the currently connected VPN server. For example:

```swift
  apiManager.disconnect()
```

- **`isConnectedToVPN`**
```objc
  - (BOOL)isConnectedToVPN;
```
  Returns `YES` if connected, `NO` otherwise. For example:

```swift
 apiManager.isConnectedToVPN()
```

- **`isConnectingToVPN`**
```objc
  - (BOOL)isConnectingToVPN;
```
  Returns `YES` if connecting, `NO` otherwise. For example:

```swift
  apiManager.isConnectingToVPN()
```

- **`isDisconnectingFromVPN`**
```objc
  - (BOOL)isDisconnectingFromVPN;
```
  Returns `YES` if disconnecting, `NO` otherwise. For example:

```swift
  apiManager.isDisconnectingFromVPN()
```

- **`isDisconnectedFromVPN`**
```objc
  - (BOOL)isDisconnectedFromVPN;
```
  Returns `YES` if disconnected, `NO` otherwise. For example:

```swift
  apiManager.isDisconnectedFromVPN()
```

> Refer : [Connection](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Connection.md)

- **`resetConfiguration`**
```objc
  - (void)resetConfiguration;
```
  Removes and resets the current configuration to address issues.

- **`refreshConfiguration`**
```objc
  - (void)refreshConfiguration;
```
  Refreshes the current configuration.


## Connection Timer Functions

- **`connectedDate`**: Returns the `NSDate` when the user connected else nil.
- **`connectedTimeInSeconds`**: Returns an integer representing the number of seconds since connected else -1 if not connected.

## Captive Portal Functions

- **`updateCaptivePortalStatus:`**
```objc
  - (void)updateCaptivePortalStatus:(void (^_Nullable)(CaptivePortal newStatus))completion;
```
  Calling this function will update `captivePortalStatus` before calling its completion handler.

## Protocol Helpers

- **`supportedProtocols`**
```objc
  - (NSArray * _Nonnull)supportedProtocols;
```
  Returns an array of supported protocols from all connection adapters.

- **`protocolForString:`**
```objc
- (VPNProtocol)protocolForString:(NSString * _Nonnull)protocolString;
```
  Returns the appropriate `VPNProtocol` for a provided string value.

## Plugin Support

- **`addPlugin:forKey:`**
```objc
  - (void)addPlugin:(id<VPNPluginProtocol> _Nonnull)plugin forKey:(NSString * _Nonnull)key;
```
  Adds a plugin to the `VPNAPIManager`.

- **`getPlugin:`**
```objc
  - (id<VPNPluginProtocol> _Nonnull)getPlugin:(NSString * _Nonnull)key;
```
  Gets a plugin from the `VPNAPIManager`.

## System Extension Helpers (macOS only)

- **`systemExtensionInstalled`**
```objc
  - (BOOL)systemExtensionInstalled;
```
  Checks if the WireGuard system extension is installed or not. If it is then the WireGuard protocol can connect; otherwise, call the **installSystemExtension** function.

- **`systemExtensionApprovalPending`**
```objc
  - (BOOL)systemExtensionApprovalPending;
```
  Checks if the WireGuard system extension is pending for user approval. If true, the WireGuard protocol cannot connect then you should show alert to notify user.

- **`installSystemExtension`**
```objc
  - (void)installSystemExtension;
```
  **installSystemExtension()** function installs the WireGuard system extension. The installation status will be reported as a notification (`VPNHelperInstallSuccessNotification` or `VPNHelperInstallFailedNotification` with an error as the notification object).

- **`uninstallSystemExtension`**
```objc
  - (void)uninstallSystemExtension;
```
  Uninstalls the WireGuard system extension.

For example:

```swift
class ViewController : NSWindowController {
        /// The instance of `VPNAPIManager` used to perform API operations.
        var apiManager: VPNAPIManager
        
        func canWireGuardConnect() {
            guard apiManager.systemExtensionInstalled() else {
                apiManager.installSystemExtension()
                return false
            }
            
            guard !apiManager.systemExtensionApprovalPending() else {
                // Show alert that the user has to approve the system extension from the Settings app
                return false
            }
            
            return true
        }
}

extension ViewController: VPNHelperStatusReporting {
    func statusHelperInstallSuccess(_ notification: Notification) {
        guard let vpnConfiguration = vpnConfiguration else {return}
        if vpnConfiguration.selectedProtocol == .wireGuard  {
            // WireGuard System Extention installed successfully and available to connect.
        }
    }
    
    func statusHelperInstallPending(_ notification: Notification) {
        guard let vpnConfiguration = vpnConfiguration else {return}
        if vpnConfiguration.selectedProtocol == .wireGuard  {
            // WireGuard System Extention installation pending so cannot connect.
        }
    }
    
    func statusHelperInstallFailed(_ notification: Notification) {
        guard let vpnConfiguration = vpnConfiguration else {return}
        if vpnConfiguration.selectedProtocol == .wireGuard  {
            // WireGuard System Extention installation failed so cannot connect.
        }
    }
}
```

## Privileged Helper (macOS only)

 - **`isHelperInstalled`**
  This function drives helper installation. It can, synchronously or asynchronously, determine if the helper is installed. Once your adapter determines if the helper is installed, it should call the completion handler. This function is used by multiple methods in the VPNAPIManager. Each function that calls it may provide a different completion handler.
```objc
- (BOOL)isHelperInstalled;
```
 - **`installPrivilegedHelper()`**
  Installs the **OpenVPN** privileged helper. The installation status will be reported as a notification (`VPNHelperInstallSuccessNotification` or `VPNHelperInstallFailedNotification` with an error as the notification). On connecting without the helper installation, a `VPNHelperInstallPendingNotification` notification will be sent.

For example:

```swift
class ViewController : NSWindowController {
    /// The instance of `VPNAPIManager` used to perform API operations.
    var apiManager: VPNAPIManager
    
    // Initialized privileged helper manager with the provided helper tool name
    var privilegedHelperManager: VPNPrivilegedHelperManager?
    
    func canOpenVPNConnect() {
        if !(privilegedHelperManager?.isHelperInstalled()) {
            apiManager.installPrivilegedHelper()
            return false
        }
        
        return true
    }
}

extension ViewController: VPNHelperStatusReporting {
    func statusHelperInstallSuccess(_ notification: Notification) {
        guard let vpnConfiguration = apiManager.vpnConfiguration else {return}
        if vpnConfiguration.selectedProtocol == .openVPN_TCP
            || vpnConfiguration.selectedProtocol == .openVPN_UDP {
            // OpneVPN Helper installed successfully and available to connect.
        }
    }
    
    func statusHelperInstallPending(_ notification: Notification) {
        guard let vpnConfiguration = apiManager.vpnConfiguration else {return}
        if vpnConfiguration.selectedProtocol == .openVPN_TCP
            || vpnConfiguration.selectedProtocol == .openVPN_UDP {
            // OpneVPN Helper installation pending so cannot connect.
        }
    }
    
    func statusHelperInstallFailed(_ notification: Notification) {
        guard let vpnConfiguration = apiManager.vpnConfiguration else {return}
        if vpnConfiguration.selectedProtocol == .openVPN_TCP
            || vpnConfiguration.selectedProtocol == .openVPN_UDP {
            // OpneVPN Helper installation failed so cannot connect.
        }
    }
}
```
