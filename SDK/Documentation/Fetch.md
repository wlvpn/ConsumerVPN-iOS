# Server

  Method to update the server list
- `(void)updateServerList`
  Fetch the server list and stores it as a current list of servers.

`Server` NSManagedObject model contains the following information about the specific server:
```markdown
- `name`                        : NSString - The name of the server. Usually the hostname.
- `capacity`                    : NSNumber - The % capacity in use expressed as an integer.
- `cityName`                    : NSString - The name of the city that contains this server.
- `countryName`                 : NSString - The name of the country that contains this server.
- `hostname`                    : NSString - The full hostname of the server.
- `ipAddress`                   : NSString - The IP address of the server.
- `lastUpdated`                 : NSDate - The last time the information about this server was updated.
- `scheduledMaintenanceStarts`  : NSDate - The start time for scheduled maintenance on this server.
- `scheduledMaintenanceEnds`    : NSDate - The end time for scheduled maintenance on this server.
- `latitude`                    : NSNumber - The latitude of the server location.
- `longitude`                   : NSNumber - The longitude of the server location.
- `maintenance`                 : NSString - Is this server under maintenance or not.
- `presharedKey`                : NSString - The preshared key used to connect to this server.
- `serverID`                    : NSString - Returns the hostname for the server.
- `status`                      : NSNumber - The server status. Returns 1 if not under maintenance else 0.
- `visible`                     : NSNumber - The server visibility (in the server list). Returns 1 if not under maintenance and 0 if under maintenance.
- `city`                        : The city that contains this server.
- `country`                     : The country that contains this server.
```

## Fetch all cities
 Fetch all of the cities from the APIManager
 ```swift
  apiManager.fetchAllCities()
```

## City
 `City` NSManagedObject model contains the following information about the specific city:

```markdown
- `cityID`              : NSString: A unique identifier for the city. Composed of cityName:countryCode.
- `name`                : NSString: Localized name of the city.
- `popName`             : NSString: A three letter code used to identify the POP.
- `latitude`            : NSNumber: The latitude of the city.
- `longitude`           : NSNumber: The longitude of the city
- `country`             : Name of the country this city belongs to.
- `servers`             : A set of servers that are in this City.
- `locationString`      : NSString: location string.
- `sortedServers`       : NSArray: Array of servers sorted by server name.
- `hostname`            : A hostname for the POP. Derived from the popName and the popHostname.
```

## Fetch all countries
Fetch all countries from the APIManager
```swift
 apiManager.fetchAllCountries()
```
        
## Country 
  `Country` NSManagedObject model contains the following information about the specific country:

```markdown
- `countryID`           : NSString - The ISO-3166-1 alpha-2 country code for the country.
- `name`                : NSString - The country name. Set to the localizedName on fetch/insert.
- `cities`              : NSSet<City *> - Cities in this country.
- `servers`             : NSSet<Server *> - Servers in this country.
- `localizedName`       : NSString - This returns a localized country name.
- `englishName`         : NSString - This returns a english country name.
- `flagImage`           : CountryFlagImage - An image of the flag that can be used by consumers of the country.
- `sortedCities`        : `(NSArray<City *> *)` - Return an Array of cities sorted by city name.
- `sortedServers`       : `(NSArray<Server *> *)` - Return an Array of servers sorted by server name.
```

## Fetch Current Location
`VPNCurrentLocationModel` NSManagedObject model for the current location.

```markdown
- `city`                : NSString - The name of the current city.
- `country`             : NSString - The name of the current country.
- `countryCode`         : NSString - The ISO-3166-1 alpha-2 country code for the current country.
- `region`              : NSString - The name of the current region.
- `ipAddress`           : NSString - The user's current IP address.
- `latitude`            : NSNumber - The approximate latitude of the user
- `longitude`           : NSNumber - The approximate longitude of the user
- `location`            : NSString - A user readable current location
```

Follow the below example to fetch current location
```swift
 ip  = apiManager.vpnConfiguration.currentLocation?.ipAddress ?? "Loading"
```

Fetch the current location by listening to the `VPNConfigurationStatusReporting` notification named 'statusCurrentLocationDidChange'
    - It contains VPNCurrentLocationModel object as a notification object.

Follow the below example to fetch current location
```swift
 extension VPNManager: VPNConfigurationStatusReporting {
    func statusCurrentLocationDidChange(_ notification: Notification) {
        if let currentLocation = (notification.object as? VPNConfiguration)?.currentLocation {
            DDLogVerbose("CurrentLocationDidChange");
            let currentLocation = currentLocation
        }
    }
}
```

