# VPNKit 5.x -> 6.x Upgrade Guide

## Renamed Items

VPNFrameworkUsageError becomes VPNKitFrameworkUsageError to improve Swift compatibility.

## Configuration Changes

### Configuration Objects

_*In Progress*_

We've now added typed configuration objects. These objects can be used in lieu of the legacy configuration objects. They
are also more compatible with Swift. 

### Legacy Configuration

Add `kV3ServiceNameKey` to the `V3APIAdapter` initialization code. This is the name of the keychain item to use
when storing login and VPN credentials in the keychain. This should be the name of your app. If you set this to 
to "My VPN App" then the API adapter will create services with names like "My VPN App Login" and 
"My VPN App Access Token". 

Add `kIKEv2KeychainServiceName` to the `NEVPNManagerAdapter`. This is the name of the keychain item to use when
connecting to the VPN. In most cases this should be set to:

```
apiAdapter.passwordServiceName
```

Remove the following keys, if present, from your VPNAPIManager configuration:

`kVPNServiceNameKey`
`kVPNOldServiceNameKey`
`kBrandNameKey`

## User Object

Removed two deprecated properties: `userID` and `accountID`. Use the `username` property instead.

## Notification Handlers

Notification handlers were updated to all accept an NSNotification object as a parameter. Please 
update your event handlers as needed. You can use the strings below to run a find/replace on your codebase. 
Depending on your coding standards, you may need to remove the space between "-" and "(void)".

The following notification handlers were updated to accept an NSNotification object:

```
- (void)statusLogoutWillBegin
- (void)statusLogoutWillBegin:(nonnull NSNotification *)notification

func statusLogoutWillBegin()
func statusLogoutWillBegin(_ notification: Notification)
```

```
- (void)statusLogoutSucceeded
- (void)statusLogoutSucceeded:(nonnull NSNotification *)notification

func statusLogoutSucceeded()
func statusLogoutSucceeded(_ notification: Notification)
```

```
- (void)statusAccountExpired
- (void)statusAccountExpired:(nonnull NSNotification *)notification

func statusAccountExpired()
func statusAccountExpired(_ notification: Notification)
```

```
- (void)statusConnectionWillBegin
- (void)statusConnectionWillBegin:(nonnull NSNotification *)notification

func statusConnectionWillBegin()
func statusConnectionWillBegin(_ notification: Notification)
```
```
- (void)statusConnectionDidBegin
- (void)statusConnectionDidBegin:(nonnull NSNotification *)notification

func statusConnectionDidBegin()
func statusConnectionDidBegin(_ notification: Notification)
```

```
- (void)statusConnectionWillReconnect
- (void)statusConnectionWillReconnect:(nonnull NSNotification *)notification

func statusConnectionWillReconnect()
func statusConnectionWillReconnect(_ notification: Notification)
```

```
- (void)statusConnectionSucceeded
- (void)statusConnectionSucceeded:(nonnull NSNotification *)notification

func statusConnectionSucceeded()
func statusConnectionSucceeded(_ notification: Notification)
```

```
- (void)statusConnectionWillDisconnect
- (void)statusConnectionWillDisconnect:(nonnull NSNotification *)notification

func statusConnectionWillDisconnect()
func statusConnectionWillDisconnect(_ notification: Notification)
```

```
- (void)statusConnectionDidDisconnect
- (void)statusConnectionDidDisconnect:(nonnull NSNotification *)notification

func statusConnectionDidDisconnect()
func statusConnectionDidDisconnect(_ notification: Notification)
```

```
- (void)statusConnectionActive
- (void)statusConnectionActive:(nonnull NSNotification *)notification

func statusConnectionActive()
func statusConnectionActive(_ notification: Notification)
```

```
- (void)statusServerCapacityWarning
- (void)statusServerCapacityWarning:(nonnull NSNotification *)notification

func statusServerCapacityWarning()
func statusServerCapacityWarning(_ notification: Notification)
```

