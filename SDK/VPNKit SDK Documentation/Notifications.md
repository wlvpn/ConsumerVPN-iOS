# VPNHelperStatusReporting
- `statusHelperInstallSuccess`: Notify the user that the Helper is installed. Includes the current VPNConfiguration.
- `statusHelperInstallPending`: Notify the user that the Helper is pending to install. Use this to set back options to the default value and inform the user of a failure. It includes NSError describing the issue.
- `statusHelperInstallFailed`: Notify the user that the Helper failed to install properly. Use this to set options back to defaults and inform the user of failure. Includes NSError describing issue.

```sh 
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

# VPNStatusReporting

- `updateConfigurationBegin`: Notify the receiver that the begin to updating the configuration.
- `updateConfigurationSucceeded`: Notify the receiver that the attempt to update the configuration was successful.
- `updateConfigurationFailed`: Notify the receiver that the attempt to update the configuration failed.
- `configurationRuntimeError`- Notify the receiver that the configuration failed due to run-time error.
- `resetConfigurationBegin`: Notify the receiver that the begin to reset the configuration.
- `resetConfigurationSucceeded`: Notify the receiver that the attempt to reset the configuration was successful.
- `resetConfigurationFailed`: Notify the receiver that the attempt to reset the configuration was failed.
- `refreshConfigurationBegin`: Notify the receiver that the begin to refresh the configuration.
- `refreshConfigurationSucceeded`: Notify the receiver that the attempt to refresh the configuration was successful.
- `refreshConfigurationFailed`: Notify the receiver that the attempt to refresh the configuration was failed.
- `statusConnectionWillBegin`: Notify the receiver that the connection logic is about to take place. Use this time to prep for the connection.
- `statusConnectionDidBegin`: Notify the receiver that the connection logic has started. This will result in a success or a failure. Use this time to inform the user of progress.
- `statusConnectionWillReconnect`: Notify the receiver that the connection logic will reconnect.
- `statusConnectionSucceeded`: Notify the receiver that the connection logic has completed successfully. 
- `statusConnectionFailed`: Notify the receiver that the connection logic has completed with a failure. Includes an NSError describing the issue.
- `statusConnectionWillDisconnect`:  Notify the receiver that the disconnection logic is about to take place. Use this time to prep for the disconnection and to inform the user of progress.
- `statusConnectionDidDisconnect`: Notify the receiver that the disconnection logic has completed. Use this to inform the user the disconnection has finished.
- `statusConnectionActive`: Notify the receiver that the connection is currently in an active state.
- `statusNetworkMonitorUpdate`: Notify the receiver about incoming and outgoing network data used. Includes a bandwidth object with this information.object property holds type `VPNBandwidthModel`
- `networkConnectionStatusChanged`: Notifies the receiver that the network connection status has been changed


```sh
  ViewController: VPNConnectionStatusReporting {
      /// Used to log the connection status of `Will Begin`
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
  }
```

# VPNConnectionStatus
- `VPNStatusDisconnected`: VPN setup, disconnected
- `VPNStatusConnecting`: VPN setup, connecting
- `VPNStatusConnected`: VPN setup, connected and active
- `VPNStatusReconnecting`: VPN setup, previously connected and attempting reconnection
- `VPNStatusDisconnecting`: VPN setup, disconnecting
- `VPNStatusInvalid`: VPN not setup
- `VPNStatusActive`: VPN setup, ready to go
- `VPNStatusError`: An error occurred after the tunnel was started
- `VPNStatusReconnect`: VPN setup, should attempt to reconnect
- `VPNStatusHelperInstallSuccess`: VPN Helper Install Successfully
- `VPNStatusHelperInstallFailed`: VPN Helper Install was attempted and failed
- `VPNStatusHelperInstallPending`: VPN Helper Install was attempted and pending

```sh
   func updateStatusForState(state : VPNConnectionStatus? = nil, didFail : Bool = false) {
      // If no state was set, retrieves apiManager status directly to determine state.
        let connectionStatus = state ?? apiManager.status
      // Error occurred, displays error animation and returns
         if didFail { return }
      // sets dashboard status UI and animation for state
         switch connectionStatus {
             case .statusDisconnected:
                  // Handle any update in here
             case .statusConnecting:
                  // Handle any update in here
             case .statusDisconnecting:
                  // Handle any update in here
             case .statusConnected:
                 // Handle any update in here
             default:
                 // Handle any update in here
       }
  }
