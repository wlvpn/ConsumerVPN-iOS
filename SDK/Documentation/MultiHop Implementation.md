# MultiHop Implementation

# `MultiHop`
The multihop feature enhances the anonymity and security of VPN connections by introducing an entry
and exit point, thereby adding an extra layer of protection to user data.
The user's connection will enter through one server and exit through another server.


### Implementation

1. **isMultihopEnabled** property is a read-only computed property that checks whether multihop cities (entry) and the exit city are set.
2. Set the entry or hop city to **multihopCities** property and exit city to **city** property.
3. Call the connection function.
4. After a successful connection, the **connectedServers** property is updated on `VPNConfiguration`.
5. Sample implementation for WireGuard/OpenVPN:

```swift
apiManager.vpnConfiguration.multihopCities = // Array of City as entry or hop(s).
apiManager.vpnConfiguration.city = // Single city object as exit city.
self.apiManager.connect()
```
 - Client will get the **connectedServers** in **statusConnectionSucceeded** notification
```swift
func statusConnectionSucceeded(_ notification: Notification) {
    guard let vpnConfiguration = apiManager.vpnConfiguration, vpnConfiguration.isMultihopEnabled else { return }
    
    if let entryServer = vpnConfiguration.connectedServers?.first {
        //Update UI
    }
    if let exitServer = vpnConfiguration.connectedServers?.last {
        //Update UI
    }
}
```

# Implementation notes:

- Works with `WireGuard` and `OpenVPN` only.
- The `OpenVPN` port setting is ignored when Multihop is enabled.
- The `Scramble` setting is ignored when Multihop is enabled.
- Errors based on error codes can be found:

> Refer: [Errors](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/Documentation/Errors.md)
