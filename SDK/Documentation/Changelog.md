# VPNKit Changelog

## VPNKit 7.0.0

### New Items
- Added `VPNConnectionHealthUpdateNotification` notification for WireGuard to check VPN connection is healthy or not.
- Added new properties to `Server`:
  - `scheduledMaintenanceStarts`: Date, which indicate the scheduled maintenance start time for the server.
  - `scheduledMaintenanceEnds`: Date, which indicate the scheduled maintenance end time for the server.
- It is recommended to set the `apiKey` property within the `WireGuardAdapterConfiguration` for optimal functionality.
- Added new `disconnect()` method at `WGPacketTunnelProvider` to terminate the VPN connection.
- Added new `bypassAllTraffic()` method at `WGPacketTunnelProvider` to bypass all traffic from the VPN connection.
- Added a new `isVirtualServersSkipped` property to `VPNConfiguration`, allowing the option to skip virtual server selection when connecting to the optimal location. The default value is false.
- Added new `getLastHandshake()` method at `WGPacketTunnelProvider` to retrieve the last successful handshake timestamp and current network status.
- Added new `isOnDemandEnabled` property at `WGPacketTunnelProvider` to determine if the VPN connection is on-demand.
- Introduced a new `availableEntitlements` property in `VPNAPIManager` that lists the available product entitlements.
- Added new `updateAccountConfiguration()` method at `VPNAPIManager` to update account configuraiton.
- Added new `vpnHandshakeFailureDetected()` method at `WGPacketTunnelProvider`. Subclasses can now override this method to receive notifications and handle VPN handshake failures according to their specific requirements.
- Added new `helperStatus` property at `VPNAPIManager` to determine the current status of the VPN helper installation (macOS only).
- Added new error code `VPNSystemExtensionNotInstalled`, `VPNSystemExtensionNotApproved`  on `synchronizeConfiguration` to determine the current status of the VPN helper installation (macOS only).


### Removed Items
- Removed Protocol API endpoint along with `ServerProtocol` and `ProtocolType` Models.
- Removed `icon`,`scheduledMaintenance` and 'protocols' properties from `Server` model.
- Removed `kV3InitialServersKey` and `kV3InitialProtocolsKey` keys.

### Improvements
- Updated OpenVPN documentation.
- Fixes consistency on double-hop connections.
- Fixes subsequent connection errors when the bandwidth quota is reset.
- VPN Profile(s) will only get removed during manual logout.
- Fixes crash when traffic counter active and PacketTunnelProvider gets deallocated.
- Fixes refresh token API not executed when access token expired on remote.
- Optimize the multihop flow at `VPNConfiguration`.
  - **isMultihopEnabled** property read-only.
  - **multihopCities** contains hop cities which include also entry server. 
  - **city** property should set as exit city.
- Improves token management:
  - `Token based authentication` - Increased the coverage for the token expiration management. The SDK will keep sending `VPNLogoutSucceededNotification` which has `VPNTokenExpiredError` error as an notification object when the authentication tokens are expired/invalidated. The implementer needs to re-authenticate the user.
  - `Password based authentication` - Upon token invalidation/expiration, the SDK will attempt to re-authenticate the user using the saved email and password. If the authentication fails, will send `VPNLogoutSucceededNotification` notification which has `VPNReauthenticationFailed` error as an  notification object. The implementer needs to re-authenticate the user.
- Update all APIs version from v3.1 to v3.4.
- Resolved WireGuard Doublehop with Kill switch connection issue.
- Resolved IKEv2 / IPSec protocol all trusted WiFi + untrusted WiFi(s) on-demand connection issue.
- The timeout for Web service API calls has been updated to 30 seconds.
- On `synchronizeConfiguration`, added `VPNHelperInstallSuccessNotification` if helper installation done successfully.
- Fixes crash on device wake up with an active traffic counter.
- Fixes incorrect VPN health check or network status for certain servers.
- Fixes WireGueard Internet is not working after VPN Connection for certain servers.
- Update all APIs version from v3.4 to v3.5.
- Fixes Wi-Fi information unavailable after VPN disconnect.
- Fixes network status not sync with available network.
- Sends VPN health update notification on network change when using WireGuard.
- Fixes crash on VPN health check timeout timer.

