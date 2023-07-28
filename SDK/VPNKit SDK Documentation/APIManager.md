# APIManager
Properties
- `isActiveUser`:`Bool`: Returns whether the user is Active or not
- `vpnConfiguration`: The VPNConfiguration class object.This class object manages the state of the VPN configuration and API state for the app. You can set/get the current user, account, country, city, server, etc.... you can also set VPN connection options such as on-demand.
- `status`: VPNConnectionStatus object which shows the current connection status. 
- `networkIsReachable`: Is the internet currently reachable by the device?
- `reachableViaWWAN`: BOOL - Whether or not the network is currently reachable via WWAN.
- `reachableViaWiFi`: Whether or not the network is currently reachable via WiFi.
- `networkType`: VPNNetworkType - Describes the type of network connection on device
- `captivePortalStatus`: CaptivePortal - Describes the possibility of being in a captive portal.
- `apiAdapter`: is readonly.
  Initiate the object
  Configure the vpnConfiguration object

## Refresh Location Functions
- `(void)refreshLocation`
  Refreshes the user's current location using the API adapter

## Update Server List
- `(void)updateServerList`
  Updates the server list and saves it to the current list of servers. Calls updateServerList

## Fetch Country Functions
- `fetchAllCountries`
  Returns An array of all countries

## Fetches all cities
- `fetchAllCities`
  Returns An array of all cities

# Connection Functions

- `(void)synchronizeConfiguration()`
  Use this method to commit configuration changes to the currently active adapter.

- `(void)connect;`
 Connect to the VPN with the provided VPNConfiguration

- `(void)disconnect;`
  Disconnect from the currently connected server.

- `(BOOL)isConnectedToVPN;`
  Returns YES if connected. Returns NO otherwise.

- `(BOOL)isConnectingToVPN;`
  Returns YES if connecting. Returns NO otherwise.

- `(BOOL)isDisconnectingFromVPN;`
  Returns YES if disconnecting. Returns NO otherwise.

- `(BOOL)isDisconnectedFromVPN;`
  Returns YES if disconnected. Returns NO otherwise.

- `(void)resetConfiguration;`
  Removing and resetting the current configuration on an attempt to get rid of issues.

- `(void)refreshConfiguration;`
  Refresh the current configuration.
