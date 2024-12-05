# Implementing Notifications
  Notifications can be integrated by conforming to the various available protocol methods in the VPNKit. Please refer to the below example implementation to get notification callbacks.

```swift
class VPNManager: NSObject, VPNStatusReporting {
    var apiManager: VPNAPIManager!

    override init() {
        super.init()
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Observers
    func addObservers() {
        NotificationCenter.default.addObserver(for: self)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(for: self)
    }

}
```

# VPNHelperStatusReporting
   Implement this protocol in your VPNManager to get the status updates for Helper or System Extention Installation.

```markdown
- `statusHelperInstallSuccess`      : Notifies the receiver that the helper or system extention is installed. Includes the current VPNConfiguration.
- `statusHelperInstallPending`      : Notifies the receiver that the helper or system extention is still pending to be installed. Used to set back options to defaults or inform the user of a failure. Includes an NSError describing the issue, in case of a failure.
- `statusHelperInstallFailed`       : Notifies the receiver that the helper or system extention has failed to install. Used to set options back to defaults and inform the user of failure. Includes an NSError describing the issue.
```

Example Implementation:

```swift
  ViewController : VPNHelperStatusReporting {
   //@param notification The notification kicked back from NotificationCenter. object property holds `VPNConfiguration` type.
      func statusHelperInstallSuccess(_ notification: Notification) {
         // Handle any update in here
      }
      
      //@param notification TThe notification kicked back from NotificationCenter. Object property holds `NSError` type.
      func statusHelperInstallPending(_ notification: Notification) {
        // Handle any update in here
      }
      
      //@param notification The notification kicked back from NotificationCenter. object property holds `NSError` type.
      func statusHelperInstallFailed(_ notification: Notification) {
        // Handle any update in here
      }
  }
```

## VPNConnectionStatusReporting
    Implement this protocol in your view controller to get VPN connection status updates.


```markdown
- `updateConfigurationBegin`        : Notifies the receiver that the configuration update has begun.
- `updateConfigurationSucceeded`    : Notifies the receiver that the attempt to update the configuration was successful.
- `updateConfigurationFailed`       : Notifies the receiver that the attempt to update the configuration failed.
- `configurationRuntimeError`       : Notifies the receiver that the configuration failed due to a run-time error.
- `resetConfigurationBegin`         : Notifies the receiver that the configuration reset has begun.
- `resetConfigurationSucceeded`     : Notifies the receiver that the configuration reset was successful.
- `resetConfigurationFailed`        : Notifies the receiver that the attempt to reset the configuration was failed.
- `refreshConfigurationBegin`       : Notifies the receiver that the configuration refresh has begun.
- `refreshConfigurationSucceeded`   : Notifies the receiver that the configuration refresh has been successfully processed.
- `refreshConfigurationFailed`      : Notifies the receiver that refresh configuration has failed.
- `statusConnectionWillBegin`       : Notifies the receiver that the connection is about to begin. Use this time to prep for the connection.
- `statusConnectionDidBegin`        : Notifies the receiver that the connection has begun. This will result in a success or a failure. Use this time to inform the user of progress.
- `statusConnectionWillReconnect`   : Notifies the receiver that the connection will reconnect.
- `statusConnectionSucceeded`       : Notifies the receiver that the connection was successful. 
- `statusConnectionFailed`          : Notifies the receiver that the connection was not successful. Includes an NSError describing the issue.
   ++Parameter++: `notification`    : The notification kicked back from the NotificationCenter. object property holds `NSError` type.
- `statusConnectionWillDisconnect`  : Notifies the receiver that the disconnection is about to begin. Use this time to prep for the disconnection and to inform the user of progress.
- `statusConnectionDidDisconnect`   : Notifies the receiver that the disconnection was successful. Use this to inform the user the disconnection has finished.
- `statusConnectionActive`          : Notifies the receiver that the connection is currently in an active state.
- `statusNetworkMonitorUpdate`      : Notifies the receiver about incoming and outgoing network data used. Includes a bandwidth object with this information.object property holds type `VPNBandwidthModel`.
 ++Parameter++: `notification`      : The notification kicked back from NotificationCenter. object property holds type `VPNBandwidthModel`
- `connectionShouldDisconnect`      : Notifies the receiver that the active connection should disconnect.
- `connectionShouldConnect`         : Notifies the receiver that the connection should connect.
- `networkConnectionStatusChanged`  : Notifies the receiver that the network connection status has been changed.
- `statusConnectionHealthUpdate`    : Notifies the receiver that the VPN connection is healthy or not.
```

Example Implementation:

```swift
// MARK: - VPNAccountStatusReporting
ViewController: VPNConnectionStatusReporting {
    
    // MARK: - Configuration updates
    func updateConfigurationBegin(_ notification: Notification) {
        // Handle any update in here
    }
    
    func updateConfigurationSucceeded(_ notification: Notification) {
        // Handle any update in here
    }
    
    func updateConfigurationFailed(_ notification: Notification) {
        // Handle any update in here
    }
    
    // MARK: - Configuration resets
    func resetConfigurationBegin(_ notification: Notification) {
        // Handle any update in here
    }
    
    func resetConfigurationSucceeded(_ notification: Notification) {
        // Handle any update in here
    }
    
    func resetConfigurationFailed(_ notification: Notification) {
        // Handle any update in here
    }
    
    // MARK: - Configuration refresh
    func refreshConfigurationBegin(_ notification: Notification) {
        // Handle any update in here
    }
    
    func refreshConfigurationSucceeded(_ notification: Notification) {
        // Handle any update in here
    }
    
    func refreshConfigurationFailed(_ notification: Notification) {
        // Handle any update in here
    }
    
    //MARK: - Network Connection Status Changed
    func networkConnectionStatusChanged(_ notification: Notification) {
        // Handle any update in here
    }
    
    func statusConnectionWillBegin(_ notification: Notification) {
        // Handle any update in here
    }
    
    /// Used to log the connection status of `Did Begin`
    func statusConnectionDidBegin(_ notification: Notification) {
        // Display indeterminate progress showing that the connection process did begin.
    }
    
    func statusConnectionSucceeded(_ notification: Notification) {
        // Handle any update in here
    }
    
    func statusConnectionDidDisconnect(_ notification: Notification) {
        // Handle any update in here
    }
    
    ///parameter notification: Notification object kicked back from the VPNKit.
    func statusConnectionFailed(_ notification: Notification) {
        // Handle any update in here
    }
    
    func updateConfigurationSucceeded(_ notification: Notification) {
        // Handle any update in here
    }
    
    func updateConfigurationFailed(_ notification: Notification) {
        // Handle any update in here
    }
    
    func networkConnectionStatusChanged(_ notification: Notification) {
        // Handle network change in here
    }
    
    ///parameter notification: Notification object (as error) kicked back from the VPNKit.
    func statusConnectionHealthUpdate(_ notification: Notification) {
        // Handle VPN connection health update in here
    }
}

```

# `VPNConnectionStatus`
Implement this protocol in your view controller to get VPN connection status updates.

```markdown
- `VPNStatusDisconnected`           : VPN disconnected.
- `VPNStatusConnecting`             : VPN connecting.
- `VPNStatusConnected`              : VPN connected and active.
- `VPNStatusReconnecting`           : VPN previously connected and attempting reconnection.
- `VPNStatusDisconnecting`          : VPN disconnecting.
- `VPNStatusInvalid`                : VPN not setup.
- `VPNStatusActive`                 : VPN setup, ready to go.
- `VPNStatusError`                  : An error occurred after the tunnel was started.
- `VPNStatusReconnect`              : VPN setup, should attempt to reconnect.
- `VPNStatusHelperInstallSuccess`   : VPN Helper Install Successfully.
- `VPNStatusHelperInstallFailed`    : VPN Helper Install was attempted and failed.
- `VPNStatusHelperInstallPending`   : VPN Helper Install was attempted and pending.
```

Example Implementation:

```swift
   func updateStatusForState(state : VPNConnectionStatus? = nil) {
      // If no state was set, retrieves apiManager status directly to determine state.
        let connectionStatus = state ?? apiManager.status
      // Error occurred, displays error animation and returns
         if didFail { return }
         switch connectionStatus {
             case .statusDisconnected:
                  // Handle any update 
             case .statusConnecting:
                  // Handle any update 
             case .statusDisconnecting:
                  // Handle any update 
             case .statusConnected:
                 // Handle any update
             default:
                 // Handle any update
       }
  }
```


# VPNConfigurationStatusReporting
Implement this protocol in your VPNManagerr to get the current user's status updates when changes are reported by VPNConfiguration.

