# VPNKit iOS Guide

VPNKit is a Framework developed to manage, create and monitor a VPN connection.
This framework provides an API to login, fetch servers, backup data in a database, connecting and configuring the VPN service, and getting connection states.

SETUP
## `FIRST:`
## ++`Integrate VPNKIt `++
1. Copy the VPNKit SDKs (VPNKit, VPNV3APIAdapter) from iOS_Fat (for simulator/development) or iOS_ARM (for production releases) or XCFrameworks to this folder.
    
 2. Copy the VPNKitNetworkExtensionAdapters SDKs (VPKWireGuardAdapter, VPKWireGuardExtension) from iOS_ARM (for production releases) or macOS to this folder.

- You can find the VPNKit changelog in its subfolder. [README](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/README.md)

## `Second:`
## ++`Add the required permissions for the app`++

1. `Personal VPN` : Enabling `Personal VPN` allows your app to create and control a custom system VPN configuration.
    1. Select your project in Xcode’s Project navigator.
    2. Select the app’s target in the Targets list.
    3. Click the Signing & Capabilities tab in the project editor.
    4. Locate the `Personal VPN`` capability.

2. `Network Extension`: Before your app can use the `Network Extension` framework to customize and extend the core networking features of iOS and macOS by implementing specific app capabilities, you must configure your Xcode project to include the necessary entitlements by performing the following steps:

    1. Select your project in Xcode’s Project navigator.
    2. Select the app’s target in the Targets list.
    3. Click the Signing & Capabilities tab in the project editor.
    4. Locate the `Network Extensions` capability.
    5. Enable `Packet Tunnel` capability by checking the corresponding checkboxes.
    6. Locate the `Personal VPN`

These capabilities are reflected under `Developer Account`
Developer > Account > Certificates, Identifiers & Profiles > Identifiers > [your app ID]

## `Third:`
## ++`Initialization`++

In **Appdelegate** initialize the SDK

An initialized VPNAPIManager object for various api and connection adapter settings is built using helper Objc objects. It contains a brand name, a configuration name, an api key, and a username suffix.

```
import VPNKit
class AppDelegate: UIResponder, UIApplicationDelegate {
var apiManager: VPNAPIManager!

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Initialize the APIManager using helper Objc object.
        apiManager = SDKInitializer.initializeAPIManager(
            withBrandName: //brandName,
            configName: //Your company custom VPN configuration name,
            apiKey: //apiKey,
            andSuffix: //usernameSuffix
        )
        // set the default encryption to 256 if one isn't already set
        if apiManager.vpnConfiguration.hasOption(forKey: kIKEv2Encryption) == false {
            apiManager.vpnConfiguration.setOption(kVPNEncryptionAES256, forKey: kIKEv2Encryption)
        }
}
}
```
The VPNAPIManager class creates a VPN connection and a VPN connection adapter for each VPN protocol. The VPNConnectionTestAdapter class fakes a VPN connection in the simulator and produces all the correct notifications.
```
/**
 * Builds a VPNAPIManager object for various api and connection adapter settings.
 *
 * @param brandName The brand name of this client
 * @param configName The VPN configuration name of this client
 * @param apiKey    The api key provided on WLVPN signup
 * @param suffix    The username suffix provided on WLVPN Signup
 *
 * @return An initialized VPNAPIManager ready to use
 */
+ (nonnull VPNAPIManager *)initializeAPIManagerWithBrandName:(NSString *)brandName
                                                  configName:(NSString *)configName
                                                      apiKey:(NSString *)apiKey
                                                   andSuffix:(NSString *)suffix {
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *bundleID = [infoDict objectForKey:@"CFBundleIdentifier"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:bundleID];
    //set path 
    NSURL *coreDataUrl = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:@"<Your Sqlite name>"]];
    
    NSDictionary *apiAdapterOptions = @{
        kV3BaseUrlKey:          // baseURL,
        kV3AlternateUrlsKey:    //array of alternate URLs if available else empty,
        kV3ApiKey:              //apiKey,
        kV3CoreDataURL:         //coreDataUrl,
        kV3ServiceNameKey:      //brandName
    };
    
    V3APIAdapter *apiAdapter = [[V3APIAdapter alloc] initWithOptions:apiAdapterOptions];
    
    NSDictionary *connectionOptions = @{
        kVPNManagerUsernameExtensionKey: suffix,
        kVPNManagerBrandNameKey: brandName,
        kVPNManagerConfigurationNameKey: configName,
        kIKEv2KeychainServiceName: apiAdapter.passwordServiceName //The name of the Keychain item containing the users login/billing credentials,
    };
    
    NSMutableArray *adapters = [NSMutableArray arrayWithCapacity:2];
    
    NSNumber *defaultProtocol = [NSNumber numberWithInt:VPNProtocolIKEv2];
    
    // The simulator doesn't work with VPN connections so the VPNConnectionTestAdapter fakes a connection
    // in the simulator. Produces all the correct notifications
#if (TARGET_OS_SIMULATOR)
    id <VPNConnectionAdapterProtocol> connectionAdapter = [[VPNConnectionTestAdapter alloc] initWithOptions:connectionOptions];
    [adapters addObject:connectionAdapter];
