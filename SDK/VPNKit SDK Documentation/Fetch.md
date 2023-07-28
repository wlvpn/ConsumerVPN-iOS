# Server

  Method to update the server list
- (void)updateServerList
  Updates the server list and saves it to the current list of servers. Calls updateServerList:YES

`Server` model contains the following information about the specific server:
- `name`: The name of the server. Usually the hostname
- `capacity`: The % capacity in use expressed as an integer.
- `cityName`: The name of the city that contains this server
- `countryName`: The name of the country that contains this server
- `hostname`: The full hostname of the server
- `icon`: A URL that contains a flag image you can use.
- `ipAddress` : The IP address of the server
- `lastUpdated`: The last time the information about this server was update
- `scheduledMaintenance`: The start time for scheduled maintenance on this server
- `latitude`: The latitude of the server
- `longitude`: The longitude of the server
- `maintenance`: Is this server in maintenance?
- `presharedKey`: The preshared key used to connect to this server
- `serverID`: Returns the hostname for the server
- `status`: The server status. Returns 1 if not in maintenance and 0 if in maintenance.
- `visible`: The server visibility (in the server list). Returns 1 if not in maintenance and 0 if in maintenance.
- `city`: The city that contains this server
- `country`: The country that contains this server
- `protocols`:  A list of detailed properties about our protocol configuration

## Fetch all cities
 Fetch all of the cities from the APIManager
 
        if let fetchedCities = apiManager.fetchAllCities() as? [City] {
            // Handle 
        }

## CityModel
 NSManagedObject
 Describes each City object in the context of our ServerListViewController
- `isExpanded`: Bool - Determines whether the cityModel object is expanded in the server list table view controller to display all children servers
- `name`: String: Localized name of the city.
- `countryName`: String: Localized name of the country this city belongs to. This `should` be done on the API side.
- `cityDisplayName`: String: Localized combination of the city and country. This `should` be done on the API side.
- `countryID`: String: Localized CountryID. 
- `city`: City: Reference to the Core Data city object. This receives updates when pinging
- `flagImage`: Image representing the country this city belongs to
- `filteredServers`: List of servers that contain the search text the user provided

## Fetch all countries
Fetch all countries from the APIManager

        if let fetchedCities = apiManager.fetchAllCountries() as? [Country] {
            // Handle 
        }
        
## Country Model : 
  NSManagedObject 
  A country where we have Cities/Servers.

1. `countryID`: NSString - The ISO-3166-1 alpha-2 country code for the country.
2. `name`: NSString - The country name. Set to the localizedName on fetch/insert.
3. `cities`: NSSet<City *> - Cities in this country 
4. `servers`: NSSet<Server *> - Servers in this country
5. `localizedName`: NSString - This calls a function that returns a localized country name
6. `englishName`: NSString - This calls a function that returns a english country name
7. `flagImage`: CountryFlagImage - An image of the flag that can be used by consumers of the country
8. `sortedCities`: `(NSArray<City *> *)` - Return anArray of cities sorted by city name
9. `sortedServers`: `(NSArray<Server *> *)` - Return anArray of servers sorted by server name

