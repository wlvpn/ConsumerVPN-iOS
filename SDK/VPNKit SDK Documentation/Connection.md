# Connect
Select the desired location from the list. If not selected or completely nil VPNConfiguration, VPN will be connected to the `Fastest Available` server. The algorithm selects the best server considering several factors like closeness, load etc. Once the location is selected a VPN connection can be started calling the connect() method
```
  apiManager.connect()
```
As soon as method is called VPNConnectionStatusReporting Notifications are fired


# Disconnect
   To disconnect from the VPN, call the disconnect() method 
```
  apiManager.disconnect()
``` 
As soon as the method is called VPNConnectionStatusReporting Notifications are fired

# For macOS only
# Install WireGuard system extension.
* Before using the `connect()` method check whether WireGuard system extension is installed or not. 
* The installation status will be reported as a notification. VPNHelperInstallSuccessNotification for a Successful installation or in the event of an error VPNHelperInstallFailedNotification

Methods:
Check if the WireGuard system extension is installed or not.
- `(BOOL)systemExtensionInstalled;`

Check if the WireGuard system extension is pending for approval.
- `(BOOL)systemExtensionApprovalPending;`

Installs WireGuard system extension.
- `(void)installSystemExtension;`

Uninstalls WireGuard system extension.
- `(void)uninstallSystemExtension;`