#else
    id <VPNConnectionAdapterProtocol> connectionAdapter = [[NEVPNManagerAdapter alloc] initWithOptions:connectionOptions];
    [adapters addObject:connectionAdapter];
    WireGuardAdapter *wireGuardAdapter = [self createWireGuardAdapterWithBrandName:brandName
                                                                            apiKey:apiKey
                                                                              uuid:[apiAdapter getOption:kV3UUIDKey]];
    [adapters addObject:wireGuardAdapter];
    defaultProtocol = [NSNumber numberWithInt:VPNProtocolWireGuard];
#endif
    
    NSDictionary *apiManagerOptions = @{
        kBundleNameKey: bundleID,
        kVPNDefaultProtocolKey: defaultProtocol,
    };
    
    VPNAPIManager *apiManager = [[VPNAPIManager alloc] initWithAPIAdapter:apiAdapter
                                                       connectionAdapters:adapters
                                                               andOptions:apiManagerOptions];
    
    // ensure that connections are not killed off when the app dies during an active connection
    [apiManager.vpnConfiguration setOption:@YES forKey:kVPNStayConnectedOnQuit];
    
    return apiManager;
}

#if !TARGET_OS_SIMULATOR
+ (WireGuardAdapter *)createWireGuardAdapterWithBrandName:(NSString *)brandName
                                                   apiKey:(NSString *)apiKey
                                                     uuid:(NSString *)uuid {
    
    WireGuardAdapterConfiguration *wgConfig = [[WireGuardAdapterConfiguration alloc] init];
    
    wgConfig.brandName = brandName;
    wgConfig.useAPIKey = NO;
    wgConfig.uuid = uuid; //[apiAdapter getOption:kV3UUIDKey];
    wgConfig.apiURL = [NSString stringWithFormat:@"%@wireguard", [self baseURL]];
    wgConfig.apiKey = apiKey;
    wgConfig.backupURL = @[];
    
    return [[WireGuardAdapter alloc] initWithConfiguration:wgConfig];
}
#endif
@end
```

## `Fourth:`
## ++`Implementation`++
## `1. Login/SignUP`

Login securely authenticates the user to your application.

```
func signIn(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
		//description This function will notify us via notifications of the results.
        apiManager.loginWithRetry(forUsername: username, password: password)
		signInCompletion = completion
	}
```
See: [Login Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/Login.md)


## `2. Fetch the servers`
```
// Do the initial table setup
// Fetch all of the cities from the APIManager
if let fetchedCities = apiManager.fetchAllCities() as? [City] {
 // Convert the fetchedCities into model objects
}
```
See: [Fetch Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/Fetch.md)


## `3. Fetch the location`
Fetch the current location model from the `vpnConfiguration` object.
See: [VpnConfiguration Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/Notifications.md)
**Properties**
`city`: **NSString**: The name of the geolocated city.
`country`: **NSString**: The name of the geolocated country.
`countryCode`: **NSString**: The ISO-3166-1 alpha-2 country code for the country.
`region`: **NSString**: The name of the geolocated region ("state" in the United States).
`ipAddress`: **NSString**: The users ip address.
`latitude`: **NSNumber**: The approximate latitude of the user.
`longitude`: **NSNumber**: The approximate longitude of the user.
`location`: **NSString**: Returns a user readable location string for convenience.

```
 ip  = vpnConfiguration.currentLocation?.ipAddress ?? "Loading"
```


## `4. Protocol`
If this method doesn't have a value, something went wrong and we should crash.
```
 /// This should have a value through dependency injection. If this doesn't have a value, something went wrong and we should crash
    var apiManager : VPNAPIManager! {
        didSet {
            vpnConfiguration = apiManager.vpnConfiguration
        }
    }
    var vpnConfiguration: VPNConfiguration?
    // set the  selectedProtocol property of VPNConfiguration

    // If WireGuard selected
                vpnConfiguration?.selectedProtocol = VPNProtocol.wireGuard
    // If IKEv2 selected        
                vpnConfiguration?.selectedProtocol = VPNProtocol.ikEv2
    // If IPSec selected       
                vpnConfiguration?.selectedProtocol = VPNProtocol.ipSec
```


## `5. Synchronize the configuration`
 * In order to avoid excessive updates to the underlying VPN connections, we don't automatically apply changes as they're made to VPNConfiguration.
 * Excessive updates can cause unpredictable client behavior.
 * Use this method to commit configuration changes to the currently active adapter.
 * Call this method whenever there are changes in the configuration.
 
``` 
- (void)synchronizeConfiguration;
- (void)synchronizeConfigurationWithCompletion:(void(^_Nullable)(BOOL success))completion;
```
Notifications related to synchronization are listed under `VPNConnectionStatusReporting` 
See: [Notifications Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/Notifications.md)


## `6. Connect`
With this, the user can connect and disconnect using the API.
See: [Connection Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/Connection.md)


## `7. Errors`
The API throws an error code and error message. These values are listed in the **Error documentation**
See: [Errors Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/Errors.md)


## `8. Notification`
The events fire notifications. The end-user must handle these events. Notifications are listed in the **Notifications documentation**
See: [Notifications Documentation](https://github.com/wlvpn/ConsumerVPN-iOS/blob/main/SDK/VPNKit%20SDK%20Documentation/Notifications.md)
