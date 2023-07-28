# VPNConfiguration
 This class manages the state of the VPN configuration and API state for the app. You can set/get the current user, account, country, city, server, etc.... you can also set VPN connection options such as on-demand.

# Properties
1. `stayConnectedOnQuit`: Bool - If true, the VPN will stay connected on quit. If false, the VPN will not stay     connected on quit.
2. `onDemandConfiguration`: readonly: VPNOnDemandConfiguration: If non-null, contains the active on demand rules.
3. `user`: User - An object that represents the current *login credentials*. Login will create a User and assign one or more accounts.
4.  `server`: Server - The Actual Server the User will or is connected to. Should be set on connect.
5.  `city`: City - The city for which a connection should be attempted, or that the user is currently connected to.
6.  `country`: Country - The country for which a connection should be attempted, or that the user is currently connected to.
7.  `currentLocation`: VPNCurrentLocationModel - The current location model for the current vpnConfiguration.
8.  `selectedProtocol`: VPNProtocol - The currently selected protocol
9.  `getSelectedProtocolName`: String - Returns the string representation of the currently selected protocol
10. `defaultProtocol`: VPNProtocol - The default protocol
11. `usingAutoselectedCountry`: BOOL - Stores whether or not the VPN Configuration is using
12. `usingAutoselectedServer`: BOOL - Stores whether or not the VPN Configuration is using
13. `usingAutoselectedCity`: BOOL - Stores whether or not the VPN Configuration is using
14. `allowCityOnlySelection`: BOOL - Stores whether or not the VPN Configuration is using

# Methods
1. `(instancetype _Nullable )initWithOptions:(NSDictionary *_Nullable)options
                                  onDemand:(VPNOnDemandConfiguration * _Nullable)configuration;`
  Description:
  Initialize the VPNConfiguration with the provided options.
  Allows you to mass set options on instantiation
  Returns an instantiated VPN Configuration with the provided options

2. `(void)setCityAndCountry:(City *_Nullable)city;`
   Description: Sets the country, then the city, using a city object;
   Parameter: city The city to set into the VPNConfiguration

3. `(void)setOption:(id _Nullable )option forKey:(NSString *_Nonnull)key;` 
   Description: Sets an option in the vpn options dictionary and updates any KVO observers
   Parameter: - option - The new value to be updated in the options dictionary.
              - key    - The key for the option in the options dictionary.

4. `(id _Nullable )getOptionForKey:(NSString *_Nonnull)key;`
   Description: Returns a value from the options dictionary for the specified key.
   Parameter: key - The specified key to perform a lookup with.

5. `(BOOL)hasOptionForKey:(NSString *_Nonnull)key;`
   Description: Returns whether or not the requested option is set.
   Parameter: The key for the option in the options dictionary.

6. `(BOOL)isValidConfigurationWithError:(NSError *_Nullable*_Nullable)error;`
   Description: Verify that the current configuration is a valid and connectable configuration.
   Parameter: error Message containing the error.