### Breaking Changes
- The `isMultihopEnabled` flag from `VPNConfiguration` is no longer required to set for establishing a multihop connection.

## VPNKit 6.9

### New Items
- Added support for simulators for WireGuard to test UI/UX (actual connection won't happen on simulators, just a mock connection).

### Removed Items
- Removed refresh location call from VPN disconnect or network reconnect.
- Removed support for `kV3LocationURLKey` from `V3APIAdapter` options. Now the Location URL will be generated from the base URL.

### Improvements
- Improved logs and error handling.
- WireGuard VPN configuration will be requested again if it fails with `NEVPNError.configurationStale`.
- System Extension updated based on Network Extension Target version and build number.
- Resets the device's DNS after a force quit while using OpenVPN.
- Fixed VPN configuration issues after certain endpoints failed to load.
- Optimized endpoint usage.
- Fixed an issue where VPNKit asked to reinstall the VPN Profile after a logout.
- Improved VPN stability for WireGuard.
- Embedded base URL and API mirrors into the SDK.

### Breaking Changes
- The `kV3LocationURLKey` from `V3APIAdapter` options is no longer necessary. The IPGeo request will work without it.

## VPNKit 6.8

### New Items
- Added new properties to `VPNBandwidthModel`:
  - `lastUploadPerSecond`: Data sent per second.
  - `lastDownloadPerSecond`: Data received per second.
- Added new API `refreshLocation` with completion in `VPNAPIManager`.
- Added `Threat Protection` support on OpenVPN (macOS only) and WireGuard protocols.
- Added `Split Tunneling` support on OpenVPN protocol (macOS only).
- Created new `vpnhelper.xcframework` for OpenVPN command line tool (macOS only).
- Created new `VPNHelperAdapter.framework` for OpenVPN protocol adapter (macOS only).
- Added new login API by access token.
- Added new error codes for `synchronizeConfiguration` during user login:
  - `VPNLoginInProgressError`: Login in progress.
  - `VPNInactiveError`: User inactive.
  - `VPNInvalidLoginError`: User not logged in.
- Added Apple TV `tvOS` support for `IKEv2` protocol.
- Added new metadata APIs.
- `WireGuard` `extensionName` must be passed to `WireGuardAdapterConfiguration`.
- Added `Multihop` support for WireGuard and OpenVPN protocols.
- Added `Passive Kill Switch` support for all protocols.
- Added new API `account` with completion in `V3APIAdapter` based on account status.
- Added new error codes under `User Account Validation Errors`:
  - `VPNKitAccountCapReachedError`
  - `VPNKitAccountPausedError`
  - `VPNKitAccountSuspendedError`
  - `VPNKitAccountClosedError`
  - `VPNKitAccountPendingError`
  - `VPNKitAccountInvalidError`

### Removed Items
- Removed unwanted terminal logs.
- Removed notifications related to the server list fetch during login.

### Renamed Items
- Renamed VPNKit User Account Validation errors:
  - `VPNKitAccountErrorBase` = 1500: Invalid account
  - `VPNKitAccountCapReachedError` = 1500: Account cap reached
  - `VPNKitAccountPausedError` = 1501: Account paused
  - `VPNKitAccountSuspendedError` = 1502: Account suspended
  - `VPNKitAccountClosedError` = 1503: Account closed
  - `VPNKitAccountPendingError` = 1504: Account pending
  - `VPNKitAccountInvalidError` = 1510: Invalid account runtime error

### Improvements
- Bug fixes.
- Improved logs and error handling.
- Enhanced accuracy of the traffic counter.
- Disabled `Split Tunneling`, `Kill Switch`, and `Connect On Demand` on VPN disconnect and protocol change.
- Connection notifications now include status code in notification object user info.
- OpenVPN Command Line tool updates automatically based on the defined version update.
- Internal logout on receiving `Refresh token error`, profile configuration file not deleted.
- Profile configuration file deleted on user-initiated logout.
- Reset VPN configuration on protocol change for `Connect On Demand`, `Kill Switch`, and `Split Tunneling`.
- Improved Kill Switch implementation for WireGuard, IKEv2, and IPSec protocols.
- Connect-On-Demand, Split Tunnel, or Kill Switch will not reset in `VPNConfiguration` on VPN disconnect or protocol change.
- WireGuard VPN configuration requested again if it fails with `NEVPNError.configurationStale`.
- Protocol change notifications for `statusCurrentProtocolDidChange`.

### Breaking Changes
- `VPNLoginServerUpdateWillBeginNotification`, `VPNLoginServerUpdateSucceededNotification`, and `VPNLoginServerUpdateFailedNotification` removed.
- Deprecated methods removed from User object.
- Reset VPN configuration on protocol change for `Connect On Demand`, `Kill Switch`, and `Split Tunneling`.

## VPNKit 6.7

### New Items
- Added `installSystemExtension()` API to install WireGuard System Extension.
- Added `Split Tunneling` support.
- Updated OpenVPN certificate.
- Bug fixes and improved protocol functionality.
- OpenVPN/Legacy privileged helper.

### Renamed Items
- Replaced `InstallHelper` notifications with `VPNUpdateConfigurationSuccessNotification` and `VPNUpdateConfigurationFailedNotification`.

### Breaking Changes
- Split tunneling and protocol change handling updated, ensuring that `Split Tunneling`, `Kill Switch`, and `Connect On Demand` settings are reset as needed.

## VPNKit 6.6

### MOBIKE Recovery
- VPNKit attempts recovery by setting `kIKEv2DisableMobike` and `kIKEv2UseIPAddress` if IKEv2 connection fails.
- Added APIs for installing and uninstalling WireGuard System Extension.
- Added delegate methods for installation status reporting and connection status changes.

### Renamed Items
- `VPNFrameworkUsageError` becomes `VPNKitFrameworkUsageError`.

### Configuration Changes
- Added typed configuration objects.
- Updated legacy configuration with new keychain items and removed obsolete keys.
- Removed deprecated properties from the User object.
- Updated notification handlers to accept `NSNotification` objects.

### Breaking Changes
- Configuration changes require updates to keychain items and removal of obsolete keys.
- Deprecated properties removed from User object.

## VPNKit 6.5

### New Items
- Added `CountryCode` property to VPN location information.
- Added `IsActive` function to the User object.
- Added login with retries API.
- Added `StayConnectedOnQuit` adapter option.
- Added new notification handler methods for configuration synchronization status.
- Added retry count configuration option for VPN connection.
- Improved error management with error codes.
- Logout clears VPNProfiles from device settings.
- VPN configuration name is now customizable.
- Immediate server list fetch on login.
- OS version, app version, and logging level logged on startup.
- Separated new `VPNOnDemandConfiguration` class.
- Brand name support in authorization prompt.
- Updated server list fetch interval to 30 mins.

### Removed Functionality
- Removed insecure protocols PPTP/SSTP/L2TP.
- Removed Ethernet rule in `OnDemandConfiguration`.

### Renamed Items
- Renamed kill switch methods to `activateAdapter` and `deactivateAdapter`.
- Renamed `removeHelperWithCompletionHandler` to `renameConfiguration:withCompletion`.
- Renamed `status` to `connectionStatus` in `VPNAPIManager`.

### Breaking Changes
- Removal of insecure protocols requires updates to configurations using these protocols.
- Renamed methods require updates to any implementations using the old method names.
- Renamed `status` to  `connectionStatus` require updates to any implementations using the old property names.

## VPNKit 6.4

### Removed Functionality
- Deprecated "Helper install".
- Removed activate/deactivate adapter for connection adapters.
- Standardized `VPNStatusFailed` as `VPNStatusError`.

### Breaking Changes
- Removal of deprecated "Helper install" functionality requires updates to connection management implementations.

## VPNKit 6.3

### Improvements
- Bug fixes

## VPNKit 6.2

### Renamed Items
- `VPNKitChinaError` renamed to `VPNKitLoginErrorDomainBlocked`.
- `kVPNCurrentLogLevel` renamed to `kVPNCurrentLogLevelKey`.

### New Items
- Added captive portal checking to detect network login requirements.

### Breaking Changes
- Renamed items require updates to implementations using the old names.
