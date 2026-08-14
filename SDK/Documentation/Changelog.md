# VPNKit Changelog

## VPNKit 7.2.0

### New Items
- Added `VPNOpenVPNSettings` class which holds port, protocol types, etc under `VPNConfiguration`. refer to [VPNOpenVPNSettings](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/VPNOpenVPNSettings.md)
- Added `OpenVPN` support for iOS using Network Extension. refer to [OpenVPN+NE Implementation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/OpenVPN+NE%20Implementation.md)
- Added `OpenVPN` support for macOS using Network Extension. refer to [OpenVPN+NE Implementation](https://github.com/wlvpn/ConsumerVPN-macOS/blob/main/SDK/Documentation/OpenVPN+NE%20Implementation.md)
- Implemented OpenVPN handshake update functionality. refer to [VPNOpenVPNSettings](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Handshake%20Update%20Implementation.md)
- Added a `quantumResistanceEnabled` flag to `WireGuardAdapterConfiguration` to toggle the quantum-resistant transition. Default is true, meaning quantum resistance is enabled.
- Added an `allowDisconnectOnQuantumResistanceFailure` flag to `WireGuardAdapterConfiguration` to control whether the VPN disconnects if the post-connect quantum-resistant transition fails. Default is false, which preserves the existing classical WireGuard session. This flag has only effect when `quantumResistanceEnabled` is set to true.
- Updated OpenVPN from v2.4 to v2.6.
- Added the `OSSystemExtensionsWorkspaceObserver` for `OpenVPN` and `WireGuard` support on macOS 15.1 and later.
- Added a `clientManagesSystemExtension` flag to `OpenVPNAdapterConfiguration` indicating that OpenVPN system extension installation is managed by the macOS client application using Apple APIs.
- Added new `disconnect()` method at `OVPacketTunnelProvider` to terminate the VPN connection. (Intended to use on macOS only)
- Added new `bypassAllTraffic()` method at `OVPacketTunnelProvider` to bypass all traffic from the VPN connection.
- Added new `tunnelCancelled(reason) (3005)` handshake error (OpenVPN TCP only). Raised after the SDK invokes `cancelTunnelWithError(...)` because the tunnel was stopped externally (OS, another VPN being activated, system termination, etc.). The `reason` associated value carries the raw log line for diagnostics. This notification is informational and intended for logging or user notification purposes only. When Connect-On-Demand is enabled, the VPN will reconnect automatically once internet connectivity is restored. When Connect-On-Demand is disabled, this cancellation is expected and the VPN will remain disconnected. Refer to [Handshake Update Implementation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Handshake%20Update%20Implementation.md).
- Added new `captivePortalLikely (3006)` handshake error for WireGuard and OpenVPN. Surfaced once per episode when repeated handshake failures within the post-roam window strongly suggest the current network requires HTTP sign-in (captive portal). OpenVPN additionally pauses its internal reconnect loop while suspected; both protocols clear the classification on a successful handshake or a fresh network path change. When `isKillSwitchEnabled` is `true`, the manager's `includeAllNetworks` flag must be cleared so iOS can present its captive sheet — on macOS by calling `self.disconnect(...)` from inside `vpnHandshakeUpdateDetected(_:)`, on iOS / tvOS by signaling the app target and having the app call its own disconnect API. Refer to [Handshake Update Implementation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Handshake%20Update%20Implementation.md).
- Added new `isKillSwitchEnabled` property on `OVPacketTunnelProvider` and `WGPacketTunnelProvider` reflecting the active `includeAllNetworks` value from the tunnel protocol configuration. Intended to be read from `vpnHandshakeUpdateDetected(_:)` to decide whether `captivePortalLikely` recovery requires clearing the kill switch (via `self.disconnect(...)` on macOS, or via an app-side disconnect call on iOS / tvOS).
- Added new `notifyRoamingOnce: Bool` property on `OVPacketTunnelProvider` and `WGPacketTunnelProvider` to control `.roaming` event delivery. Defaults to `true` (the SDK emits at most one `.roaming` notification per roam episode — episode boundary = successful handshake, fresh network path change, or tunnel start/stop). Set to `false` to receive a `.roaming` event on every handshake retry inside the post-roam window (diagnostics, telemetry, or aggressive recovery UI).
- Enabled OpenVPN UDP **session floating** (link rebinding) by default. Network path changes that previously required a full TLS / key renegotiation are now recovered by rebinding the existing session to the new socket. It dramatically reducing recovery latency on Wi-Fi ↔ cellular swaps and eliminating the visible "tunnel restarts on every path change" UX.
- Added `VPNQuantumResistenceFailedNotification` and `statusQuantumResistenceFailed` for WireGuard quantum resistance failures. The notification includes an `NSError` with `VPNKitQuantumResistanceError` codes in the 6000 range and failure detail keys for city, hostname, timestamp, and reason.
- Added `VPNConfigurationExtra` to configure additional VPN protocol routing flags, including local network, device communication, cellular services, route enforcement, and sleep-disconnect behavior.
- Added `systemExtensionStatus` to `VPNAPIManager` and `VPNConnectionAdapterProtocol` to report the current adapter's system extension state on macOS 15.1 and later.
- Added `VPNSystemExtensionDisabled` to `Errors.h` to report an error when the client attempts to connect while the system extension is disabled.


### Removed Items
- Removed `VPNProtocolOpenVPN_UDP` and `VPNProtocolOpenVPN_TCP` VPNProtocols.
- Removed legacy code related to OpenVPN Command Line Tool.
- Removed the unused AES-256-CBC cipher from the OpenVPN client configuration.
- Removed unwanted legacy OpenVPN+XPC handlings on logout.

### Improvements
- Changed URLSession cache policy to disable cache writes
- Improved unexpected API response handling on login endpoint to return an error and prevent false positives.
- Fix OpenVPN doublehop connection issue.
- Fix OpenVPN crash issue on macOS during migration to Network Extension support.
- OpenVPN connection will be failed when user account isn't active.
- Fixed IPSec connection issue.
- Fixed `loginWithAccessToken:refreshToken:` (token-based login) no longer reports success when the underlying network request fails.
- Fixed no internet available after connect to OpenVPN with 8080 port.
- Updated SDK APIs from v3.5 to v3.6.
- Fixed repeated VPN profile re-approval when multiple macOS users shared the same VPN account.
- Fixed OpenVPN connection not updating status change.
- Fixed `VPNUpdateConfigurationFailedNotification` on OpenVPN profile installation failure.
- Improved WireGuard and OpenVPN handshake failure classification — `HandshakeError` now distinguishes `roaming` (3002), `staleSession` (3003), and `handshakeTimeout` (3004). Refer to [Handshake Update Implementation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Handshake%20Update%20Implementation.md).
- Made `isInternetAvailable` on `OVPacketTunnelProvider` and `WGPacketTunnelProvider` reflect the live `NWPath.Status` directly instead of a log-driven cached flag. Fixes a race where a handshake failure arriving before the next path update would classify against stale state, causing real outages to be mis-classified as `.handshakeTimeout` or `.roaming` instead of `.internetUnreachable`. The property is now strictly `true` only when the active path status is `.satisfied`; `.requiresConnection` and `.unsatisfied` both read as `false`. The classifier inside `vpnHandshakeUpdateDetected(_:)` uses the same live source of truth.
- MTU set based on the OpenVPN network tunnel overhead instead device compatibility.
- Fixed issue of Objective-C class name collision originating from Bucket, Usage and Plan and renamed them to VPNV3Bucket, VPNV3Usage, VPNV3Plan inside VPNV3APIAdapter.framework
- Improve OpenVPN TCP LINK management.
- Improve error handling for Wireguard API response.
- `validate()` method from `WireGuardAdapterConfiguration` / `OpenVPNAdapterConfigurationError` now returns a typed error enum (`WireGuardAdapterConfigurationError` / `OpenVPNAdapterConfigurationError`) instead of `Bool`, enabling callers to identify the specific validation failure.
- Applied CarPlay-related protocol routing flags from `VPNConfigurationExtra` instead of `UserDefaults`.
- Fixed a Core Data persistence error that could occur during the login process on tvOS.
- Fixed a macOS issue preventing OpenVPN from connecting while Kill Switch was active.
- Improve error handling for IKEv2 API response.
- Applied additional headers to the `/doublehop` endpoint request.
- Fixed OpenVPN-UDP no internet issue when device in idle state.

### Breaking Changes
- `VPNProtocolOpenVPN_UDP` and `VPNProtocolOpenVPN_TCP` replaced with `VPNProtocolOpenVPN`.
- Removed legacy code related to OpenVPN Command Line Tool.
- Removed `kV3UUIDKey` constant and need not to set manually for `WireGuardAdapterConfiguration` or `OpenVPNAdapterConfiguration`.
- Added an optional `httpStatusCode` parameter to the completion handlers of `getIKev2ServerCredentials` and `getUserMetadata`.
- Updated `WireGuardAdapterConfiguration.validate()` to return `WireGuardAdapterConfigurationError` values (none, missingBrandName, missingAPIKey) instead of a generic `Bool` result, providing more granular validation.


## VPNKit 7.1.3

### Improvements
- Enhanced `IKEv2` error handling to gracefully manage `VPNServerUnhealthyError` and `VPNInvalidServerError`
- When connecting to a VPN server, if the connection fails with `VPNServerUnhealthyError` or `VPNInvalidServerError`, that server is now automatically removed to prevent future connection attempts to unhealthy or invalid servers. See [Fetch](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Fetch.md#refetching-updated-data) for details on refetching updated data.
- Fixed an issue where the SDK was unable to retrieve stored keychain values when the iOS device was locked.
- Fixed crash occurring during retrieval of stored keychain values.
- Rename coredata model version files without whitespaces.
- Updated all APIs version from v3.4 to v3.5. Also refactored refresh token code.
- Retrieve and send the exact account status when synchronizeConfiguration() fails due to invalid account.
- Reset last server update date on user logout to ensure fresh server sync on next login.

### New Items
- Added a `clientManagesSystemExtension` flag to `WireGuardAdapterConfiguration` indicating that WireGuard system extension installation is managed by the macOS client application using Apple APIs.
- Added support for simulators for tvOS to test UI/UX (actual connection won't happen on simulators, just a mock connection).

## VPNKit 7.1.2

### Improvements
**Security:** Fixed a macOS privilege escalation vulnerability in the OpenVPN command-line helper where insufficient validation could allow unauthorized executables to interact with the privileged helper. The SDK now enforces certificate validation and code-signing checks. Integrators must update the OpenVPN CLI tool to ensure the helper is properly updated on user systems.

## VPNKit 7.1.1

### Improvements
- `sortedServer()` in `City` and `Country` now returns the latest updated server list, not cached data.

### Breaking Changes
- Renamed property from `shouldSkipVirtualServers` (getter: `isVirtualServersSkipped`) to `skipVirtualServerInLoadBalance` (getter: `shouldSkipVirtualServerInLoadBalance`) in `VPNConfiguration` class.

## VPNKit 7.1.0

### New Items
- Added new `availableFeatures` property at `Server` model to retrieve available features on a server. For more details, see [Server Features](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/ServerFeatures.md).
- Added a new `selectedFeatures` property to `VPNConfiguration`, allowing the option to filter servers based on selected features when connecting to the optimal location.

## VPNKit 7.0.1

### New Items
- Added new `vpnHandshakeUpdateDetected(_ error: Error?)` method at `WGPacketTunnelProvider`. Refer at [Handshake Update Implementation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Handshake%20Update%20Implementation.md)
- Added new properties to `WGPacketTunnelProvider`:
    - `lastHandshakeDate`   : `Date?` which indicates date timestamp of the last successful handshake.
    - `isInternetAvaialble` : `Bool` which indicates the current network status. 

### Removed Items
- Removed `vpnHandshakeFailureDetected()` method from `WGPacketTunnelProvider`.
- Removed `getLastHandshake()` method from `WGPacketTunnelProvider`.

### Improvements
- `lastHandshakeDate` reports correct last handshake date.
- The timeout for Web service API calls has been updated to 5 seconds.
- Added default base URL and fallback URLs for `/account` API.
- Updated The default Diffie-Hellman group for IKEv2 VPN configurations from Group 2 (MODP 1024) to Group 14 (MODP 2048) to comply with Apple’s latest platform security requirements.
- Fixed no internet available notification not sent.
- Fixed Deferred Account error code conflicts.
- Corrected default URLs for VPNAPIManager metadata account APIs.

### Breaking Changes
- Replaced `vpnHandshakeFailureDetected()` with `vpnHandshakeUpdateDetected(_ error: Error?)` optional method at `WGPacketTunnelProvider`.
- Replaced `getLastHandshake()` method with new `lastHandshakeDate` and `isInternetAvaialble` properties at `WGPacketTunnelProvider`.

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