```markdown
- `statusCurrentUserWillChange`     : Notifies the receiver that the current `User` of the VPNConfiguration is about to change.
- `statusCurrentUserDidChange`      : Notifies the receiver that the current `User` of the VPNConfiguration has been changed.
- `statusCurrentAccountWillChange`  : Notifies the receiver that the current `Account` of the VPNConfiguration is about to change.
- `statusCurrentAccountDidChange`   : Notifies the receiver that the current `Account` of the VPNConfiguration has been changed.
- `statusCurrentServerWillChange`   : Notifies the receiver that the current `Server` of the VPNConfiguration is about to change.
- `statusCurrentServerDidChange`    : Notifies the receiver that the current `Server` of the VPNConfiguration has been changed.
- `statusCurrentCityWillChange`     : Notifies the receiver that the current `City` of the VPNConfiguration is about to change.
- `statusCurrentCityDidChange`      : Notifies the receiver that the current `City` of the VPNConfiguration has been changed.
- `statusCurrentCountryWillChange`  : Notifies the receiver that the current `Country` of the VPNConfiguration is about to change.
- `statusCurrentCountryDidChange`   : Notifies the receiver that the current `Country` of the VPNConfiguration has been changed.
- `statusCurrentProtocolWillChange` : Notifies the receiver that the current protocol of type `VPNProtocol` of the VPNConfiguration is about to change.
- `statusCurrentProtocolDidChange`  : Notifies the receiver that the current protocol of type `VPNProtocol` of the VPNConfiguration has been changed.
- `statusCurrentLocationWillChange` : Notifies the receiver that the current location of type `VPNCurrentLocationModel` of the VPNConfiguration is about to change.
- `statusCurrentLocationDidChange`  : Notifies the receiver that the current location of type `VPNCurrentLocationModel` of the VPNConfiguration has been changed.
- `statusOptionsWillChange`         : Notifies the receiver that the current options of the VPNConfiguration is about to change.
- `statusOptionsDidChange`          : Notifies the receiver that the current options of the VPNConfiguration has been changed.
```

Example Implementation:

```swift
  // MARK: - VPNConfigurationStatusReporting
  ViewController : VPNConfigurationStatusReporting {
    func statusCurrentCityDidChange(_ notification: Notification) {
      // Handle any update in here
    }
    func statusCurrentLocationDidChange(_ notification: Notification) {
      // Handle any update in here
    }
}
```


# VPNServerStatusReporting
Implement this protocol in your VPNManager  to get the VPN server status updates.

```markdown
- `statusServerCapacityWarning`     : Notifies the receiver that the currently connected VPN server has reached 80% of its maximum capacity.
- `statusServerUpdateWillBegin`     : Notifies the receiver that the list of VPN servers are about to update.
- `statusServerUpdateSucceeded`     : Notifies the receiver that the list of VPN servers were updated successfully. Includes an array of servers that were updated.
- `statusServerUpdateFailed`        : Notifies the receiver that the list of servers failed to update. Includes an NSError describing the reason for failure.
```


Example Implementation:

```swift
// MARK: - VPNServerStatusReporting
ViewController : VPNServerStatusReporting {
    
    func statusServerUpdateWillBegin(_ notification: Notification) {
        // Handle any update in here
    }
    
    func statusServerUpdateSucceeded(_ notification: Notification) {
        // Handle any update in here
    }
    
    func statusServerUpdateFailed(_ notification: Notification) {
        // Handle any update in here
    }
}
```


# VPNAccountStatusReporting
   Handles conformance to status reporting.

```markdown
- `statusLoginWillBegin`            : Notify receiver that the login operation is about to begin.
- `statusLoginSucceeded`            : Notify the receiver that the login operation has completed successfully. Includes the Account information.
- `statusLoginFailed`               : Notify the receiver that the login operation has completed with a failure. Includes an NSError describing the issue.
- `statusAutomaticLoginSuceeded`    : Notify the receiver that an automatic login operation did occur.
- `statusLogoutWillBegin`           : Notify the receiver that the logout operation is about to begin.
- `statusLogoutSucceeded`           : Notify the receiver that the logout operation has completed successfully.
- `statusLogoutFailed`              : Notify the receiver that the logout operation has completed with a failure. Includes an NSError describing the issue.
- `statusAccountExpired`            : Notify the receiver that the account is expired.
```


Example Implementation:

```swift
    // MARK: - VPNAccountStatusReporting
ViewController: VPNAccountStatusReporting {
    
    func statusLoginWillBegin(_ notification: Notification) {
        // Handle any update in here
    }
    
    //Parameter notification: Notification kicked back from the framework. Holds `Account` information.
    func statusLoginSucceeded(_ notification: Notification) {
        // Handle any update in here
    }
    
    func statusAutomaticLoginSuceeded(_ notification: Notification) {
        // Handle any update in here
    }

    /// Login failures are handled by the Login View Controller
    func statusLoginFailed(_ notification: Notification) {
        // Handle any update in here
    }
    
    func statusLogoutWillBegin(_ notification: Notification) {
        // Handle any update in here
    }

    func statusLogoutSucceeded(_ notification: Notification) {
        // Handle any update or session expired error here...
        
        // When logout by SDK, check error for more detail
        if let error = notification.object as? NSError {
            // handle session expired or reauthentication failed error if any.
        }
        
    }

    func statusLogoutFailed(_ notification: Notification) {
        // Handle any update in here
    }
    
    func statusAccountExpired(_ notification: Notification) {
        // Handle any update in here
    }
    
}
```