```

# VPNConfigurationStatusReporting
- `statusCurrentUserWillChange`: Notify the receiver that the current `User` of the VPNConfiguration is about to change
- `statusCurrentUserDidChange`: Notify the receiver that the current `User` of the VPNConfiguration has been changed
- `statusCurrentAccountWillChange`: Notify the receiver that the current `Account` of the VPNConfiguration is about to change
- `statusCurrentAccountDidChange`: Notify the receiver that the current `Account` of the VPNConfiguration has been changed
- `statusCurrentServerWillChange`: Notify the receiver that the current `Server` of the VPNConfiguration is about to change
- `statusCurrentServerDidChange`: Notify the receiver that the current `Server` of the VPNConfiguration has been changed
- `statusCurrentCityWillChange`: Notify the receiver that the current `City` of the VPNConfiguration is about to change
- `statusCurrentCityDidChange`: Notify the receiver that the current `City` of the VPNConfiguration has been changed
- `statusCurrentCountryWillChange`: Notify the receiver that the current `Country` of the VPNConfiguration is about to change
- `statusCurrentCountryDidChange`: Notify the receiver that the current `Country` of the VPNConfiguration has been changed
- `statusCurrentProtocolWillChange`: Notify the receiver that the current protocol of type `VPNProtocol` of the VPNConfiguration is about to change
- `statusCurrentProtocolDidChange`: Notify the receiver that the current protocol of type `VPNProtocol` of the VPNConfiguration has been changed
- `statusCurrentLocationWillChange`: Notify the receiver that the current location of type `VPNCurrentLocationModel` of the VPNConfiguration is about to change
- `statusCurrentLocationDidChange`: Notify the receiver that the current location of type `VPNCurrentLocationModel` of the VPNConfiguration has been changed
- `statusOptionsWillChange`: Notify the receiver that the current options of the VPNConfiguration is about to change
- `statusOptionsDidChange`: Notify the receiver that the current options of the VPNConfiguration has been changed

```sh
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

- `statusServerCapacityWarning`: Notify the receiver that the currently connected server's capacity is greater than 80% maximum capacity.
- `statusInitialServerUpdateWillBegin`: Notify the receiver that the first ServerUpdateWillBegin notification has been thrown since starting the application.
- `statusInitialServerUpdateSucceeded`: Notify the receiver that the first ServerUpdateSucceeded notification has been thrown since starting the application.
- `statusInitialServerUpdateFailed`: Notify the receiver that the first ServerUpdateFailed notification has been thrown since starting the application.
- `statusServerUpdateWillBegin`: Notify the receiver that the list of servers are about to update.
- `statusServerUpdateSucceeded`: Notify the receiver that the list of servers were updated successfully. Includes Array of Servers that were updated.
- `statusServerUpdateFailed`: Notify the receiver that the list of servers failed to update. Includes an NSError describing the reason for failure.

