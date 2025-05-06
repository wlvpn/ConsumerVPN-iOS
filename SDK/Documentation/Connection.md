# Connect

Select the desired VPN server location from the list. If not selected, VPN will be connected to the `Fastest Available` server. The algorithm selects the best server considering several factors like closeness, load etc. Once the location is selected a VPN connection can be started by calling the `connect()` method.
```swift
    apiManager.vpnConfiguration.country = <#Country>
    apiManager.vpnConfiguration.city = <#City>
    apiManager.vpnConfiguration.server = <#Server>
    apiManager.connect()
```
As soon as method is called `VPNConnectionStatusReporting` Notifications are fired.


# Disconnect
   To disconnect from the VPN, call the `disconnect()` method 
```swift
  apiManager.disconnect()
``` 
As soon as the method is called `VPNConnectionStatusReporting` Notifications are fired


# Install WireGuard system extension.(macOS only)
* Before using the `connect()` method check whether **WireGuard system extension** is installed or not. 
* The installation status will be reported as a notification. `VPNHelperInstallSuccessNotification` for a Successful installation or in the event of an error `VPNHelperInstallFailedNotification`.

Methods:

Check if the WireGuard system extension is installed or not.
- `(BOOL)systemExtensionInstalled;`

Check if the WireGuard system extension is pending for user approval.
- `(BOOL)systemExtensionApprovalPending;`

Installs WireGuard system extension.
- `(void)installSystemExtension;`

Uninstalls WireGuard system extension.
- `(void)uninstallSystemExtension;`


# Implementation notes:

Notifications regarding Login can be found:
> Refer: [Notifications](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Notifications.md)
   
Errors based on error codes can be found:
> Refer: [Errors](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Errors.md)