```
- (void)statusInitialServerUpdateWillBegin
- (void)statusInitialServerUpdateWillBegin:(nonnull NSNotification *)notification

func statusInitialServerUpdateWillBegin()
func statusInitialServerUpdateWillBegin(_ notification: Notification)
```

```
- (void)statusServerUpdateWillBegin
- (void)statusServerUpdateWillBegin:(nonnull NSNotification *)notification

func statusServerUpdateWillBegin()
func statusServerUpdateWillBegin(_ notification: Notification)
```

## MOBIKE recovery

Whenever VPNKit detects that a connection using IKEv2 fails, it will attempt to recover by setting `kIKEv2DisableMobike` and `kIKEv2UseIPAddress` in the given VPNConfiguration object, then reconnecting. If this reconnection attempt fails, VPNKit will post a connection failed notification. You may monitor this process by checking Debug logs and filtering logs that contain the string "ErrorState".

# VPNKit 6.1 -> 6.2 Updates

## Renamed Items

`VPNKitChinaError` has been renamed `VPNKitLoginErrorDomainBlocked`. In previous versions of VPNKit, we would attempt to recover from a blocked domain in an unsafe way, without reporting the issue to the client application. We now correctly report blocked domains to the client application. 

The constant name for the NSUserDefaults log level key has changed. Instead of using `kVPNCurrentLogLevel`, please use `kVPNCurrentLogLevelKey`.

## New Items

Added captive portal checking to automatically detect when internet connectivity is blocked on networks that require the user to login through a website before accessing the internet.

# VPNKit 6.2 -> 6.3 Updates

No breaking changes were instroduct between 6.2 and 6.3.

# VPNKit 6.3 -> 6.4 Updates

## Removed Functionality

"Helper install" has been deprecated. No longer need helper should/will install or anything related to that. Added update configuration function to set on demand and other configuration options. Otherwise updated automatically on connect.

Removes activate/deactivate adapter for connection adapters

Removed VPNStatusFailed. Everything standardized as VPNStatusError.

# VPNKit 6.4 -> 6.5 Updates

Minimum SDK support is now from iOS 12+ and macOS 10.14+

## New Items

Adds `CountryCode` property in VPN location information

Adds `IsActive` function to the User object

Adds login with retries API to ensure that the application will log in after a successful purchase

Adds new adapter option `StayConnectedOnQuit` to ensure that the VPN connection remains active when the client gets closed during an active connection

Adds the following notification handler methods for knowing the status when the configuration is synchronized:
```
// Notify the receiver that the attempt to update the configuration was successful
- (void)updateConfigurationSuceeded:(nonnull NSNotification*)notification;

// Notify the receiver that the attempt to update the configuration failed.
- (void)updateConfigurationFailed:(nonnull NSNotification*)notification;
```

Allows retry count to be set via config option for connecting to VPN

Introduces better error management, VPNKit will now send error codes with error messages to ease localization

Logout clears the VPNProfiles from the device settings

The user won’t be logged out after a device shut down

The VPN configuration name is now customizable

The login operation makes an immediate server list fetch, it is now unnecessary to fetch the server list immediately after login

OS version, app version, and logging level logs output on startup

Replaces InstallHelper notifications with `VPNUpdateConfigurationSuccessNotification` and `VPNUpdateConfigurationFailedNotification`

Replaces InstallHelper method with `SynchronizeConfiguration` for updating VPN configuration

Separates new `VPNOnDemandConfiguration` class for VPN On Demand settings

Supports brand name in authorization prompt used for installing a helper tool

Updates timer refresh interval from 15 mins to 30 mins for fetching server list

## Removed Functionality

Removes insecure protocols PPTP/SSTP/L2TP

Removes Ethernet rule in OnDemandConfiguration

## Renamed Items

Renames killSwitch methods with `activateAdapter` and `deactivateAdapter` methods

Renames `removeHelperWithCompletionHandler` with `renameConfiguration:withCompletion:`