```sh
    // MARK: - VPNServerStatusReporting
    ViewController : VPNServerStatusReporting {
	func statusInitialServerUpdateWillBegin(_ notification: Notification) {
		// Handle any update in here
	}
	
	func statusInitialServerUpdateSucceeded(_ notification: Notification) {
	   // Handle any update in here
	}
	
	func statusInitialServerUpdateFailed(_ notification: Notification) {
		// Handle any update in here
	}
	
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

- `statusLoginWillBegin`: Notify receiver that the login operation is about to begin.
- `statusLoginSucceeded`: Notify the receiver that the login operation has completed successfully. Includes the Account information.
- `statusLoginFailed`: Notify the receiver that the login operation has completed with a failure. Includes an NSError describing the issue.
- `statusAutomaticLoginSuceeded`: Notify the receiver that an automatic login operation did occur
- `statusLogoutWillBegin`: Notify the receiver that the logout operation is about to begin.
- `statusLogoutSucceeded`: Notify the receiver that the logout operation has completed successfully.
- `statusLogoutFailed`: Notify the receiver that the logout operation has completed with a failure. Includes an NSError describing the issue.
- `statusAccountExpired`: Notify the receiver that the account is expired.
- `statusLoginServerUpdateWillBegin`: Notify the receiver that fetch login server list about to begin.
- `statusLoginServerUpdateSucceeded`: Notify the receiver that fetch login server list has completed successfully.
- `statusLoginServerUpdateFailed`: Notify the receiver that fetch login server list has completed with failure.

```sh
    // MARK: - VPNAccountStatusReporting
    ViewController: VPNAccountStatusReporting {
    
         func statusLoginWillBegin(_ notification: Notification) {
             // Handle any update in here
         }
         
      //Parameter notification: Notification kicked back from the framework. Holds `Account` information.
         func statusLoginSucceeded(_ notification: Notification) {
            // Handle any update in here
        }
        
     /// Login failures are handled by the Login View Controller
         func statusLoginFailed(_ notification: Notification) {
           // Handle any update in here
        }
      
         func statusAccountExpired(_ notification: Notification) {
            // Handle any update in here
        }
      
        func statusLoginServerUpdateWillBegin(_ notification: Notification) {
           // Handle any update in here
        }
      
        func statusLoginServerUpdateSucceeded(_ notification: Notification) {
           // Handle any update in here
        }
      
        func statusLoginServerUpdateFailed(_ notification: Notification) {
           // Handle any update in here
        }
}
```

## VPNConnectionStatusReporting

 * `updateConfigurationBegin`: Notify the receiver that the configuration update has begun.
 * `updateConfigurationSucceeded`:Notify the receiver that the attempt to update the configuration was successful.
 * `updateConfigurationFailed`: Notify the receiver that the attempt to update the configuration failed.
 * `configurationRuntimeError`: Notify the receiver that the configuration failed due to a run-time error.
 * `resetConfigurationBegin`: Notify the receiver that the configuration reset has begun.
 * `resetConfigurationSucceeded`: Notify the receiver that the configuration reset was successful.
 * `resetConfigurationFailed`: Notify the receiver that the attempt to reset the configuration was failed.
 * `refreshConfigurationBegin`: Notify the receiver that the configuration refresh has begun.
 * `refreshConfigurationSucceeded`: Notify the receiver that the configuration refresh has been successfully processed.
 * `refreshConfigurationFailed`: Notify the receiver that refresh configuration has failed.
 * `statusConnectionWillBegin`: Notify the receiver that the connection logic is about to take place. Use this time to prep for the connection.
 * `statusConnectionDidBegin`: Notify the receiver that the connection logic has started. This will result in a success or a failure. Use this time to inform the user of progress.
 * `statusConnectionWillReconnect`: Notify the receiver that the connection logic will reconnect.
 * `statusConnectionSucceeded`: Notify the receiver that the connection logic has completed successfully. Use this to inform the user of great success.
 * `statusConnectionFailed`: Notify the receiver that the connection logic has completed with a failure. Use this to inform the user of what went wrong. Includes an NSError describing the issue.
   ++Parameter++ : `notification` : The notification kicked back from the NotificationCenter. object property holds `NSError` type.
* `statusConnectionWillDisconnect`: Notify the receiver that the disconnection logic is about to take place. Use this time to prep for the disconnection and to inform the user of progress.
* `statusConnectionDidDisconnect`: Notify the receiver that the disconnection logic has completed. Use this to inform the user the disconnection has finished.
* `statusConnectionActive`: Notify the receiver that the connection is currently in an active state.
* `statusNetworkMonitorUpdate`: Notify the receiver about incoming and outgoing network data used. Includes a bandwidth object with this information.
 ++Parameter++ : `notification` : The notification kicked back from NotificationCenter. object property holds type `VPNBandwidthModel`
* `connectionShouldDisconnect`:
* `connectionShouldConnect`:
* `networkConnectionStatusChanged`: Notifies the receiver that the network connection status has been changed

```sh
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
}
```
    