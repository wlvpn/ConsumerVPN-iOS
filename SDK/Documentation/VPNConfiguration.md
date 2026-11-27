# VPNConfiguration
 This class manages the state of the VPN configuration and API state for the app. You can set/get the current user, account, country, city, server, etc.... you can also set VPN connection options such as on-demand.

# Properties

```markdown
- `stayConnectedOnQuit`                     : Bool - If true, the VPN will stay connected on quit. If false, the VPN will not stay  connected on quit.
- `onDemandConfiguration`                   : VPNOnDemandConfiguration -  An object that represents on-Demand rules.
- `user`                                    : User - An object that represents the current *login credentials*. Login will create a User and assign one or more accounts.
- `server`                                  : Server - An object for which a connection should be attempted, or that the user is currently connected to.
- `city`                                    : City - An object for which a connection should be attempted, or that the user is currently connected to.
- `country`                                 : Country - An object for which a connection should be attempted, or that the user is currently connected to.
- `currentLocation`                         : VPNCurrentLocationModel - The current location model for the current vpnConfiguration user location.
- `selectedProtocol`                        : VPNProtocol - The currently selected VPN protocol.
- `defaultProtocol`                         : VPNProtocol - The default VPN protocol. It can be set at `VPNAPIManager` initialization. 
- `usingAutoselectedCountry`                : BOOL - If true country will be selected automatically else user has to provide.
- `usingAutoselectedServer`                 : BOOL - If true server will be selected automatically else user has to provide..
- `usingAutoselectedCity`                   : BOOL - If true city will be selected automatically else user has to provide..
- `allowCityOnlySelection`                  : BOOL - If true user can provide city only option.
- `isMultihopEnabled`                       : BOOL - If true multihop is enabled and maximum 2 cities are supported as entry and exit.
- `multihopCities`                          : [City] - The list of cities for multihop. Order is important, the first element is the entry city, the last element is the exit city.
- `connectedServers`                        : [Server] - Read only. The list of connected servers for multihop after connection.
- `shouldSkipVirtualServerInLoadBalance`    : BOOL - If true, when establishing connection with Optimal Location, the virtual servers won't be taken into account.
- `shouldUseAPIBasedServerSelection`        : BOOL - If true, API-based server selection is used when establishing a connection to the Optimal Location. If false, the local load-balancing algorithm is used directly.
- `postQuantumResistanceSettings`           : VPNPostQuantumResistanceSettings - The post-quantum resistance (WireGuard) settings: `quantumResistanceEnabled` (default NO). See [Quantum-resistant server retry](#quantum-resistant-server-retry).
- `serverFeatures`                          : NSSet<NSNumber *> - The best available server for the city is selected based on the provided set of VPNServerFeature enum values.
- `openVPNSettings`                         : VPNOpenVPNSettings - An object for OpenVPN options like port, protocol type, scramble, etc.
```

# Methods

```swift
1. `(void)setCityAndCountry:(City *_Nullable)city;`
   Description: Sets the country, then the city, using a city object;
   Parameter: city The city to set into the VPNConfiguration
```

```swift
2. `(void)setOption:(id _Nullable )option forKey:(NSString *_Nonnull)key;` 
   Description: Sets an option in the vpn options dictionary and updates any KVO observers
   Parameter: - option - The new value to be updated in the options dictionary.
              - key    - The key for the option in the options dictionary.
```

```swift
3. `(id _Nullable )getOptionForKey:(NSString *_Nonnull)key;`
   Description: Returns a value from the options dictionary for the specified key.
   Parameter: key - The specified key to perform a lookup with.
```

```swift
4. `(BOOL)hasOptionForKey:(NSString *_Nonnull)key;`
   Description: Returns whether or not the requested option is set.
   Parameter: The key for the option in the options dictionary.
```

```swift
5. `(BOOL)isValidConfigurationWithError:(NSError *_Nullable*_Nullable)error;`
   Description: Verify that the current configuration is a valid and connectable configuration.
   Parameter: error Message containing the error.
```

# Implementation notes:

Implementation regarding On Demand can be found:
> Refer: [VPNOnDemandConfiguration](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/On%20Demand.md)

Implementation regarding OpenVPN can be found:
> Refer: [VPNOpenVPNSettings](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/VPNOpenVPNSettings.md)
   
Errors based on error codes can be found:
> Refer: [Errors](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Errors.md)

# Quantum-resistant server retry

When `postQuantumResistanceSettings.quantumResistanceEnabled` is `true` and the WireGuard quantum-resistant (PQR) transition fails after the tunnel connected, VPNKit disconnects, moves to another server in the same city and reconnects.

- **Requirements**: WireGuard protocol, with `quantumResistanceEnabled` set to `true` in `postQuantumResistanceSettings`. There is no separate switch for the disconnect or the retry. The retry continues from the disconnect that the adapter performs when the transition fails. The adapter reads `quantumResistanceEnabled` from these settings each time a connection starts.
- **HTTP 405**: if the server's key endpoint answers HTTP 405 (`VPNQuantumResistanceEndpointNotSupported (6005)`), there is no retry and no disconnect: the classical WireGuard connection is kept and the connected state is released. The error is reported through `VPNQuantumResistenceFailedNotification` only.
- **Order**: the adapter's own internal PQR retries run first. A server retry only starts once they are exhausted.
- **Server choice**: the failing server is dropped for the rest of the connection attempt and the least loaded remaining server of the city (honouring `serverFeatures`) is used. At most 3 server retries are made.
- **User-selected server**: if the user picked a specific server (a server was already set on `VPNConfiguration` when `connect` was called), no retry is made.
- **Connection state**: the app stays in its connecting state until the transition has a verdict. `VPNConnectionSucceededNotification` is held until the transition completes, and `VPNConnectionDidBeginNotification`, `VPNConnectionWillDisconnectNotification` and `VPNConnectionDidDisconnectNotification` are not delivered between retry attempts. The disconnect of the last failed tunnel is not delivered either: hosts go from connecting straight to the connection failure below.
- **Cancelling**: a user-initiated `disconnect:` or a new `connect` cancels the retry loop and resets its state.
- **Retry failed**: when no retry is possible or the 3 retries are exhausted, VPNKit posts `VPNConnectionFailedNotification` once per connection attempt, only if the user is left disconnected. It replaces the disconnect of the failed tunnel, so hosts must reset their connection state when they handle it. The error has code `VPNQuantumResistanceServerRetriesExhausted (6004)`, so hosts can tell it apart from other connection failures. If the connection stays up without quantum resistance (HTTP 405), the connected state is released and no failure notification is posted.
- **Safety timeouts**: the connected notification is held for at most 60 seconds without a verdict, and retry suppression lasts at most 90 seconds.

Failed attempts are reported by the adapter through `VPNQuantumResistenceFailedNotification` on every failure, including a failure on a user-selected server. The 6004 error carries the reason, the city and the number of failures in `VPNQuantumResistanceFailureReasonKey`, `VPNQuantumResistanceFailureCityKey` and `VPNQuantumResistanceFailureAttemptKey`.
