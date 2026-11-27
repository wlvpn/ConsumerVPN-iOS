# Dedicated IP Implementation

## Overview

This document describes how to implement Dedicated IP using the SDK.

The Dedicated IP flow consists of four steps:

1. Update account configuration to determine Dedicated IP entitlement and count.
2. Automatically fetch Dedicated IP locations when entitlement is detected, or explicitly refresh the list on demand.
3. Provide Dedicated IP servers, countries and cities.
4. Connect to a Dedicated IP server using the standard connection flow.

## Implementation Flow

### 1. Update Account Configuration

Update account configuration after login or app launch. This allows the SDK to determine whether the user has Dedicated IP entitlement.

`VPNAPIManager` exposes a `dedicatedIPsCount` property, populated from the account configuration response, indicating how many dedicated IP servers are available on the account.

### 2. Load Dedicated IP Locations

Use the following SDK methods to fetch Dedicated IP locations:

```swift
let dedicatedIPCountries = apiManager.fetchCountriesWithDedicatedIPs() as? [Country] ?? []
let dedicatedIPCities = apiManager.fetchCitiesWithDedicatedIPs() as? [City] ?? []
let dedicatedIPServers = apiManager.fetchServersWithDedicatedIPs() as? [Server] ?? []
```

To explicitly fetch and persist the latest dedicated IP server list (for example, on a pull-to-refresh), call:

```swift
apiManager.fetchDedicatedIPsServerList { success, error in
    // Reload dedicated IP countries/cities/servers on success.
}
```

The SDK reports the dedicated IP server fetch result through `VPNServerStatusReporting`:

- `statusDedicatedIPServersUpdateWillBegin` : Notify the receiver that the dedicated IP servers fetch operation is about to begin.
- `statusDedicatedIPServersUpdateSucceeded` : Notify the receiver that the dedicated IP servers fetch operation has completed successfully. The notification's object contains the updated dedicated IP servers.
- `statusDedicatedIPServersUpdateFailed` : Notify the receiver that the dedicated IP servers fetch operation has failed.

### 3. Load Servers for Selected City

When a city is selected, load its Dedicated IP servers:

```swift
let cityDedicatedIPServers = selectedCity.sortedDedicatedIPServers() as? [Server] ?? []
```

### 4. Connect to a Dedicated IP Server

Use the selected server with the standard VPN connection flow:

```swift
apiManager.vpnConfiguration.country = selectedCity.country
apiManager.vpnConfiguration.city = selectedCity
apiManager.vpnConfiguration.server = selectedDedicatedIPServer
apiManager.connect()
```

## Example

```swift
func connectToDedicatedIP(apiManager: VPNAPIManager) {
    let cities = apiManager.fetchCitiesWithDedicatedIPs() as? [City] ?? []

    guard
        let city = cities.first,
        let server = city.sortedDedicatedIPServers()?.firstObject as? Server
    else {
        return
    }

    apiManager.vpnConfiguration.country = city.country
    apiManager.vpnConfiguration.city = city
    apiManager.vpnConfiguration.server = server
    apiManager.connect()
}
```

## Recommended Integration Steps

1. Update account configuration after login or app launch, and read `dedicatedIPsCount` to determine entitlement.
2. Load Dedicated IP locations for the UI, calling `fetchDedicatedIPsServerList(completion:)` to refresh the list on demand (e.g. pull-to-refresh).
3. Load servers using `sortedDedicatedIPServers()` when a city is selected.
4. Assign the selected server to `vpnConfiguration.server`.
5. Call `connect()`.

## SDK Methods

### Location APIs

- `dedicatedIPsCount`
- `fetchDedicatedIPsServerList(force:completion:)`
- `fetchCountriesWithDedicatedIPs()`
- `fetchCitiesWithDedicatedIPs()`
- `fetchServersWithDedicatedIPs()`
- `sortedDedicatedIPServers()`

### Connection APIs

- `vpnConfiguration.country`
- `vpnConfiguration.city`
- `vpnConfiguration.server`
- `connect()`

## Notes

- Dedicated IP uses the same connection flow as standard servers.
- Only Dedicated IP-enabled accounts will receive Dedicated IP servers.
- No additional connection logic is required.
