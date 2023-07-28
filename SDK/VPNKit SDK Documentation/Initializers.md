# V3APIAdapter:

Add following keys to the `V3APIAdapter` initialization code
- `kV3BaseUrlKey`: This is the baseurl for api's.
- `kV3AlternateUrlsKey`: The alternate Url in case baseurl fails.
- `kV3ApiKey`: The API key of app.
- `kV3CoreDataURL`: The URL for your CoreData Store.
- `V3InstallFavoritesPlugin`: By default `YES`
- `kV3ServiceNameKey`:  This is the name of the keychain item to use when storing the login and VPN credentials in the keychain. This should be the name of your app. If you set this to "My VPN App" then the API adapter will create services with names like "My VPN App Login" and 
"My VPN App Access Token".

```
  NSDictionary *options = @{
                kV3BaseUrlKey:               [self baseURL],
                kV3AlternateUrlsKey:	     [self backupURLs],
                kV3ApiKey:                   apiKey,
                kV3CoreDataURL:              [self coreDataURL],
                @"V3InstallFavoritesPlugin": @YES,
                kV3ServiceNameKey:           brandName,
    	};
```

# Connection Adapter:
 Initialize the connection adapter
- `kIKEv2UseIPAddress` : If set to 'YES' uses the IPAddress of server else uses server's hostname
- `kVPNManagerBrandNameKey` : This is the client's name
- `kIKEv2RemoteIdentifier` : This string will be used for authentication purposes in identifying the remote IPSec endpoint 
- `kVPNSharedSecretKey` : Shared secret key, can be the name of app
- `kIKEv2KeychainServiceName` : This is the name of the keychain item to use when connecting to the VPN. In most cases this should be set to: 

```
 NSDictionary *connectionOptions = @{
                kIKEv2UseIPAddress:         @YES,
    	        kVPNManagerBrandNameKey:    clientName,
    	        kIKEv2RemoteIdentifier:     @"*.vpn.appname.com",
    	        kVPNSharedSecretKey:        @"appname",
    	        kIKEv2KeychainServiceName:  [apiAdapter passwordServiceName],
    		};
```
# APIManager:
- `kBundleNameKey` : This is the bundle identifier you get from `CFBundleIdentifier`
- `kVPNDefaultProtocolKey` : The default protocol you want to set.
- `kVPNAccessGroupNameKey`: The name of the group using VPN
- `kCityPOPHostname` : This will be set as the POP hostname for all city objects. Used when you get the   hostname for the City.

```
  NSDictionary *apiManagerOptions = @{
                kBundleNameKey:         bundleName,
                kVPNDefaultProtocolKey: defaultProtocol,
                kVPNAccessGroupNameKey: kAccessGroupName,
                kCityPOPHostname:       @"appname.com",
    	};
```


