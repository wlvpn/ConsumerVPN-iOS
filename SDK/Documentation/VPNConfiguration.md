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
- `shouldSkipVirtualServerInLoadBalance`    : BOOL - If true, when establishing connnection with Optimal Location, the virtual servers won't be taken into account.
- `serverFeatures`                          : NSSet<NSNumber *> - The best available server for the city is selected based on the provided set of VPNServerFeature enum values.
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
